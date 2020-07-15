library(magrittr)
library(tidyverse)
library(readxl)
library(glue)
library(jsonlite)

raw_data_path <- "params.xlsx"

raw_data <- excel_sheets(raw_data_path) %>%
  set_names() %>%
  map(read_excel, path = raw_data_path)

c2t <- raw_data$c2t %>%
  pivot_longer(is.numeric) %>%
  group_by(condition, treatment) %>%
  summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %>%
  summarise(treatments = map2(list(data), list(treatment), set_names), .groups = "drop")

g2c <- raw_data$g2c %>%
  mutate_at("pcnt", as.list) %>%
  inner_join(c2t, by = "condition") %>%
  pivot_longer(pcnt:treatments) %>%
  group_by(group, condition) %>%
  summarise(data = map2(list(value), list(name), set_names), .groups = "drop_last") %>%
  summarise(conditions = map2(list(data), list(condition), set_names), .groups = "drop") %>%
  inner_join(raw_data$groups, by = "group") %>%
  select(group, size, pcnt, curve, conditions) %>%
  mutate_at(vars(-group), as.list) %>%
  pivot_longer(-group) %>%
  group_by(group) %>%
  summarise(data = map2(list(value), list(name), set_names), .groups = "drop") %$%
  set_names(data, group)

params <- list(
  groups = g2c,
  treatments = raw_data$treatments %>%
    pivot_longer(is.numeric) %>%
    group_by(treatment) %>%
    summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %$%
    set_names(data, treatment),
  curves = raw_data$curves %>%
    select(-month) %>%
    pivot_longer(everything()) %>%
    group_by(name) %>%
    summarise_at("value", list) %$%
    set_names(value, name)
)

params %>%
  write_json("shiny_app/params.json", pretty = TRUE, auto_unbox = TRUE)
