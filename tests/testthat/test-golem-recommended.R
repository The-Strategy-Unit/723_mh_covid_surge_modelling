context("golem tests")

library(golem)

test_that("app ui", {
  ui <- app_ui()
  expect_shinytaglist(ui)
})

test_that("app server", {
  server <- app_server
  expect_is(server, "function")
})

# Configure this test to fit your need
test_that("app launches", {
  if(!"R" %in% dir(here::here())) {
    skip("This test only works in devtools::test")
  }

  # The issue is around here::here(), it will be running in
  # golemTest.Rcheck/tests/testthat
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
  Sys.sleep(5)
  expect_true(x$is_alive())
  x$kill()
})

test_that("run_app starts the application correctly", {
  m <- mock("app")

  with_mock(with_golem_options = m, {
    res <- run_app()
  })

  expect_called(m, 1)
  expect_call(m, 1, with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server),
    golem_opts = list(...)
  ))
  expect_equal(res, "app")
})
