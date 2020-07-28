
referrals_plot <- function(df) {
  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~date,
          y = ~value,
          hovertemplate = paste("<b>Month</b>: %{x:.1f}",
                                "<b>Referrals</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Month"),
                   yaxis = list(title = "New Referrals"))
}

demand_plot <- function(demand) {
  plot_ly(demand,
          type = "scatter",
          mode = "lines",
          x = ~date,
          y = ~no_appointments,
          hovertemplate = paste("<b>Month</b>: %{x:.1f}",
                                "<b>Demand</b>: %{y:.0f}",
                                sep = "<br>")) %>%
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Month"),
                   yaxis = list(title = "Demand"))
}


surge_plot <- function(data) {
  data %>%
    mutate_at("new-referral", `-`, quo(`new-treatment`)) %>%
    rename("Received treatment" = `new-treatment`,
           "Referred, but not treated" = `new-referral`) %>%
    pivot_longer(-group) %>%
    mutate_at("name", fct_rev) %>%
    ggplot(aes(value, group, fill = name)) +
    geom_col() +
    scale_x_continuous(expand = expansion(c(0, 0.05))) +
    scale_fill_discrete(guide = guide_legend(reverse = TRUE)) +
    theme(panel.background = element_blank(),
          panel.grid = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line.x = element_line(),
          legend.position = c(1, 0),
          legend.justification = c(1, 0),
          legend.title = element_blank()) +
    labs(y = "",
         x = "Total Referrals / Treatments",
         caption = paste0("The total receiving services offered for each condition will never exceed the total",
                          "symptomatic over period referrals"))
}
