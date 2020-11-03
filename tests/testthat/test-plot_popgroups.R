library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

# popgroups_plot ----

test_that("popgroups_plot returns a plotly chart", {
  actual <- popgroups_plot(model_output, "IAPT")

  expect_s3_class(actual, "plotly")
})

test_that("popgroups_plot returns NULL if no data is available", {
  stub(popgroups_plot, "popgroups_plot_data", tibble())

  actual <- popgroups_plot(NULL, NULL)

  expect_null(actual)
})

# popgroups_plot_data ----

test_that("popgroups_plot_data returns a tibble", {
  model_output <- tibble(
    time = double(),
    date = lubridate::Date(),
    type = character(),
    group = character(),
    condition = character(),
    treatment = character(),
    value = double()
  )

  actual <- popgroups_plot_data(model_output, "IAPT")

  expect_s3_class(actual, "tbl_df")
})

test_that("popgroups_plot_data returns expected data", {
  actual <- popgroups_plot_data(model_output, "IAPT")

  expect_snapshot(actual)
})

test_that("popgroups_plot_data calls summarise_model_output", {
  m <- mock(
    tibble(value = 1, group = "a") %>%
      group_by(group)
  )
  stub(popgroups_plot_data, "summarise_model_output", m)

  popgroups_plot_data(tibble(group = "a", date = ymd(20200501)), "IAPT")

  expect_called(m, 1)
  expect_call(m, 1, summarise_model_output(., "new-referral", treatment))
})
