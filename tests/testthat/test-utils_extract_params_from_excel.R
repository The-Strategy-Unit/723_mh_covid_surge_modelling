library(testthat)
library(mockery)

test_that("if the correct sheets aren't present it throws an error", {
  stub(extract_params_from_excel,
       "excel_sheets",
       # miss off one sheet
       c("curves", "groups", "g2c", "c2t", "treatments"))

  expect_error(extract_params_from_excel("file.xlsx"))
})

test_that("it only loads the correct sheets", {
  stub(extract_params_from_excel,
       "excel_sheets",
       # add in some additional sheets
       c("curves", "groups", "g2c", "c2t", "treatments", "demand", "a", "b"))

  m <- mock()
  stub(extract_params_from_excel, "read_excel", m, depth = 2)

  # it should fail because the data is NULL
  expect_error(extract_params_from_excel("file.xlsx"))

  expect_called(m, 6)
  expect_args(m, 1, "curves", path = "file.xlsx", n_max = 10000)
  expect_args(m, 2, "groups", path = "file.xlsx", n_max = 10000)
  expect_args(m, 3, "g2c", path = "file.xlsx", n_max = 10000)
  expect_args(m, 4, "c2t", path = "file.xlsx", n_max = 10000)
  expect_args(m, 5, "treatments", path = "file.xlsx", n_max = 10000)
  expect_args(m, 6, "demand", path = "file.xlsx", n_max = 10000)
})
