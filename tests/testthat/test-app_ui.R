library(testthat)
library(mockery)

test_that("main ui is generated correctly", {
  m1 <- mock()
  m2 <- mock()
  m3 <- mock()
  m4 <- mock()
  m5 <- mock()

  stub(app_ui, "home_ui", m1)
  stub(app_ui, "params_ui", m2)
  stub(app_ui, "demand_ui", m3)
  stub(app_ui, "results_ui", m4)
  stub(app_ui, "surgetab_ui", m5)

  expect_snapshot(app_ui())

  expect_called(m1, 1)
  expect_args(m1, 1, "home_page")

  expect_called(m2, 1)
  expect_args(m2, 1, "params_page")

  expect_called(m3, 1)
  expect_args(m3, 1, "demand_page")

  expect_called(m4, 1)
  expect_args(m4, 1, "results_page")

  expect_called(m5, 3)
  expect_args(m5, 1, "surge_subpopn")
  expect_args(m5, 2, "surge_condition")
  expect_args(m5, 3, "surge_service")
})

test_that("it calls golem_add_external_resources", {
  stub(app_ui, "home_ui", "home_page")
  stub(app_ui, "params_ui", "params_page")
  stub(app_ui, "demand_ui", "demand_page")
  stub(app_ui, "results_ui", "results_page")
  stub(app_ui, "surgetab_ui", "surge_subpopn")

  m <- mock()
  stub(app_ui, "golem_add_external_resources", m)

  app_ui()
  expect_called(m, 1)
})
