#' Subpopulation curve plot
#'
#' displays a quick plot of what the current parameters selected for the subpopulation group will generate
#'
#' @param curve the curve vector to display
#' @param size the base population size
#' @param pcnt the percentage of the base population size we are using (0 - 100)
#'
#' @importFrom plotly plot_ly layout config
#'
#' @return a plotly chart
subpopulation_curve_plot <- function(curve, size, pcnt) {
  x <- seq_along(curve)
  y <- curve * size * pcnt / 100

  plot_ly(x = x,
          y = y,
          type = "scatter",
          mode = "lines",
          text = paste0("month ", x, ": ", comma(y)),
          line = list(color = "#F8BF07"),
          hoverinfo = "text",
          line = list(shape = "spline")) %>%
    layout(xaxis = list(visible = FALSE,
                        showgrid = FALSE,
                        zeroline = FALSE),
           yaxis = list(visible = FALSE),
           margin = list(l = 0, r = 0, b = 0, t = 0, pad = 1),
           showlegend  = FALSE) %>%
    config(displayModeBar = FALSE)
}
