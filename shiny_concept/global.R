options(tidyverse.quiet = TRUE)
library(magrittr,        quietly = TRUE, include.only = "%$%")
library(tidyverse,       quietly = TRUE)
library(deSolve,         quietly = TRUE)
library(patchwork,       quietly = TRUE)
library(plotly,          quietly = TRUE, exclude = c("last_plot", "filter", "layout"))
library(shinyWidgets,    quietly = TRUE)
library(shinycssloaders, quietly = TRUE)
library(jsonlite,        quietly = TRUE, exclude = "flatten")

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

css_table <- "#contents {
font-size: 9px
}
"

sim_time <- as.numeric(Sys.getenv("SIM_TIME", 1/5))

curves <- read_csv("curves.csv", col_types = "ddddd") %>%
  modify_at(vars(-Month), ~.x / sum(.x))

params <- read_json("params.json")

population_groups <- names(params$groups)

conditions <- params$groups %>%
  map("conditions") %>%
  # the data is stored as nested lists of condition$treatment, this pulls out the names of the outer list, then it gets
  # a list of all of the names from it's inner list. We then map over this pair of name and list of names, use paste to
  # get a combination of all of these, then we flatten the results.
  # this produces a named list per group of the condition-treatment names
  map(~map2(names(.x), map(.x, names), paste, sep = "-") %>% flatten_chr())

treatments <- names(params$demand)

# the sliders used in the model
sliders <- c("pcnt", "treat", "success")

group_variables <- c("curve", "size", "pcnt")

models <- params$groups %>%
  names() %>%
  set_names() %>%
  map(~run_single_model(params$groups[.x], 24, sim_time))
