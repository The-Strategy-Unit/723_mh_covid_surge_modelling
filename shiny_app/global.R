options(tidyverse.quiet = TRUE,
        scipen = 999)

# PUT ALL LIBRARY CALLS IN THIS SCRIPT
source("00_library.R")

source("half_life_factor.R")
source("run_model.R")
source("plots.R")
source("extract_params_from_excel.R")
source("params_to_xlsx.R")
source("helper_functions.R")

sim_time <- as.numeric(Sys.getenv("SIM_TIME", 1 / 5))

params <- read_json("params.json", simplifyVector = TRUE) %>%
  modify_at("demand", as.list)

population_groups <- names(params$groups)
get_all_conditions <- function(params) {
  params$groups %>%
    map("conditions") %>%
    map(names) %>%
    unname() %>%
    flatten_chr() %>%
    unique() %>%
    sort()
}
treatments <- names(params$treatments)

models <- params$groups %>%
  names() %>%
  set_names() %>%
  map(~run_single_model(params, .x, 24, sim_time))
