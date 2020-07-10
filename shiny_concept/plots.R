
pop_plot <- function(model_data) {
  df <- model_data %>%
    filter(type == "at-risk")

  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~time,
          y = ~value,
          color = ~group,
          hovertemplate = paste("<b>Time</b>: %{x:.1f}",
                                "<b>Patients</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Time"),
                   yaxis = list(title = "# People at Risk of having MH Needs"))
}

demand_plot <- function(demand) {
  plot_ly(demand,
          type = "scatter",
          mode = "lines",
          x = ~time,
          y = ~no_appointments,
          color = ~treatment,
          hovertemplate = paste("<b>Time</b>: %{x:.1f}",
                                "<b>Demand</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Time"),
                   yaxis = list(title = "Demand"))
}
