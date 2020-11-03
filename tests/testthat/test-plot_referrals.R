library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

# referrals_plot ----

test_that("referrals_plot returns a plotly chart", {
  actual <- referrals_plot(model_output, "IAPT")

  expect_s3_class(actual, "plotly")
})

test_that("referrals_plot returns NULL if no data is available", {
  stub(referrals_plot, "referrals_plot_data", tibble())

  actual <- referrals_plot(NULL, NULL)

  expect_null(actual)
})

# referrals_plot_data ----

test_that("referrals_plot_data returns a tibble", {
  model_output <- tibble(
    time = double(),
    date = lubridate::Date(),
    type = character(),
    group = character(),
    condition = character(),
    treatment = character(),
    value = double()
  )

  actual <- referrals_plot_data(model_output, "IAPT")

  expect_s3_class(actual, "tbl_df")
})

test_that("referrals_plot_data returns expected data", {
  actual <- referrals_plot_data(model_output, "IAPT")

  expect_equal(sum(actual$Referrals), 780917, tolerance = 1e-6)
  expect_equal(sum(actual$Treatments), 484368, tolerance = 1e-6)
})

test_that("referrals_plot_data calls summarise_model_output", {
  m <- mock(tibble(date = lubridate::Date(), value = double()), cycle = TRUE)
  stub(referrals_plot_data, "summarise_model_output", m)

  t <- tibble(group = "a", date = ymd(20200501))

  referrals_plot_data(t, "IAPT")

  expect_called(m, 2)
  expect_args(m, 1, "new-referral", model_output = t, treatment = "IAPT")
  expect_args(m, 2, "new-treatment", model_output = t, treatment = "IAPT")
})
