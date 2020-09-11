#' Summarise model output
#'
#' Helper function used to filter results of the model output for use in plots and tables
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param treatment a name of a treatment to filter by
#'
#' @return a filtered and summarised version of \code{model_output}
#'
#' @importFrom dplyr %>% filter group_by summarise across
#' @import rlang
summarise_model_output <- function(model_output, type, treatment) {
  # thought that you should be able to call {{type}} and {{treatment}} in the filter call, but this seems to be causing
  # the results to not filter correctly.
  f_type <- type
  f_treatment <- treatment

  model_output %>%
    filter(.data$type == f_type,
           .data$treatment == f_treatment) %>%
    group_by(.data$date, .add = TRUE) %>%
    summarise(across(.data$value, sum), .groups = "drop_last")
}
