library(testthat)
library(mockery)

# ui ----

test_that("it generates the UI correctly", {
  m <- mock("documentation")

  stub(home_ui, "md_to_tags", m)
  stub(home_ui, "app_sys", identity)
  stub(home_ui, "dir", c("params_a.xlsx", "params_b.xlsx", "params_c.xlsx"))

  ui <- home_ui("a")

  expect_snapshot(ui)
  expect_s3_class(ui, "shiny.tag.list")

  expect_called(m, 1)
  expect_args(m, 1, "app/data/home_documentation.md")
})

# server ----

home_server_args <- function() list(
  params_file_path = reactiveVal(),
  upload_event = reactiveValues(
    counter = 0,
    success = FALSE,
    msg = ""
  )
)

test_that("it handles params_select input correctly", {
  ms <- mock()
  mh <- mock()

  stub(home_server, "shinyjs::show", ms)
  stub(home_server, "shinyjs::hide", mh)

  testServer(home_server, args = home_server_args(), {
    # doesn't do anything if input$params_select is not truthy
    session$setInputs(params_select = NULL)

    expect_called(ms, 0)
    expect_called(mh, 0)
    expect_equal(params_file_path(), NULL)

    session$setInputs(params_select = "custom")
    expect_called(ms, 2)
    expect_args(ms, 1, "user_upload_xlsx")
    expect_args(ms, 2, "example_param_file_text")
    expect_called(mh, 0)
    expect_equal(params_file_path(), NULL)

    session$setInputs(params_select = "England")
    expect_called(ms, 2)
    expect_called(mh, 3)
    expect_args(mh, 1, "user_upload_xlsx")
    expect_args(mh, 2, "user_upload_xlsx_msg")
    expect_args(mh, 3, "example_param_file_text")
    expect_equal(params_file_path(), input$params_select)
  })
})

test_that("it handles custom file upload's correctly", {
  ms <- mock()
  stub(home_server, "shinyjs::show", ms)

  testServer(home_server, args = home_server_args(), {
    # it does nothing if the file is not truthy
    session$setInputs(user_upload_xlsx = NULL)

    expect_called(ms, 0)
    expect_equal(params_file_path(), NULL)

    session$setInputs(user_upload_xlsx = list(datapath = "file.xlsx"))
    expect_called(ms, 1)
    expect_args(ms, 1, "user_upload_xlsx_msg")
    expect_equal(params_file_path(), "file.xlsx")
  })
})

test_that("it renders upload messages correctly", {
  testServer(home_server, args = home_server_args(), {
    upload_event$counter <- 1
    upload_event$success <- TRUE
    upload_event$msg <- "Success"
    session$private$flush()

    h <- output$user_upload_xlsx_msg$html
    expect_equal(
      as.character(h),
      as.character(
        tags$div(
          tags$span(
            style = "color: green",
            "\u2714 ",
            tags$strong("Success")
          ),
          tags$br(),
          tags$br()
        )
      )
    )

    upload_event$counter <- 2
    upload_event$success <- FALSE
    upload_event$msg <- "message"
    session$private$flush()

    h <- output$user_upload_xlsx_msg$html
    expect_equal(
      as.character(h),
      as.character(
        tags$div(
          tags$span(
            style = "color: red",
            "\u2718 ",
            tags$strong("Error: "),
            "message"
          ),
          tags$br(),
          tags$br()
        )
      )
    )
  })
})
