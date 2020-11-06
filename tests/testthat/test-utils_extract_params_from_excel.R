library(testthat)
library(mockery)

fake_read_excel <- function(break_sheet = NULL, break_value = NULL) {
  break_sheet <- if (is.null(break_sheet)) "" else break_sheet
  fn <- function(path, sheet, n_max) {
    force(break_sheet)
    force(break_value)

    if (sheet == break_sheet) {
      break_value
    } else if (sheet == "curves") {
      tibble(
        month = ymd(c(20200501, 20200601, 20200701, 20200801)),
        a = c(0.25, 0.25, 0.25, 0.25),
        b = c(0.10, 0.20, 0.20, 0.50)
      )
    } else if (sheet == "groups") {
      tibble(
        group = c("a", "b", "c"),
        curve = c("a", "a", "a"),
        size = c(1, 2, 3),
        pcnt = c(10, 20, 30)
      )
    } else if (sheet == "g2c") {
      tibble(
        group = c("a", "a", "b", "b", "c", "c"),
        condition = c("a", "b", "a", "b", "a", "b"),
        pcnt = c(0.01, 0.02, 0.03, 0.04, 0.05, 0.06)
      )
    } else if (sheet == "c2t") {
      tibble(
        group = rep(c("a", "b", "c"), each = 6),
        condition = rep(rep(c("a", "b"), each = 3), 3),
        treatment = rep(c("a", "b", "c"), 6),
        split = 1:18
      )
    } else if (sheet == "treatments") {
      tibble(
        treatment = c("a", "b", "c"),
        success = 1:3 / 100,
        months = 4:6,
        decay = 7:9 / 100,
        demand = 10:12 / 100,
        treat_pcnt = 13:15 / 100
      )
    } else if (sheet == "demand") {
      tibble(
        service = rep(c("a", "b", "c"), each = 4),
        month = rep(ymd(c(20200501, 20200601, 20200701, 20200801)), 3),
        underlying = 1:12,
        suppressed = 13:24
      )
    }
  }
}

test_that("it returns expected data", {
  stub(extract_params_from_excel,
       "excel_sheets",
       # add in some additional sheets
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))
  stub(extract_params_from_excel, "read_excel", fake_read_excel())

  actual <- extract_params_from_excel("file.xlsx")

  expected_demand <- tibble(
    service = rep(c("a", "b", "c"), each = 4),
    month = ymd(rep(c(20200501, 20200601, 20200701, 20200801), 3)),
    underlying = 1:12,
    suppressed = 13:24
  ) %>%
    group_nest(service)

  expected <- list(
    groups = list(
      a = list(
        size = 1, pcnt = 10, curve = "a",
        conditions = list(
          a = list(pcnt = 0.01, treatments = c(a = 1, b = 2, c = 3)),
          b = list(pcnt = 0.02, treatments = c(a = 4, b = 5, c = 6))
        )
      ),
      b = list(
        size = 2, pcnt = 20, curve = "a",
        conditions = list(
          a = list(pcnt = 0.03, treatments = c(a = 7, b = 8, c = 9)),
          b = list(pcnt = 0.04, treatments = c(a = 10, b = 11, c = 12))
        )
      ),
      c = list(
        size = 3, pcnt = 30, curve = "a",
        conditions = list(
          a = list(pcnt = 0.05, treatments = c(a = 13, b = 14, c = 15)),
          b = list(pcnt = 0.06, treatments = c(a = 16, b = 17, c = 18))
        )
      )
    ),
    treatments = list(
      a = list(success = 0.01, months = 4, decay = 0.07, demand = 0.1, treat_pcnt = 0.13),
      b = list(success = 0.02, months = 5, decay = 0.08, demand = 0.11, treat_pcnt = 0.14),
      c = list(success = 0.03, months = 6, decay = 0.09, demand = 0.12, treat_pcnt = 0.15)
    ),
    curves = list(a = c(0.25, 0.25, 0.25, 0.25), b = c(0.1, 0.2, 0.2, 0.5)),
    demand = set_names(expected_demand$data, expected_demand$service)
  )
  expect_equal(actual, expected)
})

