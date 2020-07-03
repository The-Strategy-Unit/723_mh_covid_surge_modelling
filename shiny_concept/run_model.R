
run_model <- function(params, new_potential, simtime = seq(0, 18, by = 1 / 30), long_output_format = TRUE) {
  # ensure params are ordered
  params <- params[, sort(colnames(params))]

  # get the names of the treatments from the params matrix column names
  treatments <- colnames(params)

  # get the names of the initial groups from the start of the treatment names
  initials <- treatments %>%
    str_extract("^([^_]+)(?=_)") %>%
    unique()

  # reorders the new_potential object to be same order as the initials
  new_potential <- new_potential[initials]

  # set up the stocks for the no mh needs group, each of the initial groups, and each of the stocks
  stocks <- c("no-mh-needs", initials, treatments) %>%
    purrr::set_names() %>% # ensure we are using the purrr version of this function
    map_dbl(~0)

  # create a matrix that can take the initial group stocks and create a matrix that matches the treatment stocks.
  # each initial group is a column in the matrix
  initial_treatment_map <- treatments %>%
    str_extract("([^_]+)(?=_)") %>%
    map(~as.numeric(.x == initials)) %>%
    flatten_dbl() %>%
    matrix(ncol = length(initials), byrow = TRUE)

  # verify that there is a new_potential function for each of the initial groups
  stopifnot("new_potential length does not match initials length" =
              length(new_potential) == length(initials))

  model <- function(time, stocks, params) {
    # get each of the new potentials for each of the initial groups
    f_new_potential <- map_dbl(new_potential, ~.x(time))

    # expand the initials stocks for each of the treatments
    initials_matrix <- initial_treatment_map %*% matrix(stocks[initials], ncol = 1)

    # flow from initial groups to treatments
    f_pot_treat <- initials_matrix[, 1] * params["pcnt", ] * params["treat", ]
    # flow from initial groups to no needs
    f_no_needs  <- stocks[initials] * (1 - matrix(params["pcnt", ], nrow = 1) %*% initial_treatment_map)[1, ]

    # flow from treatment groups back to initials
    f_treat_pot      <- stocks[treatments] * (1 - params["success", ]) * exp(params["decay", ])
    # flow from treatment groups to no further mh needs
    f_treat_no_needs <- stocks[treatments] * (0 + params["success", ]) * exp(params["decay", ])

    # convert the flows from treatment groups to be based on initial stocks, not treatment stocks
    f_pot_treat_initials <- (matrix(f_pot_treat, nrow = 1) %*% initial_treatment_map)[1, ]
    f_treat_pot_initials <- (matrix(f_treat_pot, nrow = 1) %*% initial_treatment_map)[1, ]

    # calculate the changes to each of the stocks
    list(c(sum(f_no_needs) + sum(f_treat_no_needs),
           f_new_potential + f_treat_pot_initials - f_pot_treat_initials - f_no_needs,
           f_pot_treat - f_treat_pot - f_treat_no_needs))
  }

  # run the model and return the results in a long tidy format
  o <- ode(stocks, simtime, model, params, "euler") %>%
    as.data.frame() %>%
    as_tibble() %>%
    rename_with(~paste0("at-risk_", .x), .cols = all_of(initials)) %>%
    rename_with(~paste0("treatment_", .x), .cols = all_of(treatments))

  if (long_output_format) {
    o <- o %>%
      pivot_longer(-time) %>%
      separate(name, c("type", "group", "treatment", "condition"), "\\_", fill = "right")
  }
  o
}
