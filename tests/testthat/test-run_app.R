library(testthat)
library(mockery)

test_that("run_app starts the application correctly", {
  m <- mock("app")

  stub(run_app, "with_golem_options", m)

  res <- run_app()

  expect_called(m, 1)
  expect_call(m, 1, with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server),
    golem_opts = list(...)
  ))
  expect_equal(res, "app")
})
