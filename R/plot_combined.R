#' Combined Plot
#'
#' Generates a plot that shows the actual demand data, along with the suppressed activity figures, and the model output.
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#' @param params the current `params` object used to model the data
#'
#' @return \code{combined_plot()}: a plotly chart
#'
#' @importFrom dplyr %>%
#' @importFrom plotly plot_ly layout config
combined_plot <- function(model_output, treatment, params) {
  df <- combined_plot_data(model_output, treatment, params)

  if (nrow(df) < 1) return(NULL)

  df %>%
    plot_ly(type = "scatter",
            mode = "lines",
            x = ~date,
            y = ~value,
            hovertemplate = "%{y:.0f}",
            colors = c("#F8BF07", "#587FC1", "#EC6555", "#686F73"),
            color = ~type) %>%
    layout(showlegend = TRUE,
           hovermode = "x unified",
           xaxis = list(title = "Month"),
           yaxis = list(title = "# Referrals")) %>%
    config(displayModeBar = FALSE)
}

#' @rdname combined_plot
#'
#' @return \code{combined_plot_data()}: a summarised version of \code{model_output}
#'
#' @importFrom dplyr %>% filter group_by summarise across mutate rename
#' @importFrom tidyr pivot_longer
#' @importFrom lubridate ymd
combined_plot_data <- function(model_output, treatment, params) {
  df <- model_output %>%
    summarise_model_output("new-referral", {{treatment}}) %>%
    mutate(type = "surge") %>%
    bind_rows(
      params$demand[[treatment]] %>%
        pivot_longer(-.data$month, names_to = "type") %>%
        rename(date = .data$month) %>%
        mutate(across(.data$date, ymd))
    )

  bind_rows(
    df,
    df %>%
      filter(day(.data$date) == 1) %>%
      group_by(.data$date) %>%
      summarise(across(.data$value, sum), type = "total", .groups = "drop")
  )
}
