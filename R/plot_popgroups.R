#' Population Groups Plot Data
#'
#' Prepares the data for \code{popgroups_plot()}
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#'
#' @return a summarised version of \code{model_output}
#'
#' @importFrom dplyr %>% filter group_by summarise across mutate rename
popgroups_plot_data <- function(model_output, treatment) {
  model_output %>%
    group_by(.data$group) %>%
    filter(day(.data$date) == 1) %>%
    summarise_model_output("new-referral", treatment) %>%
    summarise(across(.data$value, ~round(sum(.x), 0)), .groups = "drop") %>%
    filter(.data$value != 0) %>%
    mutate(across(.data$group, fct_reorder, .data$value)) %>%
    arrange(-.data$value) %>%
    rename(`# Referrals` = .data$value)
}

#' Population Groups Plot
#'
#' Generates a plot that shows the size of the population groups for a given treatment.
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#'
#' @return a plotly chart
#'
#' @importFrom dplyr %>%
#' @importFrom plotly plot_ly layout config
popgroups_plot <- function(model_output, treatment) {
  df <- popgroups_plot_data(model_output, treatment)

  if (nrow(df) < 1) return(NULL)

  plot_ly(df,
          x = ~`# Referrals`,
          y = ~group,
          text = df$`# Referrals`,
          textposition = "auto",
          type = "bar",
          marker = list(color = "rgb(158,202,225)",
                        line = list(color = "rgb(8,48,107)", width = 1.5))) %>%
    layout(xaxis = list(title = "# Referrals"),
           yaxis = list(title = "")) %>%
    config(displayModeBar = FALSE)
}
