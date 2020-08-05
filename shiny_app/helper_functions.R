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
