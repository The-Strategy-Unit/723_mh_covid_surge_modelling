options(tidyverse.quiet = TRUE)

suppressPackageStartupMessages({
  library(magrittr)
  library(tidyverse)
  library(deSolve)
  library(patchwork)
  library(plotly, exclude = c("last_plot", "filter", "layout"))
  library(rlang)
  library(shiny)
  library(shinyWidgets)
  library(shinycssloaders)
  library(shinydashboard)
  library(jsonlite, exclude = c("flatten", "validate"))
  library(packcircles)
  library(lubridate, exclude = c("intersect", "setdiff", "union"))
})
options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

sim_time <- as.numeric(Sys.getenv("SIM_TIME", 1 / 5))

params <- read_json("params.json", simplifyVector = TRUE) %>%
  modify_at("demand", as.list)

population_groups <- names(params$groups)
treatments <- names(params$treatments)

models <- params$groups %>%
  names() %>%
  set_names() %>%
  map(~run_single_model(params, .x, 24, sim_time))
