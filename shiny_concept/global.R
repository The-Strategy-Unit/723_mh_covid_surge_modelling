options(tidyverse.quiet = TRUE)
library(tidyverse,    quietly = TRUE)
library(deSolve,      quietly = TRUE)
library(patchwork,    quietly = TRUE)
library(plotly,       quietly = TRUE)
library(shinyWidgets, quietly = TRUE)
library(magrittr,     quietly = TRUE, include.only = "%$%")
library(shinycssloaders, quietly = TRUE)

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

css_table <- "#contents {
font-size: 9px
}
"

params_raw <- read_csv("params.csv", col_types = "cccddddd") %>%
  mutate_at(vars(group:treatment), str_replace_all, "[ _]", "-") %>%
  arrange(group, condition, treatment) %>%
  unite(rowname, group:treatment, sep = "_", na.rm = TRUE) %>%
  mutate_at("decay", ~ half_life_factor(months, .x)) %>%
  select(-months) %>%
  group_nest(rowname) %$%
  set_names(data, rowname) %>%
  map(as.list)

population_groups_raw <- read_csv("population_groups.csv", col_types = "ccdd") %>%
  mutate_at(vars(group), str_replace_all, "[ _]", "-") %>%
  arrange(group) %>%
  group_nest(group) %$%
  set_names(data, group) %>%
  map(as.list)

curves <- read_csv("curves.csv", col_types = "ddddd") %>%
  modify_at(vars(-Month), ~.x / sum(.x))

treatment_types <- params_raw %>%
  names() %>%
  str_split("_") %>%
  map_chr(3) %>%
  unique() %>%
  sort()
