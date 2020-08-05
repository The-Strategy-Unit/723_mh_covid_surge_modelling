get_model_output <- function(models) {
  models %>%
    # combine models
    bind_rows() %>%
    # add in a date column relating to the time value
    # we need to add in separately the month's and days
    mutate(date = ymd(20200501) %m+%
             months(as.integer(floor(time))) %m+%
             days(as.integer((time - floor(time)) * 30))) %>%
    select(time, date, everything())
}

get_appointments <- function(params) {
  params$treatments %>%
    map_dfr(bind_cols, .id = "treatment") %>%
    transmute(treatment, average_monthly_appointments = demand)
}

model_totals <- function(model_output, type, treatment) {
  model_output %>%
    filter(type == {{type}}, treatment == {{treatment}}, day(date) == 1) %>%
    pull(value) %>%
    sum() %>%
    scales::comma()
}

surge_summary <- function(model_output, column) {
  model_output %>%
    filter(day(date) == 1, !is.na({{column}}), str_starts(type, "new-")) %>%
    group_by(type, {{column}}) %>%
    summarise(across(value, sum), .groups = "drop") %>%
    pivot_wider(names_from = type, values_from = value) %>%
    mutate(across({{column}}, fct_reorder, `new-referral`),
           across(starts_with("new-"), compose(as.integer, round))) %>%
    arrange(desc(`new-referral`)) %>%
    rename(group = {{column}})
}

surge_table <- function(surge_data, group_name) {
  df <- surge_data %>%
    rename({{group_name}} := `group`,
           "Total symptomatic over period referrals" = `new-referral`,
           "Total receiving services over period" = `new-treatment`)

  if ("new-at-risk" %in% colnames(df)) {
    df <- df %>%
      rename("Adjusted exposed / at risk @ baseline" = `new-at-risk`)
  }

  df
}
