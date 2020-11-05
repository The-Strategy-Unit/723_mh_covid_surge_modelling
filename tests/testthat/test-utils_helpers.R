library(testthat)
library(mockery)

test_that("half_life_factor calculates half life factors correctly", {
  expect_equal(half_life_factor(0, 0), -Inf)
  expect_equal(half_life_factor(0, 1), NaN)
  expect_equal(half_life_factor(1, 0), -Inf)
  expect_equal(half_life_factor(1, 1), 0)

  expect_equal(half_life_factor(1, 0.25), log(0.25) / 1)
  expect_equal(half_life_factor(2, 0.25), log(0.25) / 2)
  expect_equal(half_life_factor(1, 0.50), log(0.50) / 1)
  expect_equal(half_life_factor(2, 0.50), log(0.50) / 2)
  expect_equal(half_life_factor(1, 0.75), log(0.75) / 1)
  expect_equal(half_life_factor(2, 0.75), log(0.75) / 2)
})

test_that("comma formats numbers correctly", {
  expect_equal(comma(123.45), "123")
  expect_equal(comma(1234.4), "1,234")
  expect_equal(comma(12345.678), "12,346")
})

test_that("where works as expected", {
  expect_type(where, "closure")
  expect_type(where(identity), "closure")

  m <- mock()
  t <- where(m)
  t(1, 2, 3)

  expect_called(m, 1)
  expect_call(m, 1, fn(x, 2, 3))
})

test_that("primary_box calls box with the right arguments set", {
  m <- mock()
  stub(primary_box, "box", m)
  primary_box(1, 2, 3)

  expect_called(m, 1)
  expect_call(m, 1, box(1, 2, 3, solidHeader = TRUE, status = "primary"))
})

test_that("replace_bootstrap_cols updates classes correctly", {
  t <- tagList(
    tags$div(
      class = "col-xs-4",
      tags$div(
        tags$div(class = "col-sm-4"),
        tags$div(class = "col-xs-4")
      )
    ),
    tags$div(
      class = "col-xs-4"
    )
  )

  actual <- replace_bootstrap_cols(t, "xs", "xl")
  expected <- tagList(
    tags$div(
      class = "col-xl-4",
      tags$div(
        tags$div(class = "col-sm-4"),
        tags$div(class = "col-xl-4")
      )
    ),
    tags$div(
      class = "col-xl-4"
    )
  )

  expect_equal(actual, expected)
})
