library(testthat)

test_that("it loads params variable", {
  mhSurgeModelling:::.onLoad()
  expect_true(exists("params"))
})

test_that("it loads sim_time variable", {
  mhSurgeModelling:::.onLoad()
  expect_true(exists("sim_time"))
})

test_that("default parameter files exist", {
  files <- dir(app_sys("app/data"), pattern = "\\.xlsx$")

  expect_equal(files, c("params_CWP.xlsx", "params_England.xlsx", "params_Mersey-Care.xlsx"))
})
