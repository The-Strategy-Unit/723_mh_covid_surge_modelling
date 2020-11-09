library(testthat)
library(mockery)

test_that("it calls markdownToHTML correctly", {
  m <- mock("<p>text</p>")

  stub(md_to_tags, "markdownToHTML", m)

  actual <- md_to_tags("file.md")

  expect_called(m, 1)
  expect_args(m, 1, "file.md", html.fragment = TRUE)

  expect_s3_class(actual, "shiny.tag.list")
  expect_equal(as.character(actual), "<p>text</p>")
})

test_that("it calls htmlTemplate correctly", {
  m <- mock()

  stub(md_to_tags, "markdownToHTML", "text")
  stub(md_to_tags, "htmlTemplate", m)

  md_to_tags()

  expect_called(m, 1)
  expect_args(m, 1, text_ = "text", document_ = FALSE)
})
