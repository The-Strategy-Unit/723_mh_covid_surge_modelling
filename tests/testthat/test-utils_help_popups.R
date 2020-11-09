library(testthat)
library(mockery)

fake_help <- list(
  a = list(
    title = "A",
    text = c("first", "second: paragraph")
  ),
  b = list(
    title = "B",
    text = c("test")
  )
)

test_that("it fails if the file doesn't exist", {
  expect_error(help_popups("page"), "no help file for page exists")
})

test_that("it reads the correct json file", {
  ma <- mock("page.json")
  mr <- mock()
  stub(help_popups, "file.exists", TRUE)
  stub(help_popups, "app_sys", ma)
  stub(help_popups, "read_json", mr)

  help_popups("page")

  expect_called(ma, 1)
  expect_args(ma, 1, "app/data/page_help.json")

  expect_called(mr, 1)
  expect_args(mr, 1, "page.json", TRUE)
})

test_that("it returns a named list of functions", {
  stub(help_popups, "file.exists", TRUE)
  stub(help_popups, "app_sys", "")
  stub(help_popups, "read_json", fake_help)

  actual <- help_popups("page")

  expect_type(actual, "list")
  expect_length(actual, 2)

  expect_type(actual$a, "closure")
  expect_type(actual$b, "closure")

  ma <- mock()
  mb <- mock()

  stub(actual$a, "ask_confirmation", ma)
  stub(actual$b, "ask_confirmation", mb)

  actual$a()
  actual$b()

  expect_called(ma, 1)
  expect_args(ma,
              1,
              "a_box",
              "A",
              tagList(
                list(
                  tags$p("first"),
                  tags$p(tags$strong("second"), "paragraph")
                )
              ),
              "question",
              "ok",
              closeOnClickOutside = TRUE,
              showCloseButton = FALSE,
              html = TRUE)

  expect_called(mb, 1)
  expect_args(mb,
              1,
              "b_box",
              "B",
              tagList(
                list(
                  tags$p("test")
                )
              ),
              "question",
              "ok",
              closeOnClickOutside = TRUE,
              showCloseButton = FALSE,
              html = TRUE)
})
