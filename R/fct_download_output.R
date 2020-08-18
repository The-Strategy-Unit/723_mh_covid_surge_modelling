#' Download Model Output
#'
#' Download the model output as a csv in order to be used with other applications
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param appointments output from \code{get_appointments()}
#'
#' @return a function that accepts a file name to save the results to
#'
#' @importFrom dplyr %>% mutate filter near group_by_at summarise across
#' @importFrom lubridate day
#' @import rlang
#' @importFrom utils write.csv
download_output <- function(model_output, appointments) {
  # make sure to "force" the model_output and appointments so that the values are available when called from the
  # returned function
  force(model_output)
  force(appointments)

  function(file) {
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
    ) %>%
      write.csv(file, row.names = FALSE)
  }
}
