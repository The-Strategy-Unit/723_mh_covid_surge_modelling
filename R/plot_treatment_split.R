#' Treatment split plot
#'
#' generates a bar chart to show the percentage splits for the current treatments
#'
#' @param treatments a named vector of the splits for the treatments
#'
#' @importFrom dplyr tibble mutate across arrange desc
#' @importFrom plotly plot_ly layout config
#' @importFrom stringr str_wrap str_replace_all
#' @import rlang
#'
#' @return a plotly chart
treatment_split_plot <- function(treatments) {
  if (length(treatments) < 1 | is.null(treatments)) return(NULL)

  tibble(treatment = names(treatments),
         split = treatments) %>%
    mutate(across(.data$split, ~ .x / sum(.x)),
           across(.data$treatment, ~ .x %>%
                    str_wrap(width = 27) %>%
                    str_replace_all("\\n", "<br>")),
           across(.data$treatment, fct_reorder, .data$split)) %>%
    arrange(desc(.data$split)) %>%
    plot_ly(
      x = ~ split,
      y = ~ treatment,
      marker = list(
        color = "#586FC1",
        line = list(color = "#2c2825", width = 1.5)
      ),
      type =  "bar"
    ) %>%
    layout(
      xaxis = list(tickformat = "%",
                   title = FALSE),
      yaxis = list(title = FALSE,
                   tickfont = list(size = 10)),
      margin = list(l = 150)
    ) %>%
    config(displayModeBar = FALSE)
}
