library(testthat)
library(mockery)

params <- if (file.exists("../fakes/fake_params.rds")) {
  readRDS("../fakes/fake_params.rds")
} else {
  readRDS(here::here("tests/fakes/fake_params.rds"))
}

test_that("the model returns expected values", {
  actual <- run_model(params, 1)

  expect_s3_class(actual, "tbl_df")

  expect_equal(colnames(actual),
               c("time",
                 "type",
                 "group",
                 "condition",
                 "treatment",
                 "value"))

  expect_snapshot(data.frame(actual))
  expect_equal(sum(actual$value), 1669.036, tolerance = 1e-3)
  expect_equal(nrow(actual), 116)
})

test_that("it calls get_model_params", {
  m <- mock(get_model_params(params))
  stub(run_model, "get_model_params", m)
  run_model(params, 1)
  expect_called(m, 1)
  expect_args(m, 1, params)
})

test_that("it calls get_model_potential_functions", {
  m <- mock(get_model_potential_functions(params, 4))
  stub(run_model, "get_model_potential_functions", m)
  run_model(params, 1)
  expect_called(m, 1)
  expect_args(m, 1, params, 4)
})

test_that("it returns more rows if sim_time changes", {
  expect_equal(nrow(run_model(params, 0.2)), 464)
  expect_equal(nrow(run_model(params, 0.5)), 203)
})