test_that("if the correct sheets aren't present it throws an error", {
  stub(extract_params_from_excel,
       "excel_sheets",
       # miss off one sheet
       c("curves", "groups", "g2c", "c2t", "treatments"))

  expect_error(extract_params_from_excel("file.xlsx"), "Not all required sheets are present in file")
})

test_that("it only loads the correct sheets", {
  stub(extract_params_from_excel,
       "excel_sheets",
       # add in some additional sheets
       c("curves", "groups", "g2c", "c2t", "treatments", "demand", "a", "b"))

  rem <- fake_read_excel()
  m <- mock(
    rem("file.xlsx", "curves", 10000),
    rem("file.xlsx", "groups", 10000),
    rem("file.xlsx", "g2c", 10000),
    rem("file.xslx", "c2t", 10000),
    rem("file.xlsx", "treatments", 10000),
    rem("file.xlsx", "demand", 10000)
  )
  stub(extract_params_from_excel, "read_excel", m, depth = 2)

  expect_type(extract_params_from_excel("file.xlsx"), "list")

  expect_called(m, 6)
  expect_args(m, 1, "curves", path = "file.xlsx", n_max = 10000)
  expect_args(m, 2, "groups", path = "file.xlsx", n_max = 10000)
  expect_args(m, 3, "g2c", path = "file.xlsx", n_max = 10000)
  expect_args(m, 4, "c2t", path = "file.xlsx", n_max = 10000)
  expect_args(m, 5, "treatments", path = "file.xlsx", n_max = 10000)
  expect_args(m, 6, "demand", path = "file.xlsx", n_max = 10000)
})

test_that("it fails if curves don't sum to 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "curves",
    tibble(
      month = ymd(c(20200501, 20200601, 20200701, 20200801)),
      a = c(0.10, 0.10, 0.10, 0.10),
      b = c(0.25, 0.25, 0.25, 0.25)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "curves don't sum to 1")

  rem <- fake_read_excel(
    "curves",
    tibble(
      month = ymd(c(20200501, 20200601, 20200701, 20200801)),
      a = c(0.30, 0.30, 0.30, 0.30),
      b = c(0.25, 0.25, 0.25, 0.25)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "curves don't sum to 1")

  # though, it should work if values are close
  stub(extract_params_from_excel, "near", TRUE, depth = 3)
  # this should succeed
  expect_type(extract_params_from_excel("file.xlsx"), "list")
})

test_that("it fails if group percentages sum exceeds 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "g2c",
    tibble(
      group = c("a", "a", "b", "b", "c", "c"),
      condition = c("a", "b", "a", "b", "a", "b"),
      pcnt = c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "group percentages sum exceed 1")
})

test_that("it fails if group percentages are not between 0 and 100", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "groups",
    tibble(
      group = c("a", "b", "c"),
      curve = c("a", "a", "a"),
      size = c(1, 2, 3),
      pcnt = c(-10, 20, 30)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "group percentages not between 0 and 100")

  rem <- fake_read_excel(
    "groups",
    tibble(
      group = c("a", "b", "c"),
      curve = c("a", "a", "a"),
      size = c(1, 2, 3),
      pcnt = c(110, 20, 30)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "group percentages not between 0 and 100")
})

test_that("it fails if g2c pcnt not between 0 and 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "g2c",
    tibble(
      group = c("a", "a", "b", "b", "c", "c"),
      condition = c("a", "b", "a", "b", "a", "b"),
      pcnt = c(1.01, -0.02, 0.03, 0.04, 0.05, 0.06)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "g2c pcnt not between 0 and 1")
})

test_that("it fails if treatments success not between 0 and 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = - (1:3),
      months = 4:6,
      decay = 7:9 / 100,
      demand = 10:12 / 100,
      treat_pcnt = 13:15 / 100
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments success not between 0 and 1")

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = 1:3,
      months = 4:6,
      decay = 7:9 / 100,
      demand = 10:12 / 100,
      treat_pcnt = 13:15 / 100
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments success not between 0 and 1")
})

