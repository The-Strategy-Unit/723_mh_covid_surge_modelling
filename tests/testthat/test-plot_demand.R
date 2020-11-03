library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

appointments <- get_appointments(params)

# demand_plot ----

test_that("demand_plot returns a plotly chart", {
  actual <- demand_plot(model_output, appointments, "IAPT")

  expect_s3_class(actual, "plotly")
})

test_that("demand_plot returns NULL if no data is available", {
  stub(demand_plot, "demand_plot_data", tibble())

  actual <- demand_plot(NULL, NULL, NULL)

  expect_null(actual)
})

# demand_plot_data ----

test_that("demand_plot_data returns a tibble", {
  model_output <- tibble(
    time = double(),
    date = lubridate::Date(),
    type = character(),
    group = character(),
    condition = character(),
    treatment = character(),
    value = double()
  )

  appointments <- tibble(
    treatment = character(),
    average_monthly_appointments = double()
  )
  actual <- demand_plot_data(model_output, appointments, "IAPT")

  expect_s3_class(actual, "tbl_df")
})

test_that("demand_plot_data returns expected data", {
  actual <- demand_plot_data(model_output, appointments, "IAPT")

  expect_equal(sum(actual$value), 1584609)
  expect_equal(sum(actual$no_appointments), 2345221)
})

test_that("demand_plot_data calls summarise_model_output", {
  m <- mock(tibble(value = 1))
  stub(demand_plot_data, "summarise_model_output", m)

  demand_plot_data(tibble(), appointments, "IAPT")

  expect_called(m, 1)
  expect_args(m, 1, tibble(), "treatment", "IAPT")
})
