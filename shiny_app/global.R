options(tidyverse.quiet = TRUE)
library(magrittr,        quietly = TRUE, include.only = "%$%")
library(tidyverse,       quietly = TRUE)
library(deSolve,         quietly = TRUE)
library(patchwork,       quietly = TRUE)
library(plotly,          quietly = TRUE, exclude = c("last_plot", "filter", "layout"))
library(shinyWidgets,    quietly = TRUE)
library(shinycssloaders, quietly = TRUE)
library(shinydashboard,  quietly = TRUE)
library(jsonlite,        quietly = TRUE, exclude = "flatten")
library(packcircles,     quietly = TRUE)

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

sim_time <- as.numeric(Sys.getenv("SIM_TIME", 1 / 5))

params <- read_json("params.json", simplifyVector = TRUE)

population_groups <- names(params$groups)
treatments <- names(params$treatments)

models <- params$groups %>%
  names() %>%
  set_names() %>%
  map(~run_single_model(params, .x, 24, sim_time))
