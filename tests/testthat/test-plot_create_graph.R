library(testthat)
library(mockery)

model_output <- params %>%
  run_model(1) %>%
  get_model_output(ymd(20200501))

test_that("it returns a plotly object", {
  actual <- create_graph(model_output)

  expect_s3_class(actual, "plotly")
})

test_that("it calls plotly", {
  m1 <- mock("plot_ly")
  m2 <- mock("layout")
  m3 <- mock("config")

  stub(create_graph, "plot_ly", m1)
  stub(create_graph, "layout", m2)
  stub(create_graph, "config", m3)

  actual <- create_graph(model_output)

  expect_called(m1, 1)

  expect_called(m2, 1)
  expect_call(m2, 1, layout(p,
                            shapes = edge_shapes,
                            xaxis = list(visible = FALSE),
                            yaxis = list(visible = FALSE)))

  expect_called(m3, 1)
  expect_args(m3, 1, "layout", displayModeBar = FALSE)
})
