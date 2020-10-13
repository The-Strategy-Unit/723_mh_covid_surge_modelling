#' Download Model Output
#'
#' Prepares a data frame of the model output that can be downloaded as a csv in order to be used with other applications
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param params the current `params` object used to model the data
#'
#' @return a data frame
#'
#' @importFrom dplyr %>% mutate filter near group_by_at summarise across
#' @importFrom lubridate day
#' @import rlang
download_output <- function(model_output, params) {
  appointments <- get_appointments(params)

  df <- model_output %>%
    filter(day(.data$date) == 1) %>%
    group_by(.data$date,
             .data$type,
             .data$group,
             .data$condition,
             .data$treatment) %>%
    summarise(across(.data$value, sum), .groups = "drop")

  bind_rows(
    df,
    # add the demand data
    df %>%
      filter(.data$type == "treatment") %>%
      inner_join(appointments, by = "treatment") %>%
      mutate(type = "demand",
             value = .data$value * .data$average_monthly_appointments,
             average_monthly_appointments = NULL)
  )
}
