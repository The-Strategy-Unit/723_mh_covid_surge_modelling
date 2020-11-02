library(testthat)
library(mockery)

# app_sys ----
test_that("app_sys calls and returns system.file", {
  m <- mock("system.file")
  stub(app_sys, "system.file", m)
  expect_equal(app_sys("a", "b", "c"), "system.file")
  expect_called(m, 1)
  expect_call(m, 1, system.file("a", "b", "c", package = "mhSurgeModelling"))
})

# get_golem_config ----
test_that("get_golem_config calls and returns config::get", {
  m <- mock("config::get")
  stub(get_golem_config, "config::get", m)
  stub(get_golem_config, "app_sys", identity)
  expect_equal(get_golem_config("a", "b", TRUE), "config::get")
  expect_called(m, 1)
  expect_args(m, 1, value = "a", config = "b", file = "golem-config.yml", use_parent = TRUE)
})
