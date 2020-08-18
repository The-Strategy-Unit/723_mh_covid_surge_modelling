#' Get model output
#'
#' Takes models list and returns a dataframe of the model results
#'
#' @param models the model output list
#'
#' @importFrom dplyr %>% bind_rows mutate select everything
#' @importFrom lubridate %m+% ymd days
#'
#' @return a tibble
get_model_output <- function(models) {
  models %>%
    # combine models
    bind_rows() %>%
    # add in a date column relating to the time value
    # we need to add in separately the month's and days
    mutate(date = ymd(20200501) %m+%
             months(as.integer(floor(.data$time))) %m+%
             days(as.integer((.data$time - floor(.data$time)) * 30))) %>%
    select(.data$time, .data$date, everything())
}

#' @importFrom dplyr %>% bind_cols transmute
#' @importFrom purrr map_dfr
get_appointments <- function(params) {
  params$treatments %>%
    map_dfr(bind_cols, .id = "treatment") %>%
    transmute(.data$treatment, average_monthly_appointments = .data$demand)
}

#' @importFrom dplyr %>% filter pull
#' @importFrom lubridate day
#' @import rlang
model_totals <- function(model_output, type, treatment) {
  model_output %>%
    filter(.data$type == {{type}},
           .data$treatment == {{treatment}},
           day(.data$date) == 1) %>%
    pull(.data$value) %>%
    sum() %>%
    comma()
}

#' @importFrom dplyr %>% filter group_by summarise across mutate arrange desc rename starts_with
#' @importFrom purrr compose
#' @importFrom lubridate day
#' @importFrom tidyr pivot_wider
#' @import rlang
surge_summary <- function(model_output, column) {
  model_output %>%
    filter(day(.data$date) == 1,
           !is.na({{column}}),
           grepl("^new-", .data$type)) %>%
    group_by(.data$type, {{column}}) %>%
    summarise(across(.data$value, sum), .groups = "drop") %>%
    pivot_wider(names_from = .data$type, values_from = .data$value) %>%
    mutate(across({{column}}, fct_reorder, .data$`new-referral`),
           across(starts_with("new-"), compose(as.integer, round))) %>%
    arrange(desc(.data$`new-referral`)) %>%
    rename(group = {{column}})
}

#' @importFrom dplyr %>% rename
#' @import rlang
surge_table <- function(surge_data, group_name) {
  df <- surge_data %>%
    rename({{group_name}} := .data$`group`,
           "Total symptomatic over period referrals" = .data$`new-referral`,
           "Total receiving services over period" = .data$`new-treatment`)

  if ("new-at-risk" %in% colnames(df)) {
    df <- df %>%
      rename("Adjusted exposed / at risk @ baseline" = .data$`new-at-risk`)
  }

  df
}
