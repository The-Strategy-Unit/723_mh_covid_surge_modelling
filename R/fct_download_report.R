#' Download Report
#'
#' Generates a pdf report to download for the current services
#'
#' @param services the services to generate this report for
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param appointments output from \code{get_appointments()}
#' @param demand the current value of `params$demand`
#'
#' @return a function that accepts a file name to save the report to
#'
#' @import ggplot2
#' @import rlang
#' @importFrom rmarkdown render
#' @importFrom dplyr %>% filter group_by summarise across bind_rows inner_join mutate rename pull
#' @importFrom tidyr pivot_longer
download_report <- function(services, model_output, appointments, demand) {
  report_rmd <- app_sys("app/data/report.Rmd")

  function(file) {
    rmarkdown::render(
      report_rmd,
      output_file = file,
      params = list(services = services),
      envir = current_env()
    )

    file
  }
}