test_that("it fails if treatments decay not between 0 and 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = 1:3 / 100,
      months = 4:6,
      decay = 7:9 / -100,
      demand = 10:12 / 100,
      treat_pcnt = 13:15 / 100
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments decay not between 0 and 1")

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = 1:3 / 100,
      months = 4:6,
      decay = 7:9,
      demand = 10:12 / 100,
      treat_pcnt = 13:15 / 100
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments decay not between 0 and 1")
})

test_that("it fails if treatments treat_pcnt not between 0 and 1", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = 1:3 / 100,
      months = 4:6,
      decay = 7:9 / 100,
      demand = 10:12 / 100,
      treat_pcnt = 13:15 / -100
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments treat_pcnt not between 0 and 1")

  rem <- fake_read_excel(
    "treatments",
    tibble(
      treatment = c("a", "b", "c"),
      success = 1:3 / 100,
      months = 4:6,
      decay = 7:9 / 100,
      demand = 10:12 / 100,
      treat_pcnt = 13:15
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "treatments treat_pcnt not between 0 and 1")
})

test_that("it fails if unrecognised curve in groups", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "groups",
    tibble(
      group = c("a", "b", "c"),
      curve = c("a", "a", "c"),
      size = c(1, 2, 3),
      pcnt = c(10, 20, 30)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unrecognised curve in groups")
})

test_that("it fails if unrecognised group in g2c", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "g2c",
    tibble(
      group = c("a", "a", "b", "b", "c", "d"),
      condition = c("a", "b", "a", "b", "a", "b"),
      pcnt = c(0.01, 0.02, 0.03, 0.04, 0.05, 0.06)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unrecognised group in g2c")
})

test_that("it fails if unrecognised group in c2t", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "c2t",
    tibble(
      group = rep(c("a", "b", "d"), each = 6),
      condition = rep(rep(c("a", "b"), each = 3), 3),
      treatment = rep(c("a", "b", "c"), 6),
      split = 1:18
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unrecognised group in c2t")
})

test_that("it fails if unrecognised condition in c2t", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "c2t",
    tibble(
      group = rep(c("a", "b", "c"), each = 6),
      condition = rep(rep(c("a", "c"), each = 3), 3),
      treatment = rep(c("a", "b", "c"), 6),
      split = 1:18
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unrecognised condition in c2t")
})

test_that("it fails if unrecognised treatment in c2t", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "c2t",
    tibble(
      group = rep(c("a", "b", "c"), each = 6),
      condition = rep(rep(c("a", "b"), each = 3), 3),
      treatment = rep(c("a", "b", "d"), 6),
      split = 1:18
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unrecognised treatment in c2t")
})

test_that("it fails if unmapped group in g2c", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "c2t",
    tibble(
      group = rep(c("a", "a", "c"), each = 6),
      condition = rep(rep(c("a", "b"), each = 3), 3),
      treatment = rep(c("a", "b", "c"), 6),
      split = 1:18
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unmapped group in g2c")
})

test_that("it fails if unmapped condition in g2c", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "c2t",
    tibble(
      group = rep(c("a", "b", "c"), each = 6),
      condition = rep(rep(c("a", "a"), each = 3), 3),
      treatment = rep(c("a", "b", "c"), 6),
      split = 1:18
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unmapped condition in g2c")
})

test_that("it fails if unmapped group in groups", {
  stub(extract_params_from_excel,
       "excel_sheets",
       c("curves", "groups", "g2c", "c2t", "treatments", "demand"))

  rem <- fake_read_excel(
    "g2c",
    tibble(
      group = c("a", "a", "a", "a", "c", "c"),
      condition = c("a", "b", "a", "b", "a", "b"),
      pcnt = c(0.01, 0.02, 0.03, 0.04, 0.05, 0.06)
    )
  )
  stub(extract_params_from_excel, "read_excel", rem)
  expect_error(extract_params_from_excel("file.xlsx"), "unmapped group in groups")
})
