library(testthat)
library(mockery)

test_that("get_model_params returns a matrix", {
  actual <- get_model_params(params)

  expect_type(actual, "double")
  expect_true(is.matrix(actual))

  expect_type(actual, "double")
  expect_true(is.matrix(actual))
  expect_equal(dim(actual), c(4, 580))

  expect_equal(apply(actual, 1, sum),
               c(pcnt = 3.9068,
                 treat = 463.6017,
                 success = 187.55692,
                 decay = -Inf))
})

test_that("get_model_potential_functions returns a list of functions", {
  actual <- get_model_potential_functions(params, length(params$curves[[1]]))

  expect_type(actual, "list")
  expect_length(actual, length(params$groups))

  walk(actual, ~expect_type(.x, "closure"))
})

test_that("get_model_potential_functions returns a functions that return doubles", {
  fn <- get_model_potential_functions(params, length(params$curves[[1]]))[[1]]

  actual <- fn(0:36)

  expect_type(actual, "double")
})

test_that("get_model_potential_functions returns functions", {
  mpf <- get_model_potential_functions(params, 36)

  expect_equal(mpf[[1]](1:5), c(4806.411, 12016.029, 21628.851, 36048.086, 57676.937))
  expect_equal(mpf[[3]](1:5), c(4014.856, 10037.139, 18066.850, 30111.417, 48178.267))
})
