library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

# combined_plot ----

test_that("combined_plot returns a plotly chart", {
  actual <- combined_plot(model_output, "IAPT", params)

  expect_s3_class(actual, "plotly")
})

test_that("combined_plot returns NULL if no data is available", {
  stub(combined_plot, "combined_plot_data", tibble())

  actual <- combined_plot(NULL, NULL, NULL)

  expect_null(actual)
})

# combined_plot_data ----

test_that("combined_plot_data returns a tibble", {
  model_output <- tibble(
    time = double(),
    date = lubridate::Date(),
    type = character(),
    group = character(),
    condition = character(),
    treatment = character(),
    value = double()
  )

  params <- list(
    demand = list(
      "IAPT" = tibble(
        month = lubridate::Date(),
        underlying = double(),
        suppressed = double()
      )
    )
  )

  actual <- combined_plot_data(model_output, "IAPT", params)

  expect_s3_class(actual, "tbl_df")
})

test_that("combined_plot_data returns expected data", {
  actual <- combined_plot_data(model_output, "IAPT", params)

  expect_equal(
    dplyr::count(actual, type),
    tibble(
      type = c("suppressed", "surge", "total", "underlying"),
      n = 36
    )
  )

  expect_equal(
    actual %>%
      group_by(type) %>%
      summarise(across(value, sum), .groups = "drop"),
    tribble(
      ~type,        ~value,
      "suppressed",  207970,
      "surge",       857992,
      "total",      6133973,
      "underlying", 5068011
    ),
    tolerance = 1e-6
  )
})

test_that("combined_plot_data calls summarise_model_output", {
  m <- mock(tibble())
  stub(combined_plot_data, "summarise_model_output", m)

  combined_plot_data(tibble(), "IAPT", params)

  expect_called(m, 1)
  expect_args(m, 1, tibble(), "new-referral", "IAPT")
})
