library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

# surge_plot ----

test_that("surge_plot returns a plotly chart", {
  actual <- surge_plot(model_output, group)

  expect_s3_class(actual, "plotly")
})

test_that("surge_plot returns NULL if no data is available", {
  stub(surge_plot, "surge_plot_data", tibble())

  actual <- surge_plot(NULL)

  expect_null(actual)
})

# surge_plot_data ----

test_that("surge_plot_data returns expected data", {
  actual <- surge_plot_data(model_output, group)
  expect_s3_class(actual, "tbl_df")

  expect_length(actual$group, 16)
  expect_equal(sum(actual$`Referred, but not treated`), 536504, tolerance = 0.5)
  expect_equal(sum(actual$`Received treatment`), 2345221, tolerance = 0.5)
})
