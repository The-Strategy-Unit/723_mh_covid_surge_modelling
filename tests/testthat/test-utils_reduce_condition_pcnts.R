library(testthat)
library(mockery)

test_that("it doesn't alter conditions if the percentages sum to less than 1", {
  conditions <- list(
    a = list(pcnt = 0.1),
    b = list(pcnt = 0.2),
    c = list(pcnt = 0.3)
  )
  expect_equal(reduce_condition_pcnts(conditions, c("a", "b")), conditions)
})

test_that("it reduces conditions equally if the percentages sum to more than 1", {
  conditions = list(
    a = list(pcnt = 0.2),
    b = list(pcnt = 0.2),
    c = list(pcnt = 0.8)
  )

  expect_equal(
    reduce_condition_pcnts(conditions, c("a", "b")),
    list(
      a = list(pcnt = 0.1),
      b = list(pcnt = 0.1),
      c = list(pcnt = 0.8)
    )
  )
})

test_that("it recursively reduces conditions if one condition is less than the reduction amount", {
  conditions = list(
    a = list(pcnt = 0.1),
    b = list(pcnt = 0.5),
    c = list(pcnt = 0.8)
  )

  expect_equal(
    reduce_condition_pcnts(conditions, c("a", "b")),
    list(
      a = list(pcnt = 0.0),
      b = list(pcnt = 0.2),
      c = list(pcnt = 0.8)
    )
  )
})
