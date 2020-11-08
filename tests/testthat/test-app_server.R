library(testthat)
library(mockery)
library(shiny)

params <- if (file.exists("../fakes/fake_params.rds")) {
  readRDS("../fakes/fake_params.rds")
} else {
  readRDS(here::here("tests/fakes/fake_params.rds"))
}

test_that("it returns NULL invisibly", {
  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  expect_null(app_server(NULL, NULL, NULL))

  m <- mock()
  stub(app_server, "invisible", m)

  app_server(NULL, NULL, NULL)
  expect_called(m, 1)
  expect_call(m, 1, invisible(NULL))
})

test_that("it calls params_server", {
  m <- mock()

  stub(app_server, "params_server", m)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  app_server(NULL, NULL, NULL)

  expect_called(m, 1)
  expect_call(m, 1, params_server("params_page", params, model_output))
})

test_that("it calls home_server", {
  m <- mock()

  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", m)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  app_server(NULL, NULL, NULL)

  expect_called(m, 1)
  expect_call(m, 1, home_server("home_page", params_page$params_file_path, params_page$upload_event))
})

test_that("it calls demand_server", {
  m <- mock()

  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", m)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  app_server(NULL, NULL, NULL)

  expect_called(m, 1)
  expect_call(m, 1, demand_server("demand_page", params, params_page$upload_event))
})

test_that("it calls results_server", {
  m <- mock()

  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", m)
  stub(app_server, "surgetab_server", NULL)

  app_server(NULL, NULL, NULL)

  expect_called(m, 1)
  expect_call(m, 1, results_server("results_page", params, model_output))
})

test_that("it calls surgetab_server", {
  m <- mock()

  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", m)

  app_server(NULL, NULL, NULL)

  expect_called(m, 3)
  expect_call(m, 1, surgetab_server("surge_subpopn", model_output, .data$group, "Subpopulation group"))
  expect_call(m, 2, surgetab_server("surge_condition", model_output, .data$condition, "Condition"))
  expect_call(m, 3, surgetab_server("surge_service", model_output, .data$treatment, "Treatment"))
})

test_that("it converts params to reactiveValues", {
  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  t <- function(id) {
    moduleServer(id, app_server)
  }

  testServer(t, {
    expect_true(is.reactivevalues(params))
  })
})

test_that("it creates a reactive called model_output", {
  stub(app_server, "params_server", NULL)
  stub(app_server, "home_server", NULL)
  stub(app_server, "demand_server", NULL)
  stub(app_server, "results_server", NULL)
  stub(app_server, "surgetab_server", NULL)

  t <- function(id) {
    moduleServer(id, app_server)
  }

  m1 <- mock("run_model")
  m2 <- mock("get_model_output")
  stub(app_server, "run_model", m1)
  stub(app_server, "get_model_output", m2)

  testServer(t, {
    expect_true(is.reactive(model_output))
    expect_equal(model_output(), "get_model_output")

    expect_called(m1, 1)
    expect_call(m1, 1, run_model(., sim_time))
    expect_args(m1, 1, params, 0.2)

    expect_called(m2, 1)
    expect_call(m2, 1, get_model_output(., start_month))
    expect_args(m2, 1, "run_model", ymd(20200501))
  })
})
