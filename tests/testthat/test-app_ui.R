library(testthat)
library(mockery)

test_that("main ui is generated correctly", {
  expect_snapshot(app_ui())
})

test_that("it calls golem_add_external_resources", {
  m <- mock()
  stub(app_ui, "golem_add_external_resources", m)
  app_ui()
  expect_called(m, 1)
})
