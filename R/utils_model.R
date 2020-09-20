#' Run Model
#'
#' Performs the Systems Dynamics modelling on the given parameter values.
#'
#' @param params the current `params` object used to model the data
#' @param months an integer of the number of months to run the simulation for
#' @param sim_time a numeric for the time interval to run the model at, e.g. every 1/5th of a month
#'
#' @return a tibble of the results of running the model
#'
#' @importFrom purrr set_names map_chr map_dbl map map_dfr
#' @importFrom deSolve ode
#' @importFrom dplyr %>% rename_with all_of tibble as_tibble relocate select inner_join
#' @importFrom tidyr pivot_longer unite
run_model <- function(params, months, sim_time) {

  model_params <- get_model_params(params)
  potential_functions <- get_model_potential_functions(params)

  # ensure model_params are ordered
  model_params <- model_params[, sort(colnames(model_params))]
  # update decay values: the values are currently expressed as log values, so we need to exponentiate these values.
  # we also need to take the complement so we get the amount that move from a->b at each time period
  model_params["decay", ] <- 1 - exp(model_params["decay", ])

  # get the names of the treatments from the model_params matrix column names
  treatments <- colnames(model_params)

  # get the names of the initial groups from the start of the treatment names
  all_initials <- treatments %>%
    strsplit("\\|") %>%
    map_chr(1)
  initials <- unique(all_initials)

  # reorders the potential_functions object to be same order as the initials
  potential_functions <- potential_functions[initials]

  # set up the stocks for the no mh needs group, each of the initial groups, and each of the stocks
  stocks <- c("no-mh-needs", initials, treatments) %>%
    set_names() %>%
    map_dbl(~0)

  # create a matrix that can take the initial group stocks and create a matrix that matches the treatment stocks.
  # each initial group is a column in the matrix
  initial_treatment_map <- all_initials %>%
    map(~as.numeric(.x == initials)) %>%
    flatten_dbl() %>%
    matrix(ncol = length(initials), byrow = TRUE)

  # verify that there is a potential_functions function for each of the initial groups
  stopifnot("potential_functions length does not match initials length" =
              length(potential_functions) == length(initials))

  stopifnot("potential_functions does not match initials" =
              all(names(potential_functions) == initials))

  model <- function(time, stocks, model_params, initials, treatments, potential_functions, initial_treatment_map) {
    # get each of the new potentials for each of the initial groups
    f_new_potential <- map_dbl(potential_functions, ~.x(time))

    # expand the initials stocks for each of the treatments
    initials_matrix <- initial_treatment_map %*% matrix(stocks[initials], ncol = 1)

    # flow from initial groups to treatments
    f_referrals <- initials_matrix[, 1] * model_params["pcnt", ]
    f_pot_treat <- f_referrals * model_params["treat", ]
    # flow from initial groups to no needs
    f_no_needs  <- stocks[initials] * (1 - matrix(model_params["pcnt", ], nrow = 1) %*% initial_treatment_map)[1, ]

    # flow from treatment groups back to initials
    f_treat_pot      <- stocks[treatments] * (1 - model_params["success", ]) * model_params["decay", ]
    # flow from treatment groups to no further mh needs
    f_treat_no_needs <- stocks[treatments] * (0 + model_params["success", ]) * model_params["decay", ]

    # convert the flows from treatment groups to be based on initial stocks, not treatment stocks
    f_pot_treat_initials <- (matrix(f_pot_treat, nrow = 1) %*% initial_treatment_map)[1, ]
    f_treat_pot_initials <- (matrix(f_treat_pot, nrow = 1) %*% initial_treatment_map)[1, ]

    # add the flow of new-at-risk to the output
    names(f_new_potential) <- paste0("new-at-risk|", names(f_new_potential))
    # add the flow of new-referral to the output
    names(f_referrals) <- paste0("new-referral|", names(f_referrals))
    # add the flow of new-treatments to the output
    names(f_pot_treat) <- paste0("new-treatment|", names(f_pot_treat))

    # calculate the changes to each of the stocks
    c(list(c(sum(f_no_needs) + sum(f_treat_no_needs),
             f_new_potential + f_treat_pot_initials - f_pot_treat_initials - f_no_needs,
             f_pot_treat - f_treat_pot - f_treat_no_needs)),
      f_new_potential,
      f_referrals,
      f_pot_treat)
  }

  # run the model and return the results in a long tidy format
  res <- ode(stocks,
             seq(0, months - 1, sim_time),
             model,
             model_params,
             "euler",
             initials = initials,
             treatments = treatments,
             potential_functions = potential_functions,
             initial_treatment_map = initial_treatment_map) %>%
    as.data.frame() %>%
    as_tibble() %>%
    rename_with(~paste0("at-risk|", .x), .cols = all_of(initials)) %>%
    rename_with(~paste0("treatment|", .x), .cols = all_of(treatments)) %>%
    pivot_longer(-.data$time)

  # this is SIGNIFICANTLY quicker than using separate
  cols <- unique(res$name) %>%
    strsplit("\\|") %>%
    map(as.list) %>%
    map_dfr(~set_names(.x, c("type", "group", "condition", "treatment")[seq_along(.x)])) %>%
    unite("name",
          .data$type,
          .data$group,
          .data$condition,
          .data$treatment, sep = "|", remove = FALSE, na.rm = TRUE)

  res %>%
    inner_join(cols, by = "name") %>%
    relocate(.data$value, .after = everything()) %>%
    select(-.data$name)
}
