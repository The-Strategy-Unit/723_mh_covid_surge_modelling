library(testthat)
library(mockery)

# ui ----

test_that("it generates the UI correctly", {
  ui <- results_ui("a")
  expect_s3_class(ui, "shiny.tag.list")
})

# server ----

results_server_args <- function() list(
  params = lift_dl(reactiveValues)(params),
  model_output = reactive(
    params %>%
      run_model(1) %>%
      get_model_output(ymd(20200501))
  )
)

value_box_expected <- function(v, t) {
  as.character(
    tags$div(
      class = "small-box bg-aqua",
      tags$div(
        class = "inner",
        tags$h3(v),
        tags$p(t)
      )
    )
  )
}

test_that("it set's up download handlers correctly", {
  # these tests would need to be integration tests
  m <- mock(renderUI("download_report"), renderUI("download_output"))

  stub(results_server, "downloadHandler", m)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(download_choice = "all")

    expect_equal(as.character(output$download_report$html), "download_report")
    expect_equal(as.character(output$download_output$html), "download_output")

    expect_called(m, 2)

    ma <- mock_args(m)

    # output$download_report
    expect_length(ma[[1]], 2) # 2 args
    expect_equal(ma[[1]]$filename, "report.pdf")
    expect_type(ma[[1]]$content, "closure")

    m1c <- mock("rmarkdown::render", cycle = TRUE)
    stub(ma[[1]]$content, "rmarkdown::render", m1c)
    stub(ma[[1]]$content, "current_env", "env")
    ma[[1]]$content("file.pdf")
    session$setInputs(download_choice = "selected")
    ma[[1]]$content("file.pdf")
    expect_called(m1c, 2)
    expect_args(m1c, 1,
                app_sys("app/data/report.Rmd"),
                output_file = "file.pdf",
                envir = "env")
    expect_args(m1c, 2,
                app_sys("app/data/report.Rmd"),
                output_file = "file.pdf",
                envir = "env")

    # output$download_output
    expect_length(ma[[2]], 3) # 3 args
    expect_type(ma[[2]]$filename, "closure")
    expect_type(ma[[2]]$content, "closure")
    expect_equal(ma[[2]]$contentType, "text/csv")

    stub(ma[[2]]$filename, "Sys.time", lubridate::ymd_hms("2020-01-01 01:23:45"))
    expect_equal(ma[[2]]$filename(), "model_run_2020-01-01_012345.csv")

    m2d <- mock("content")
    m2w <- mock("filename")
    stub(ma[[2]]$content, "download_output", m2d)
    stub(ma[[2]]$content, "write.csv", m2w)
    ma[[2]]$content("file.csv")

    expect_called(m2d, 1)
    expect_call(m2d, 1, download_output(model_output(), params))

    expect_called(m2w, 1)
    expect_args(m2w, 1, "content", "file.csv", row.names = FALSE)
  })
})

test_that("appointments contains correct values", {
  testServer(results_server, args = results_server_args(), {
    expect_equal(appointments(), get_appointments(params))
    expect_s3_class(appointments, "reactive")
  })
})

test_that("treatments contains correct values", {
  testServer(results_server, args = results_server_args(), {
    session$private$flush()
    expect_equal(treatments(), names(params$treatments))
    expect_s3_class(treatments, "reactive_changes")
  })
})

test_that("is updated when treatments() changes", {
  m <- mock()
  stub(results_server, "updateSelectInput", m)

  testServer(results_server, args = results_server_args(), {
    t1 <- names(params$treatments)
    t2 <- t1[1:2]
    session$private$flush()
    params$treatments <- params$treatments[1:2]
    session$private$flush()

    expect_called(m, 2)
    expect_args(m, 1, session, "services", choices = t1)
    expect_args(m, 2, session, "services", choices = t2)
  })
})

test_that("plots are created correctly", {
  m <- mock()

  stub(results_server, "renderPlotly", m)
  stub(results_server, "referrals_plot", "referrals_plot")
  stub(results_server, "demand_plot", "demand_plot")
  stub(results_server, "create_graph", "create_graph")
  stub(results_server, "combined_plot", "combined_plot")
  stub(results_server, "popgroups_plot", "popgroups_plot")

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(m, 5)
    expect_args(m, 1, "referrals_plot")
    expect_args(m, 2, "demand_plot")
    expect_args(m, 3, "create_graph")
    expect_args(m, 4, "combined_plot")
    expect_args(m, 5, "popgroups_plot")
  })
})

test_that("referrals_plot is called correctly", {
  m <- mock()
  stub(results_server, "referrals_plot", m)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(m, 1)
    expect_call(m, 1, referrals_plot(model_output(), input$services))
  })
})

test_that("demand_plot is called correctly", {
  m <- mock()
  stub(results_server, "demand_plot", m)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(m, 1)
    expect_call(m, 1, demand_plot(model_output(), appointments(), input$services))
  })
})

test_that("create_graph is called correctly", {
  m <- mock()
  stub(results_server, "create_graph", m)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(m, 1)
    expect_call(m, 1, create_graph(model_output(), treatments = input$services))
  })
})

test_that("popgroups_plot is called correctly", {
  m <- mock()
  stub(results_server, "popgroups_plot", m)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(m, 1)
    expect_call(m, 1, popgroups_plot(model_output(), input$services))
  })
})

test_that("it creates the value boxes correctly", {
  mmt <- mock("a", "b", "c")
  stub(results_server, "model_totals", mmt)

  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_called(mmt, 3)
    expect_args(mmt, 1, model_output(), "new-referral", "IAPT")
    expect_args(mmt, 2, model_output(), "treatment", "IAPT")
    expect_args(mmt, 3, model_output(), "new-treatment", "IAPT")

    expect_equal(
      as.character(output$total_referrals$html),
      value_box_expected("a", "Total 'surge' referrals")
    )

    expect_equal(
      as.character(output$total_demand$html),
      value_box_expected("b", "Total additional demand per contact type")
    )

    expect_equal(
      as.character(output$total_newpatients$html),
      value_box_expected("c", "Total new patients in service")
    )
  })
})

test_that("pcnt_surgedemand_denominator functions as expected", {
  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")

    expect_s3_class(pcnt_surgedemand_denominator, "reactive")
    expect_equal(pcnt_surgedemand_denominator(), 1689337)
  })
})

test_that("pcnt_surgedemand renders correct values", {
  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")
    expect_equal(
      as.character(output$pcnt_surgedemand$html),
      value_box_expected("46.2%", "Cumulative surge demand")
    )

    session$setInputs(services = "24/7 Crisis Response Line")
    expect_equal(
      as.character(output$pcnt_surgedemand$html),
      value_box_expected("434.8%", "Cumulative surge demand")
    )

    session$setInputs(services = "General Practice")
    expect_equal(
      as.character(output$pcnt_surgedemand$html),
      value_box_expected("NA*", "Cumulative surge demand")
    )
  })
})

test_that("pcnt_surgedemand_note returns a note if pcnt_surgedemand_denominator = 0", {
  testServer(results_server, args = results_server_args(), {
    session$setInputs(services = "IAPT")
    expect_equal(output$pcnt_surgedemand_note, "")

    session$setInputs(services = "General Practice")
    expect_equal(output$pcnt_surgedemand_note, "* underlying demand data not available")
  })
})
