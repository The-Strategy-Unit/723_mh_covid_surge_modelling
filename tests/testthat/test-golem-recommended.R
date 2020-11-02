library(testthat)
library(golem)
library(mockery)

test_that("app ui", {
  ui <- app_ui()
  expect_shinytaglist(ui)
})

test_that("app server", {
  server <- app_server
  expect_type(server, "closure")
})

test_that("app launches", {
  if (!"R" %in% dir(here::here())) {
    skip("This test only works in devtools::test")
  }

  # The issue is around here::here(), it will be running in golemTest.Rcheck/tests/testthat
  # on R cmd check, so it won't find the functions to load

  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  skip_on_ci()
  x <- processx::process$new(
    "R",
    c(
      "-e",
      "pkgload::load_all(here::here());run_app()"
    )
  )
  for (i in 1:100) {
    if (x$is_alive()) break ()
    Sys.sleep(0.1)
  }
  expect_true(x$is_alive())
  x$kill()
})
