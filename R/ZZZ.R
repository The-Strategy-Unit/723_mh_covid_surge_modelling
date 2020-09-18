# any global variables that are used in the package need to be listed here: this will largely just be any NSE column
# names
utils::globalVariables(c("group", "condition", "treatment"))

# This function runs when the package is loaded: use it to set any variables into the parent environment
# note: must use the global assignment operator (<<-)
#' @importFrom dplyr %>%
#' @importFrom purrr modify_at map
.onLoad <- function(libname, pkgname) { # nolint
  sim_time <<- as.numeric(Sys.getenv("SIM_TIME", 1))

  params <<- app_sys("app/data/params.xlsx") %>%
    extract_params_from_excel() %>%
    modify_at("demand", as.list)

  population_groups <<- names(params$groups)

  treatments <<- names(params$treatments)
}
