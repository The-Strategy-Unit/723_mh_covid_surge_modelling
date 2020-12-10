library(testthat)
library(shiny)
library(shinytest)
library(mockery)

params_c2t_server_args <- function() {
  list(
    params = lift_dl(reactiveValues)(params),
    redraw_c2t = reactiveVal(),
    counter = methods::new("Counter"),
    popn_subgroup = reactiveVal(),
    conditions = reactiveVal()
  )
}

test_that("UI is created correctly", {
  ui <- c2t_ui("c2t_ui")
  expect_s3_class(ui, "shiny.tag.list")
})

test_that("updating conditions updates the dropdown", {
  m <- mock()
  stub(c2t_server, "updateSelectInput", m)

  testServer(c2t_server, args = params_c2t_server_args(), {
    conditions(c("a", "b", "c"))

    session$private$flush()
  })

  expect_called(m, 1)
  expect_call(m, 1, updateSelectInput(session, "sliders_select_cond", choices = conditions()))

  expect_equal(mock_args(m)[[1]][[2]], "sliders_select_cond")
  expect_equal(mock_args(m)[[1]][[3]], c("a", "b", "c"))
})

test_that("changing the dropdown triggers redraw c2t", {
  testServer(c2t_server, args = params_c2t_server_args(), {
    v <- counter$value
    session$setInputs("sliders_select_cond" = "a")

    expect_equal(redraw_c2t(), v + 1)
  })
})

test_that("changing the dropdown updates the container", {
  testServer(c2t_server, args = params_c2t_server_args(), {
    popn_subgroup("Children & young people")
    session$setInputs("sliders_select_cond" = "Anxiety")
    session$private$flush()

    expect_snapshot(output$container$html)
  })
})

test_that("changing the drop down updates the observers correctly", {
  testServer(c2t_server, args = params_c2t_server_args(), {
    popn_subgroup("Children & young people")

    session$setInputs("sliders_select_cond" = "Anxiety")
    expect_length(session$env$observers, 10)

    # test that destroy is called properly by replacing the observer with a mock
    mocks <- purrr::imap(session$env$observers, ~mock(.y))
    session$env$observers <- purrr::map(mocks, ~list(destroy = .x))

    session$setInputs("sliders_select_cond" = "Depression")
    expect_length(session$env$observers, 11)

    purrr::walk(mocks, expect_called, 1)
  })
})

test_that("changing the drop down updates the observers correctly", {
  testServer(c2t_server, args = params_c2t_server_args(), {
    sg <- "Children & young people"
    sc <- "Anxiety"
    st <- "24/7 Crisis Response Line"

    popn_subgroup(sg)
    session$setInputs("sliders_select_cond" = sc)

    expect_equal(params$groups[[sg]]$conditions[[sc]]$treatments[[st]], 3)
    session$setInputs("numeric_treat_split_24/7_Crisis_Response_Line" = 100)
    expect_equal(params$groups[[sg]]$conditions[[sc]]$treatments[[st]], 100)
  })
})

test_that("updating the treat split values updates the text output", {
  testServer(c2t_server, args = params_c2t_server_args(), {

    sg <- "Children & young people"
    sc <- "Anxiety"
    st <- "24/7 Crisis Response Line"

    popn_subgroup(sg)
    session$setInputs("sliders_select_cond" = sc)

    expect_equal(session$output[["pcnt_treat_split_24/7_Crisis_Response_Line"]], "3.0%")
    expect_equal(session$output[["pcnt_treat_split_IAPT"]], "39.0%")

    session$setInputs("numeric_treat_split_24/7_Crisis_Response_Line" = 10)
    expect_equal(session$output[["pcnt_treat_split_24/7_Crisis_Response_Line"]], "9.3%")
    expect_equal(session$output[["pcnt_treat_split_IAPT"]], "36.4%")
  })
})

test_that("updating the treatment parameters re-renders the plot", {
  m <- mock()
  stub(c2t_server, "treatment_split_plot", m)

  testServer(c2t_server, args = params_c2t_server_args(), {
    sg <- "Children & young people"
    sc <- "Anxiety"
    st <- "24/7 Crisis Response Line"

    popn_subgroup(sg)
    session$setInputs("sliders_select_cond" = sc)

    # change the value of an input to trigger re-render
    session$setInputs("numeric_treat_split_24/7_Crisis_Response_Line" = 10)
  })

  # called twice because of calling setInputs
  expect_called(m, 2)
  expect_call(m, 1, treatment_split_plot(params$groups[[sg]]$conditions[[ssc]]$treatments))
})
