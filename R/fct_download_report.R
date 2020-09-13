#' Download Report
#'
#' Generates a pdf report to download for the current services
#'
#' @param model_output output from \code{run_model()} and \code{get_model_output()}
#' @param params the current `params` object used to model the data
#' @param services the services to generate this report for - ignored if "All" is selected for \code{download_choice}
#'
#' @return a function that accepts a file name to save the report to
#'
#' @import ggplot2
#' @import rlang
#' @importFrom rmarkdown render
#' @importFrom dplyr %>% filter group_by summarise across bind_rows inner_join mutate rename pull
#' @importFrom tidyr pivot_longer
download_report <- function(model_output, params, services) {
  report_rmd <- app_sys("app/data/report.Rmd")

  function(file) {
    rmarkdown::render(
      report_rmd,
      output_file = file,
      envir = current_env()
    )

    file
  }
}
