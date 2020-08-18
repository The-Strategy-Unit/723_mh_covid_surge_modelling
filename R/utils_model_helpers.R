
#' @importFrom dplyr %>% bind_cols group_by mutate across select inner_join
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
