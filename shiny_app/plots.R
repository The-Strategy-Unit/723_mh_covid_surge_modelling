
referrals_plot <- function(df) {
  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~time,
          y = ~value,
          hovertemplate = paste("<b>Time</b>: %{x:.1f}",
                                "<b>Referrals</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Time"),
                   yaxis = list(title = "New Referrals"))
}

demand_plot <- function(demand) {
  plot_ly(demand,
          type = "scatter",
          mode = "lines",
          x = ~time,
          y = ~no_appointments,
          hovertemplate = paste("<b>Time</b>: %{x:.1f}",
                                "<b>Demand</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Time"),
                   yaxis = list(title = "Demand"))
}
