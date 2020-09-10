#' Download Results Report
#'
#' Generates a pdf report to download for the current services
#'
#' @param services the services to generate this report for
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param appointments output from \code{get_appointments()}
#' @param params the current `params` object used to model the data
#'
#' @return a function that accepts a file name to save the report to
#'
#' @import ggplot2
#' @import rlang
#' @importFrom rmarkdown render
#' @importFrom dplyr %>% filter group_by summarise across bind_rows inner_join mutate rename pull
#' @importFrom tidyr pivot_longer
download_report <- function(services, model_output, appointments, params) {
  report_rmd <- app_sys("app/data/report.Rmd")

  force(services)
  force(model_output)
  force(appointments)
  force(params)

  markdown_treatment <- model_output %>%
    filter(.data$type == "new-referral",
           .data$treatment == services) %>%
    group_by(.data$date) %>%
    summarise(across(.data$value, sum), .groups = "drop") %>%
    ggplot(aes(date, value)) +
    theme_bw() +
    geom_line(colour = "red") +
    scale_x_date(name = "Month",
                 date_breaks = "3 months",
                 date_labels =  "%b %Y") +
    labs(y = "New Referrals",
         title = "Additional Patients Receiving Service")

  markdown_demand <- model_output %>%
    filter(.data$type == "treatment",
           .data$treatment == services) %>%
    group_by(.data$date, .data$treatment) %>%
    summarise(across(.data$value, sum), .groups = "drop") %>%
    inner_join(appointments, by = "treatment") %>%
    mutate(no_appointments = .data$value * .data$average_monthly_appointments) %>%
    ggplot(aes(date, no_appointments)) +
    theme_bw() +
    geom_line(colour = "green") +
    scale_x_date(name = "Month",
                 date_breaks = "3 months",
                 date_labels =  "%b %Y") +
    labs(y = "Demand",
         title = "Typical Additional Contact Volumes per Appointment Type")

  markdown_referrals <- local({
    temp <- params

    df <- bind_rows(
      model_output %>%
        filter(.data$treatment == services,
               .data$type == "treatment") %>%
        group_by(.data$date) %>%
        summarise(across(.data$value, sum), .groups = "drop") %>%
        mutate(type = "surge"),
      temp$demand[[services]] %>%
        pivot_longer(-.data$month, names_to = "type") %>%
        rename(date = month) %>%
        mutate(across(date, ymd))
    )

    df <- bind_rows(
      df,
      df %>%
        group_by(date) %>%
        summarise(type = "total", value = sum(value)) %>%
        filter(date %in% (df %>% filter(type == "underlying") %>% pull(date)))
    )

    df %>%
      ggplot(aes(date, value, group = type, colour = type)) +
      theme_bw() +
      geom_line() +
      scale_x_date(name = "Month",
                   date_breaks = "3 months",
                   date_labels =  "%b %Y") +
      labs(title = "Referrals") +
      scale_colour_discrete(name = "Type")
  })

  report_params <- list(
    set_title = paste0("Modelled Results by Service: ", services),
    combined_plot = markdown_referrals,
    demand_plot = markdown_demand,
    referrals_plot = markdown_treatment,
    total_surge = model_output %>%
      model_totals("new-referral", services),
    total_demand = model_output %>%
      model_totals("treatment", services),
    total_newpatients = model_output %>%
      model_totals("new-treatment", services),
    source_referrals = model_output %>%
      filter(.data$type == "new-referral",
             .data$treatment == services,
             day(.data$date) == 1) %>%
      group_by(.data$group) %>%
      summarise(`# Referrals` = round(sum(.data$value), 0), .groups = "drop") %>%
      filter(.data$`# Referrals` != 0) %>%
      mutate(across(.data$group, fct_reorder, .data$`# Referrals`)) %>%
      arrange(-`# Referrals`) %>%
      rename(Group = group)
  )

  function(file) {
    rmarkdown::render(
      report_rmd,
      output_file = file,
      params = report_params,
      envir = new.env(parent = globalenv())
    )

    file
  }
}
