#' Summarise model output
#'
#' Helper function used to filter results of the model output for use in plots and tables
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param type the row "type" to filter by
#' @param treatments the list of treatments to filter model_output by
#'
#' @return a filtered and summarised version of \code{model_output}
#'
#' @importFrom dplyr %>% filter group_by summarise across
#' @import rlang
summarise_model_output <- function(model_output, type, treatments) {
  model_output %>%
    filter(.data$type == {{type}},
           .data$treatment %in% treatments) %>%
    group_by(.data$date, .add = TRUE) %>%
    summarise(across(.data$value, sum), .groups = "drop_last")
}
