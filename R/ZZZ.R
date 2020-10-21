# This function runs when the package is loaded: use it to set any variables into the parent environment
# note: must use the global assignment operator (<<-)
#' @importFrom dplyr %>%
#' @importFrom purrr modify_at map
.onLoad <- function(libname, pkgname) { # nolint
  sim_time <<- as.numeric(Sys.getenv("SIM_TIME", 0.2))

  params <<- app_sys("app/data/params_England.xlsx") %>%
    extract_params_from_excel() %>%
    modify_at("demand", as.list)
}
