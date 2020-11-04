library(testthat)
library(mockery)

# ui ----

test_that("it creats the UI correctly", {
  mg2c <- mock()
  mc2t <- mock()
  stub(params_ui, "g2c_ui", mg2c)
  stub(params_ui, "c2t_ui", mc2t)

  ui <- params_ui("a")
  expect_snapshot(ui)
  expect_s3_class(ui, "shiny.tag")

  expect_called(mg2c, 1)
  expect_args(mg2c, 1, "g2c")

  expect_called(mc2t, 1)
  expect_args(mc2t, 1, "c2t")
})

# server ----

params_server_args <- function() list(
  params = lift_dl(reactiveValues)(params),
  model_output = reactive({
    params %>%
      run_model(1) %>%
      get_model_output(ymd(20200501))
  })
)

test_that("it creates variables", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    expect_s4_class(counter, "Counter")

    expect_s3_class(redraw_groups, "reactiveVal")
    expect_s3_class(redraw_treatments, "reactiveVal")
    expect_s3_class(redraw_g2c, "reactiveVal")
    expect_s3_class(redraw_c2t, "reactiveVal")

    expect_s3_class(popn_subgroup, "reactiveVal")
    expect_s3_class(conditions, "reactiveVal")

    expect_s3_class(upload_event, "reactivevalues")
    expect_s3_class(params_file_path, "reactiveVal")
  })
})

test_that("it returns the correct values", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    expect_equal(session$getReturned(), list(
      upload_event = upload_event,
      params_file_path = params_file_path
    ))
  })
})

test_that("it correctly sets up the submodules", {
  mg <- mock()
  mc <- mock()

  stub(params_server, "g2c_server", mg)
  stub(params_server, "c2t_server", mc)

  testServer(params_server, args = params_server_args(), {
    expect_called(mg, 1)
    expect_args(mg, 1,
                "g2c",
                params,
                redraw_g2c,
                redraw_c2t,
                counter,
                popn_subgroup)

    expect_called(mc, 1)
    expect_args(mc, 1,
                "c2t",
                params,
                redraw_c2t,
                counter,
                popn_subgroup,
                conditions)
  })
})

test_that("updating params_file_path() replaces the parameters", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  mock_params <- list(
    groups = list(group = list(curve = 1)),
    treatments = list(treatment = 1),
    curves = list(curve = 1),
    demand = "demand"
  )
  me <- mock(mock_params)
  mu <- mock()

  stub(params_server, "extract_params_from_excel", me)
  stub(params_server, "updateSelectInput", mu)
  testServer(params_server, args = params_server_args(), {
    params_file_path("file")
    session$private$flush()

    expect_called(me, 1)
    expect_args(me, 1, "file")

    expect_equal(upload_event$counter, 1)
    expect_true(upload_event$success)
    expect_equal(upload_event$msg, "Success")

    expect_equal(params$groups, mock_params$groups)
    expect_equal(params$treatments, mock_params$treatments)
    expect_equal(params$curves, mock_params$curves)
    expect_equal(params$demand, mock_params$demand)

    expect_equal(redraw_treatments(), 1)
    expect_equal(redraw_groups(), 1)

    expect_called(mu, 3)
    expect_args(mu, 1, session, "popn_subgroup", choices = names(mock_params$groups))
    expect_args(mu, 2,
                session,
                "subpopulation_curve",
                choices = names(mock_params$curves),
                choices = mock_params$groups[[1]]$curve)
    expect_args(mu, 3, session, "treatment_type", choices = names(mock_params$treatments))
  })
})

test_that("updating params_file_path() with an invalid file updates upload_event", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  mu <- mock()

  stub(params_server, "extract_params_from_excel", function(path) stop("error"))
  stub(params_server, "updateSelectInput", mu)
  testServer(params_server, args = params_server_args(), {
    params_file_path("file")
    session$private$flush()

    expect_equal(upload_event$counter, 1)
    expect_false(upload_event$success)
    expect_equal(upload_event$msg, "error")

    expect_null(redraw_treatments())
    expect_null(redraw_groups())

    expect_called(mu, 0)
  })
})

test_that("changing popn_subgroup updates reactives", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(popn_subgroup = "a")
    expect_equal(popn_subgroup(), "a")
    expect_equal(redraw_groups(), 1)
  })
})

test_that("updating redraw_groups() updates inputs", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  m <- mock()
  stub(params_server, "updateNumericInput", m)
  stub(params_server, "updateSliderInput", m)

  testServer(params_server, args = params_server_args(), {
    sg <- "Children & young people"
    redraw_groups(1)
    session$setInputs(popn_subgroup = sg)

    expect_equal(conditions(), names(params$groups[[sg]]$conditions))
    expect_equal(redraw_g2c(), 2)

    expect_called(m, 3)
    expect_args(m, 1, session, "subpopulation_size", value = 8819765)
    expect_args(m, 2, session, "subpopulation_pcnt", value = 10)
    expect_args(m, 3, session, "subpopulation_curve", value = "Fluctuating Fears")
  })
})

test_that("updating subpopulation_size input updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    sg <- "Children & young people"
    session$setInputs(popn_subgroup = sg,
                      subpopulation_size = 1)
    expect_equal(params$groups[[sg]]$size, 1)
  })
})

