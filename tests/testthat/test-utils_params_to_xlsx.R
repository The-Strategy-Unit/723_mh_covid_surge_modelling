library(testthat)
library(mockery)

test_that("it saves the params to file correctly", {
  m <- mock()

  stub(params_to_xlsx, "write_xlsx", m)

  fake_params <- list(
    curves = list(
      a = 1:3,
      b = 4:6
    ),
    groups = list(
      a = list(
        size = 1,
        pcnt = 2,
        curve = "a",
        conditions = list(
          a = list(
            pcnt = 1,
            treatments = c(a = 1, b = 2)
          ),
          b = list(
            pcnt = 2,
            treatments = c(a = 3, b = 4)
          )
        )
      ),
      b = list(
        size = 3,
        pcnt = 4,
        curve = "b",
        conditions = list(
          a = list(
            pcnt = 3,
            treatments = c(a = 5, b = 6)
          ),
          b = list(
            pcnt = 4,
            treatments = c(a = 7, b = 8)
          )
        )
      )
    ),
    treatments = list(
      a = list(
        success = 1,
        months = 2,
        decay = 3,
        demand = 4,
        treat_pcnt = 5
      ) ,
      b = list(
        success = 6,
        months = 7,
        decay = 8,
        demand = 9,
        treat_pcnt = 10
      )
    ),
    demand = list(
      a = tibble(month = 1, underlying = 2, suppressed = 3),
      b = tibble(month = 4, underlying = 5, suppressed = 6)
    )
  )

  params_to_xlsx(fake_params, "file")

  expected <- list(
    curves = tibble(
      month = 0:2,
      a = 1:3,
      b = 4:6
    ),
    groups = tibble(
      group = c("a", "b"),
      curve = c("a", "b"),
      size = c(1, 3),
      pcnt = c(2, 4)
    ),
    g2c = tibble(
      group = c("a", "a", "b", "b"),
      condition = c("a", "b", "a", "b"),
      pcnt = 1:4
    ),
    c2t = tibble(
      group = c("a", "a", "a", "a", "b", "b", "b", "b"),
      condition = c("a", "a", "b", "b", "a", "a", "b", "b"),
      treatment = c("a", "b", "a", "b", "a", "b", "a", "b"),
      split = set_names(1:8, c("a", "b", "a", "b", "a", "b", "a", "b"))
    ),
    treatments = tibble(
      treatment = c("a", "b"),
      success = c(1, 6),
      months = c(2, 7),
      decay = c(3, 8),
      demand = c(4, 9),
      treat_pcnt = c(5, 10)
    ),
    demand = tibble(
      service = c("a", "b"),
      month = c(1, 4),
      underlying = c(2, 5),
      suppressed = c(3, 6)
    )
  )

  expect_args(m, 1, expected, "file")
})
