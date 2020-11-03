library(testthat)
library(mockery)

test_that("it returns a plotly chart", {
  actual <- subpopulation_curve_plot(0:10, 5, 0.5)

  expect_s3_class(actual, "plotly")
})

test_that("it calls plotly with correct args", {
  m1 <- mock("plot_ly")
  m2 <- mock("layout")
  m3 <- mock("config")

  stub(subpopulation_curve_plot, "plot_ly", m1)
  stub(subpopulation_curve_plot, "layout", m2)
  stub(subpopulation_curve_plot, "config", m3)

  actual <- subpopulation_curve_plot(1:10, 500, 0.5)

  expect_called(m1, 1)
  expect_args(
    m1,
    1,
    x = 1:10,
    y = seq(2.5, 25, 2.5),
    type = "scatter",
    mode = "lines",
    text = paste0("month ", 1:10, ": ", comma(1:10 * 500 * 0.5 / 100)),
    line = list(color = "#F8BF07"),
    hoverinfo = "text",
    line = list(shape = "spline")
  )

  expect_called(m2, 1)
  expect_args(
    m2,
    1,
    "plot_ly",
    xaxis = list(visible = FALSE,
                 showgrid = FALSE,
                 zeroline = FALSE),
    yaxis = list(visible = FALSE),
    margin = list(l = 0, r = 0, b = 0, t = 0, pad = 1),
    showlegend  = FALSE
  )

  expect_called(m3, 1)
  expect_args(m3, 1, "layout", displayModeBar = FALSE)
})
