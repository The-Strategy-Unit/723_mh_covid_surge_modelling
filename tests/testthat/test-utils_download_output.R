library(testthat)
library(mockery)

# setup data required: make sure to filter data to make this run quicker
model_output <- params %>%
  run_model(0.5) %>%
  get_model_output(ymd(20200501)) %>%
  filter(date < ymd(20200602))

test_that("it calls get_appointments", {
  a <- get_appointments(params)
  m <- mock(a)
  stub(download_output, "get_appointments", m)

  download_output(model_output, params)

  expect_called(m, 1)
  expect_call(m, 1, get_appointments(params))
})

test_that("it filters to just include the data from the first of the month", {
  pre <- model_output %>%
    dplyr::pull(date) %>%
    lubridate::day()
  # check that the test data doesn't pass the main test
  expect_false(all(pre == 1))

  out <- download_output(model_output, params) %>%
    dplyr::pull(date) %>%
    lubridate::day()

  expect_true(all(out == 1))
})

test_that("it summarises the model output", {
  mg <- mock()
  ms <- mock(model_output)

  stub(download_output, "group_by", mg)
  stub(download_output, "summarise", ms)
  stub(download_output, "across", NULL)

  download_output(model_output, params)

  expect_called(mg, 1)
  expect_called(ms, 1)

  expect_call(mg, 1, group_by(.,
                              .data$date,
                              .data$type,
                              .data$group,
                              .data$condition,
                              .data$treatment))
  expect_call(ms, 1, summarise(., across(.data$value, sum), .groups = "drop"))
})

test_that("it adds the demand data", {
  ma <- mock(get_appointments(params))
  mm <- mock()

  stub(download_output, "inner_join", ma)
  stub(download_output, "mutate", mm)

  download_output(model_output, params)

  expect_called(ma, 1)
  expect_called(mm, 1)

  expect_call(ma, 1, inner_join(., appointments, by = "treatment"))
  expect_call(mm, 1, mutate(.,
                            type = "demand",
                            value = .data$value * .data$average_monthly_appointments,
                            average_monthly_appointments = NULL))
})

test_that("it returns data as expected", {
  expect_snapshot(download_output(model_output, params))
})

# clean up
rm(model_output)
