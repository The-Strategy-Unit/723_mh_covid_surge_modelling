library(tidyverse)
library(readxl)
library(glue)

raw_data_path <- "params.xlsx"

raw_data <- excel_sheets(raw_data_path) %>%
  set_names() %>%
  map(read_excel, path = raw_data_path)

new_params <- raw_data$g2c %>%
  full_join(raw_data$c2t, by = "condition") %>%
  full_join(raw_data$treatments, by = "treatment") %>%
  transmute(group, condition, treatment, pcnt = pcnt.x * pcnt.y, treat, success, months, decay) %>%
  drop_na() %>%
  pivot_longer(pcnt:decay) %>%
  group_by(group, condition, treatment) %>%
  summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %>%
  summarise(data = map2(list(data), list(treatment), set_names), .groups = "drop_last") %>%
  summarise(conditions = map2(list(data), list(condition), set_names), .groups = "drop_last")

list(
  groups = raw_data$groups %>%
    group_by(group) %>%
    summarise_all(as.list) %>%
    pivot_longer(-group) %>%
    group_by(group) %>%
    summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %>%
    inner_join(new_params, by = "group") %>%
    mutate(data = map2(data, conditions, ~c(.x, list(conditions = .y)))) %$%
    set_names(data, group),
  demand = set_names(raw_data$treatments$demand, raw_data$treatments$treatment) %>% as.list()
) %>%
  write_json("shiny_concept/params.json", pretty = TRUE, auto_unbox = TRUE)
