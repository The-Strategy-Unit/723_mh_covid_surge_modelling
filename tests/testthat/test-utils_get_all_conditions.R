library(testthat)
library(mockery)

test_that("it returns the names of the conditions", {
  p <- list(
    groups = list(
      g1 = list(
        conditions = list(a = 1, b = 2, c = 3)
      ),
      g2 = list(
        conditions = list(a = 4, b = 5, d = 6)
      ),
      g3 = list(
        conditions = list(e = 7)
      )
    )
  )

  actual <- get_all_conditions(p)

  expect_equal(actual, c("a", "b", "c", "d", "e"))

  # also test against the actual params
  expect_snapshot(get_all_conditions(params))
})
