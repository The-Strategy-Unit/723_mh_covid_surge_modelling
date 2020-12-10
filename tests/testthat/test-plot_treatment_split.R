library(testthat)
library(mockery)

treatments <- params$groups$`Children & young people`$conditions$Anxiety$treatments

test_that("it returns a plotly chart", {
  actual <- treatment_split_plot(treatments)

  expect_s3_class(actual, "plotly")
})

test_that("it returns NULL if no data is passed", {
  expect_null(treatment_split_plot(NULL))
  expect_null(treatment_split_plot(numeric()))
})

test_that("it calls plotly with correct args", {
  m1 <- mock("plot_ly")
  m2 <- mock("layout")
  m3 <- mock("config")

  stub(treatment_split_plot, "plot_ly", m1)
  stub(treatment_split_plot, "layout", m2)
  stub(treatment_split_plot, "config", m3)

  treatment_split_plot(treatments)

  t <- tibble(treatment = names(treatments),
              split = treatments) %>%
    mutate(across(.data$split, ~ .x / sum(.x)),
         across(.data$treatment, ~ .x %>%
                  str_wrap(width = 27) %>%
                  str_replace_all("\\n", "<br>")),
         across(.data$treatment, fct_reorder, split)) %>%
    arrange(desc(.data$split))

  expect_called(m1, 1)
  m1_args <- mock_args(m1)[[1]]
  expect_equal(m1_args[[1]], t)
  expect_equal(deparse(m1_args$x), "~split")
  expect_equal(deparse(m1_args$y), "~treatment")
  expect_equal(m1_args$marker, list(color = "#586FC1", line = list(color = "#2c2825", width = 1.5)))
  expect_equal(m1_args$type, "bar")

  expect_called(m2, 1)
  expect_args(
    m2,
    1,
    "plot_ly",
    xaxis = list(tickformat = "%",
                 title = FALSE),
    yaxis = list(title = FALSE,
                 tickfont = list(size = 10)),
    margin = list(l = 150)
  )

  expect_called(m3, 1)
  expect_args(m3, 1, "layout", displayModeBar = FALSE)
})
