library(testthat)
library(mockery)

test_that("Counter can be instantiated", {
  counter <- methods::new("Counter")
  expect_s4_class(counter, "Counter")
})

test_that("Counter starts with a value of 0", {
  counter <- methods::new("Counter")
  expect_equal(counter$value, 0)
})

test_that("Counter get() increments and returns the value", {
  counter <- methods::new("Counter")
  expect_equal(counter$get(), 1)
  expect_equal(counter$get(), 2)
})
