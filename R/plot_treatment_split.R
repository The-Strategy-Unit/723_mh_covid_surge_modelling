#' Treatment split plot
#'
#' generates a bar chart to show the percentage splits for the current treatments
#'
#' @param treatments a named vector of the splits for the treatments
#'
#' @importFrom dplyr tibble mutate across arrange desc
#' @importFrom plotly plot_ly layout config
#' @import rlang
#'
#' @return a plotly chart
treatment_split_plot <- function(treatments) {
  if (length(treatments) < 1 | is.null(treatments)) return(NULL)

  tibble(treatment = names(treatments),
         split = treatments) %>%
    mutate(across(.data$split, ~ .x / sum(.x)),
           across(.data$treatment, fct_reorder, split)) %>%
    arrange(desc(.data$split)) %>%
    plot_ly(x = ~split,
            y = ~treatment,
            type =  "bar") %>%
    layout(xaxis = list(tickformat = "%",
                        title = FALSE),
           yaxis = list(title = FALSE))  %>%
    config(displayModeBar = FALSE)
}
