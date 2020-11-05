library(testthat)
library(mockery)

test_that("get_model_params converts params to a matrix", {
  mp <- get_model_params(params)

  expect_type(mp, "double")
  expect_true(is.matrix(mp))
  expect_equal(dim(mp), c(4, 595))

  expect_equal(apply(mp, 1, sum),
               c(pcnt = 3.9068,
                 treat = 473.636291402829,
                 success = 190.209031186532,
                 decay = -Inf))
})

test_that("get_model_potential_functions returns functions", {
  mpf <- get_model_potential_functions(params, 36)

  expect_length(mpf, 16)
  map(mpf, ~expect_type(.x, "closure"))
  expect_equal(mpf[[1]](1:5), c(4888.807, 12098.424, 21711.247, 36130.481, 57759.333))
  expect_equal(mpf[[3]](1:5), c(4083.682, 10105.965, 18135.676, 30180.243, 48247.093))
})
