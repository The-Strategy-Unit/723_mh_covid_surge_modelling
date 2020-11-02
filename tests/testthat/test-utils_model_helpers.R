library(testthat)
library(mockery)

test_that("get_model_params returns a matrix", {
  actual <- get_model_params(params)

  expect_type(actual, "double")
  expect_true(is.matrix(actual))

  expect_snapshot(actual)
})

test_that("get_model_potential_functions returns a list of functions", {
  actual <- get_model_potential_functions(params, length(params$curves[[1]]))

  expect_type(actual, "list")
  expect_length(actual, length(params$groups))

  walk(actual, ~expect_type(.x , "closure"))
})

test_that("get_model_potential_functions returns a functions that return doubles", {
  fn <- get_model_potential_functions(params, length(params$curves[[1]]))[[1]]

  actual <- fn(0:36)

  expect_type(actual, "double")
})
