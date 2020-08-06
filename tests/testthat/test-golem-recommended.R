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
test_that(
  "app launches",{
    skip_on_cran()
    skip_on_travis()
    skip_on_appveyor()
    x <- processx::process$new(
      "R",
      c(
        "-e",
        "pkgload::load_all(here::here());run_app()"
      )
    )
    i <- 0
    while ((i <- i + 1) <= 10 && !x$is_alive()) {
      Sys.sleep(1)
    }
    expect_true(x$is_alive())
    x$kill()
  }
)








