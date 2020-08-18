#' @importFrom dplyr %>% mutate filter near group_by_at summarise across
#' @importFrom lubridate day
#' @import rlang
#' @importFrom utils write.csv
download_output <- function(model_output, appointments) {
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
