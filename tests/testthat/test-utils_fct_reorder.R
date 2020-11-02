library(testthat)
library(mockery)

test_that("it correctly reorders factors", {
  f <- factor(c("a", "b", "c"))
  v <- c(3, 1, 2)
  expect_equal(levels(fct_reorder(f, v)), c("b", "c", "a"))

  f <- factor(c("a", "a", "a", "b", "b", "b", "c", "c", "c"))
  v <- c(1, 2, 30, 1, 1, 2, 2, 3, 4)
  expect_equal(levels(fct_reorder(f, v)), c("b", "a", "c"))
  expect_equal(levels(fct_reorder(f, v, .fun = sum)), c("b", "c", "a"))
})

test_that("it correctly reorder factors descending", {
  f <- factor(c("a", "b", "c"))
  v <- c(3, 1, 2)
  expect_equal(levels(fct_reorder(f, v, .desc = TRUE)), c("a", "c", "b"))

  f <- factor(c("a", "a", "a", "b", "b", "b", "c", "c", "c"))
  v <- c(1, 2, 30, 1, 1, 2, 2, 3, 4)
  expect_equal(levels(fct_reorder(f, v, .desc = TRUE)), c("c", "a", "b"))
  expect_equal(levels(fct_reorder(f, v, .fun = sum, .desc = TRUE)), c("a", "c", "b"))
})

test_that("it calls the passed summary function", {
  f <- factor(c("a", "b", "c"))
  v <- c(3, 1, 2)
  m <- mock(3, 1, 2)

  fct_reorder(f, v, .fun = m, arg = 1)

  expect_called(m, 3)
  expect_call(m, 1, FUN(X[[i]], arg = 1))
})

