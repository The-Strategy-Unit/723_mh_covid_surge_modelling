library(testthat)
library(mockery)

test_that("main ui is generated correctly", {
  stub(app_ui, "home_ui", "home_page")
  stub(app_ui, "params_ui", "params_page")
  stub(app_ui, "demand_ui", "demand_page")
  stub(app_ui, "results_ui", "results_page")
  stub(app_ui, "surgetab_ui", "surge_subpopn")

  expect_snapshot(app_ui())
})

test_that("it calls golem_add_external_resources", {
  m <- mock()
  stub(app_ui, "golem_add_external_resources", m)
  app_ui()
  expect_called(m, 1)
})