test_that("updating subpopulation_pcnt input updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    sg <- "Children & young people"
    session$setInputs(popn_subgroup = sg,
                      subpopulation_pcnt = 1)
    expect_equal(params$groups[[sg]]$pcnt, 1)
  })
})

test_that("subpopulation_size_pcnt is updated correctly", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    sg <- "Children & young people"
    session$setInputs(popn_subgroup = sg,
                      subpopulation_size = 12345,
                      subpopulation_pcnt = 10)

    expect_equal(output$subpopulation_size_pcnt, 'Modelled population: 1,234')
  })
})

test_that("updating subpopulation curve updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    sg <- "Children & young people"
    session$setInputs(popn_subgroup = sg,
                      subpopulation_curve = "a")
    expect_equal(params$groups[[sg]]$curve, "a")
  })
})

test_that("subpopulation_curve_plot renders the plot correctly", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  mp <- mock("plot")

  stub(params_server, "subpopulation_curve_plot", mp)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(subpopulation_curve = "Fluctuating Fears",
                      subpopulation_size = 12345,
                      subpopulation_pcnt = 10)

    expect_called(mp, 1)
    expect_args(mp, 1, params$curves$`Fluctuating Fears`, 12345, 10)
  })
})

test_that("updating treatment_type input updates redraw_treatments", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "a")
    expect_equal(redraw_treatments(), 1)
    session$setInputs(treatment_type = "b")
    expect_equal(redraw_treatments(), 2)
  })
})

test_that("redraw_treatments() updates inputs", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  m <- mock()
  stub(params_server, "updateSliderInput", m)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT")
    tx <- params$treatments[["IAPT"]]

    expect_called(m, 5)
    expect_args(m, 1, session, "treatment_appointments", value = tx$demand)
    expect_args(m, 2, session, "slider_success", value = tx$success * 100)
    expect_args(m, 3, session, "slider_tx_months", value = tx$months)
    expect_args(m, 4, session, "slider_decay", value = tx$decay * 100)
    expect_args(m, 5, session, "slider_treat_pcnt", value = tx$treat_pcnt * 100)
  })
})

test_that("treatment_appointments updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT",
                      treatment_appointments = 123)
    expect_equal(params$treatments[["IAPT"]]$demand, 123)
  })
})

test_that("slider_success updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT",
                      slider_success = 123)
    expect_equal(params$treatments[["IAPT"]]$success, 1.23)
  })
})

test_that("slider_tx_months updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT",
                      slider_tx_months = 123)
    expect_equal(params$treatments[["IAPT"]]$months, 123)
  })
})

test_that("slider_decay updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT",
                      slider_decay = 123)
    expect_equal(params$treatments[["IAPT"]]$decay, 1.23)
  })
})

test_that("slider_treat_pcnt updates params", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  testServer(params_server, args = params_server_args(), {
    session$setInputs(treatment_type = "IAPT",
                      slider_treat_pcnt = 123)
    expect_equal(params$treatments[["IAPT"]]$treat_pcnt, 1.23)
  })
})

test_that("download_params extracts the params correctly", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  m <- mock()
  stub(params_server, "downloadHandler", m)
  testServer(params_server, args = params_server_args(), {
    expect_called(m, 1)
    ma <- mock_args(m)[[1]]
    expect_equal(ma[[1]], "params.xlsx")
    expect_type(ma[[2]], "closure")

    fn <- ma[[2]]
    mp <- mock()
    stub(fn, "params_to_xlsx", mp)
    fn("file")

    expect_called(mp, 1)
    expect_args(mp, 1, params, "file")
  })
})

test_that("app help is added correctly", {
  stub(params_server, "g2c_server", NULL)
  stub(params_server, "c2t_server", NULL)

  m <- mock()
  stub(params_server, "ask_confirmation", m)

  help <- app_sys("app/data/params_help.json") %>%
    read_json(TRUE)

  help_text <- help %>%
    purrr::map(function(data) {
      data$text %>%
        strsplit(": ") %>%
        map(~if (length(.x) >= 2) {
          tags$p(tags$strong(.x[[1]]), paste(.x[-1], collapse = " "))
        } else {
          tags$p(.x)
        })
    })
  help_title <- map(help, "title")

  testServer(params_server, args = params_server_args(), {
    session$setInputs(population_group_help = 1,
                      group_to_cond_params_help = 2,
                      cond_to_treat_params_help = 3,
                      treatment_params_help = 4)
    expect_called(m, 4)

    expect_args(m, 1,
                "population_group_help_box",
                help_title[[1]],
                tagList(help_text[[1]]),
                "question",
                "ok",
                closeOnClickOutside = TRUE,
                showCloseButton = FALSE,
                html = TRUE)

    expect_args(m, 2,
                "group_to_cond_params_help_box",
                help_title[[2]],
                tagList(help_text[[2]]),
                "question",
                "ok",
                closeOnClickOutside = TRUE,
                showCloseButton = FALSE,
                html = TRUE)

    expect_args(m, 3,
                "cond_to_treat_params_help_box",
                help_title[[3]],
                tagList(help_text[[3]]),
                "question",
                "ok",
                closeOnClickOutside = TRUE,
                showCloseButton = FALSE,
                html = TRUE)

    expect_args(m, 4,
                "treatment_params_help_box",
                help_title[[4]],
                tagList(help_text[[4]]),
                "question",
                "ok",
                closeOnClickOutside = TRUE,
                showCloseButton = FALSE,
                html = TRUE)
  })
})
