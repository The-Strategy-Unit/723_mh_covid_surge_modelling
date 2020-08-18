#' Get All Conditions
#'
#' Extracts the names of the conditions from the current params
#'
#' @param params the current params used in the model
#'
#' @return a character vector of the condition names
#'
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
