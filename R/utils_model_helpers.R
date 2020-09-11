#' Get Model Params
#'
#' Converts the params object into a form that is usable by \code{run_model()}
#'
#' @param params the current `params` object used to model the data
#'
#' @return a matrix of the parameters for the Systems Dynamics model
#'
#' @importFrom dplyr %>% bind_cols group_by mutate across select inner_join relocate
#' @importFrom purrr map_dfr map modify_at
#' @import rlang
get_model_params <- function(params) {

  p <- params$groups %>%
    map_dfr(~.x$conditions %>%
              map(modify_at, "treatments", ~tibble(treatment = names(.x), split = .x)) %>%
              map_dfr(bind_cols, .id = "condition") %>%
              group_by(.data$condition) %>%
              mutate(across(.data$pcnt, ~.x * .data$split / sum(.data$split))) %>%
              select(.data$condition, .data$treatment, .data$pcnt) %>%
              inner_join(params$treatments %>%
                           map_dfr(bind_cols, .id = "treatment"),
                         by = "treatment") %>%
              mutate(across(.data$decay, ~half_life_factor(.data$months, .x))) %>%
              select(-.data$months, -.data$demand),
        .id = "group") %>%
    rename(treat = .data$treat_pcnt) %>%
    relocate(.data$treat, .after = .data$pcnt) %>%
    as.data.frame()

  rownames <- paste(p$group, p$condition, p$treatment, sep = "|")
  p <- select(p, where(is.numeric))
  rownames(p) <- rownames

  p %>% as.matrix() %>% t()
}

#' Get Model Potential Functions
#'
#' Takes the current params and generates the functions that simulate when the populations enter the model
#'
#' @param params the current `params` object used to model the data
#'
#' @return a list of functions for each of the population groups
#'
#' @importFrom dplyr %>%
#' @importFrom purrr map
#' @importFrom stats approxfun
get_model_potential_functions <- function(params) {
  params$groups %>%
    map(~params$curves[[.x$curve]] * .x$size * .x$pcnt / 100) %>%
    map(approxfun, x = seq_len(24) - 1, rule = 2)
}

#' Run Single Model
#'
#' Run's the model for a single population group
#'
#' @param params the current `params` object used to model the data
#' @param groups a character vector of the population group to model
#' @param months an integer of the number of months to run the simulation for
#' @param sim_time a numeric for the time interval to run the model at, e.g. every 1/5th of a month
#'
#' @return the output of \code{run_model()} for the selected population group
#'
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