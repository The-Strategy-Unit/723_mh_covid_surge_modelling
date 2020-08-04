extract_params_from_excel <- function(raw_data_path) {
  raw_data <- excel_sheets(raw_data_path) %>%
    set_names() %>%
    map(read_excel, path = raw_data_path)

  # verify data ====

  verify_fn <- function(x, ...) nrow(filter(x, ...)) == 0

  stopifnot(
    "curves don't sum to 1" = raw_data$curves %>%
      pivot_longer(-month, names_to = "curve") %>%
      group_by(curve) %>%
      summarise_at("value", sum) %>%
      verify_fn(value != 1),
    "group percentages sum exceed 1" = raw_data$g2c %>%
      group_by(group) %>%
      summarise_at("pcnt", sum) %>%
      verify_fn(pcnt > 1),
    "group percentages not between 0 and 100" = raw_data$groups %>%
      verify_fn(pcnt < 0 | pcnt > 100),
    "g2c pcnt not between 0 and 1" = raw_data$g2c %>%
      verify_fn(pcnt < 0 | pcnt > 1),
    "c2t treat not between 0 and 1" = raw_data$c2t %>%
      verify_fn(treat < 0 | treat > 1),
    "treatments success not between 0 and 1" = raw_data$treatments %>%
      verify_fn(success < 0, success > 1),
    "treatments decay not between 0 and 1" = raw_data$treatments %>%
      verify_fn(decay < 0 | decay > 1),
    "unrecognised curve in groups" = raw_data$groups %>%
      anti_join(pivot_longer(raw_data$curves, -month, names_to = "curve"), by = "curve") %>%
      verify_fn(TRUE),
    "unrecongised group in g2c" = raw_data$g2c %>%
      anti_join(raw_data$groups, by = "group") %>%
      verify_fn(TRUE),
    "unrecognised condition in c2t" = raw_data$c2t %>%
      anti_join(raw_data$g2c, by = "condition") %>%
      verify_fn(TRUE),
    "unrecognised treatment in treatments" = raw_data$treatments %>%
      anti_join(raw_data$c2t, by = "treatment") %>%
      verify_fn(TRUE),
    "unmapped treatment in c2t" = raw_data$c2t %>%
      anti_join(raw_data$treatments, by = "treatment") %>%
      verify_fn(TRUE),
    "unmapped condition in g2c" = raw_data$g2c %>%
      anti_join(raw_data$c2t, by = "condition") %>%
      verify_fn(TRUE),
    "unmapped group in groups" = raw_data$groups %>%
      anti_join(raw_data$g2c, by = "group") %>%
      verify_fn(TRUE)
  )

  # produce json ====

  c2t <- raw_data$c2t %>%
    pivot_longer(where(is.numeric)) %>%
    group_by(group, condition, treatment) %>%
    summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %>%
    summarise(treatments = map2(list(data), list(treatment), set_names), .groups = "drop")

  g2c <- raw_data$g2c %>%
    mutate_at("pcnt", as.list) %>%
    inner_join(c2t, by = c("group", "condition")) %>%
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

  list(
    groups = g2c,
    treatments = raw_data$treatments %>%
      pivot_longer(where(is.numeric)) %>%
      group_by(treatment) %>%
      summarise(data = map2(list(value), list(name), compose(as.list, set_names)), .groups = "drop_last") %$%
      set_names(data, treatment),
    curves = raw_data$curves %>%
      select(-month) %>%
      pivot_longer(everything()) %>%
      group_by(name) %>%
      summarise_at("value", list) %$%
      set_names(value, name),
    demand = raw_data$demand %>%
      group_nest(service) %$%
      set_names(data, service)
  )
}

update_params_json <- function(params) {
  params %>%
    write_json("params.json", pretty = TRUE, auto_unbox = TRUE)
}
