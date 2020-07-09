options(tidyverse.quiet = TRUE)
library(magrittr,        quietly = TRUE, include.only = "%$%")
library(tidyverse,       quietly = TRUE)
library(deSolve,         quietly = TRUE)
library(patchwork,       quietly = TRUE)
library(plotly,          quietly = TRUE)
library(shinyWidgets,    quietly = TRUE)
library(shinycssloaders, quietly = TRUE)
library(jsonlite,        quietly = TRUE)

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

css_table <- "#contents {
font-size: 9px
}
"

curves <- read_csv("curves.csv", col_types = "ddddd") %>%
  modify_at(vars(-Month), ~.x / sum(.x))

params <- read_json("params.json")

population_groups <- names(params$groups)

conditions <- params$groups %>%
  map("conditions") %>%
  map(~map2(names(.x), map(.x, names), paste, sep = "-") %>% flatten_chr())

treatments <- names(params_raw$demand)

sliders <- names(params$groups[[1]]$conditions[[1]][[1]])[1:3]
