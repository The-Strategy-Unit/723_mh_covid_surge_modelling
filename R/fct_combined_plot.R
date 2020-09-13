#' Combined Plot Data
#'
#' Prepares the data for \code{combined_plot()}
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#' @param params the current `params` object used to model the data
#'
#' @return a summarised version of \code{model_output}
#'
#' @importFrom dplyr %>% filter group_by summarise across mutate rename
#' @importFrom tidyr pivot_longer
#' @importFrom lubridate ymd
combined_plot_data <- function(model_output, treatment, params) {
  df <- model_output %>%
    summarise_model_output("treatment", {{treatment}}) %>%
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
      summarise(across(.data$value, sum), type = "total")
  )
}

#' Combined Plot
#'
#' Generates a plot that shows the actual demand data, along with the suppressed activity figures, and the model output.
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#' @param params the current `params` object used to model the data
#'
#' @return a plotly chart
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
            color = ~type) %>%
    layout(showlegend = TRUE,
           xaxis = list(title = "Month"),
           yaxis = list(title = "# Referrals")) %>%
    config(displayModeBar = FALSE)
}

#' @rdname combined_plot
#' @import ggplot2
#' @return a ggplot2 chart
combined_plot_ggplot <- function(model_output, treatment, params) {
  df <- combined_plot_data(model_output, treatment, params)

  if (nrow(df) < 1) return(NULL)

  df %>%
    ggplot(aes(.data$date, .data$value, group = .data$type, colour = .data$type)) +
    theme_bw() +
    geom_line() +
    scale_x_date(name = "Month",
                 date_breaks = "3 months",
                 date_labels =  "%b %Y") +
    labs(title = "Referrals") +
    scale_colour_discrete(name = "Type") +
    theme(legend.position = "bottom")
}
