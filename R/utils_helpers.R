half_life_factor <- function(t, p = 0.5) {
  log(p) / t
}

# tidyselect where is not-exported
where <- tidyselect:::where

# data conversion helpers ====

#' @importFrom dplyr %>%
#' @importFrom purrr map
#' @import rlang
get_all_conditions <- function(params) {
  params$groups %>%
    map("conditions") %>%
    map(names) %>%
    unname() %>%
    flatten_chr() %>%
    unique() %>%
    sort()
}

#' Get model output
#'
#' Takes models list and returns a dataframe of the model results
#'
#' @param models the model output list
#'
#' @importFrom dplyr %>% bind_rows mutate select
#' @import tidyselect
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

# model output helpers ====

#' @importFrom dplyr %>% filter pull
#' @importFrom lubridate day
#' @importFrom scales comma
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

#' @importFrom dplyr %>% filter group_by summarise across mutate arrange desc rename
#' @importFrom purrr compose
#' @importFrom stringr str_starts
#' @importFrom lubridate day
#' @importFrom tidyr pivot_wider
#' @import rlang
surge_summary <- function(model_output, column) {
  model_output %>%
    filter(day(.data$date) == 1,
           !is.na({{column}}),
           str_starts(.data$type, "new-")) %>%
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

# model helpers ====

#' @importFrom dplyr %>% bind_cols group_by mutate across select inner_join
#' @import tidyselect
#' @importFrom purrr map_dfr map modify_at
get_model_params <- function(params) {
  p <- params$groups %>%
    map_dfr(~.x$conditions %>%
              map(modify_at, "treatments", map_dfr, bind_cols, .id = "treatment") %>%
              map_dfr(bind_cols, .id = "condition") %>%
              group_by(.data$condition) %>%
              mutate(across(.data$pcnt, ~.x * .data$split / sum(.data$split))) %>%
              select(.data$condition, .data$treatment, .data$pcnt, .data$treat) %>%
              inner_join(params$treatments %>%
                           map_dfr(bind_cols, .id = "treatment"),
                         by = "treatment") %>%
              mutate(across(.data$decay, ~half_life_factor(.data$months, .x))) %>%
              select(-.data$months, -.data$demand),
            .id = "group") %>%
    as.data.frame()

  rownames <- paste(p$group, p$condition, p$treatment, sep = "|")
  p <- select(p, where(is.numeric))
  rownames(p) <- rownames

  p %>% as.matrix() %>% t()
}

#' @importFrom dplyr %>%
#' @importFrom purrr map
#' @importFrom stats approxfun
get_model_potential_functions <- function(params) {
  params$groups %>%
    map(~params$curves[[.x$curve]] * .x$size * .x$pcnt / 100) %>%
    map(approxfun, x = seq_len(24) - 1, rule = 2)
}

#' @importFrom purrr modify_at
run_single_model <- function(params, groups, months, sim_time) {
  cat("running_single_model:", groups)

  p <- modify_at(params, "groups", ~.x[groups])

  m <- get_model_params(p)
  g <- get_model_potential_functions(p)
  s <- seq(0, months - 1, by = sim_time)

  ret <- run_model(m, g, s)

  cat(" done\n")

  ret
}

# params helpers ====
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
