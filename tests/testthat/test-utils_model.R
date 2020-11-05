library(testthat)

test_that("the model returns a tibble", {
  m <- run_model(params, 1)

  expect_s3_class(m, "tbl_df")

  expect_equal(colnames(m),
               c("time",
                 "type",
                 "group",
                 "condition",
                 "treatment",
                 "value"))
})

test_that("the model returns expected values", {
  expect_snapshot(run_model(params, 1))
})
