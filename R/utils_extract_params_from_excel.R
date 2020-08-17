#' @importFrom purrr set_names map map2 compose
#' @importFrom readxl excel_sheets read_excel
#' @importFrom dplyr %>% group_by summarise across anti_join select group_nest
#' @importFrom tidyr pivot_longer
#' @import rlang
extract_params_from_excel <- function(raw_data_path) {
  raw_data <- excel_sheets(raw_data_path) %>%
    set_names() %>%
    map(read_excel, path = raw_data_path)

  # verify data ====

  verify_fn <- function(x, ...) nrow(filter(x, ...)) == 0

  stopifnot(
    "curves don't sum to 1" = raw_data$curves %>%
      pivot_longer(-.data$month, names_to = "curve") %>%
      group_by(.data$curve) %>%
      summarise(across(.data$value, sum), .groups = "drop") %>%
      verify_fn(.data$value != 1),
    "group percentages sum exceed 1" = raw_data$g2c %>%
      group_by(.data$group) %>%
      summarise(across(.data$pcnt, sum), .groups = "drop") %>%
      verify_fn(.data$pcnt > 1),
    "group percentages not between 0 and 100" = raw_data$groups %>%
      verify_fn(.data$pcnt < 0 | .data$pcnt > 100),
    "g2c pcnt not between 0 and 1" = raw_data$g2c %>%
      verify_fn(.data$pcnt < 0 | .data$pcnt > 1),
    "c2t treat not between 0 and 1" = raw_data$c2t %>%
      verify_fn(.data$treat < 0 | .data$treat > 1),
    "treatments success not between 0 and 1" = raw_data$treatments %>%
      verify_fn(.data$success < 0, .data$success > 1),
    "treatments decay not between 0 and 1" = raw_data$treatments %>%
      verify_fn(.data$decay < 0 | .data$decay > 1),
    "unrecognised curve in groups" = raw_data$groups %>%
      anti_join(pivot_longer(raw_data$curves, -.data$month, names_to = "curve"), by = "curve") %>%
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
    group_by(.data$group, .data$condition, .data$treatment) %>%
    summarise(data = map2(list(.data$value),
                          list(.data$name),
                          compose(as.list, set_names)),
              .groups = "drop_last") %>%
    summarise(treatments = map2(list(.data$data),
                                list(.data$treatment),
                                set_names),
              .groups = "drop")

  g2c <- raw_data$g2c %>%
    mutate(across(.data$pcnt, as.list)) %>%
    inner_join(c2t, by = c("group", "condition")) %>%
    pivot_longer(where(is.list)) %>%
    group_by(.data$group, .data$condition) %>%
    summarise(data = map2(list(.data$value),
                          list(.data$name),
                          set_names),
              .groups = "drop_last") %>%
    summarise(conditions = map2(list(.data$data),
                                list(.data$condition),
                                set_names),
              .groups = "drop") %>%
    inner_join(raw_data$groups, by = "group") %>%
    select(.data$group, .data$size, .data$pcnt, .data$curve, .data$conditions) %>%
    mutate(across(-.data$group, as.list)) %>%
    pivot_longer(-.data$group) %>%
    group_by(.data$group) %>%
    summarise(data = map2(list(.data$value),
                          list(.data$name),
                          set_names),
              .groups = "drop")
  txs <- raw_data$treatments %>%
    pivot_longer(where(is.numeric)) %>%
    group_by(.data$treatment) %>%
    summarise(data = map2(list(.data$value),
                          list(.data$name),
                          compose(as.list, set_names)),
              .groups = "drop_last")

  curves <- raw_data$curves %>%
    select(-.data$month) %>%
    pivot_longer(everything()) %>%
    group_by(.data$name) %>%
    summarise(across(.data$value, list), .groups = "drop")

  demand <- raw_data$demand %>%
    group_nest(.data$service)

  list(
    groups = set_names(g2c$data, g2c$group),
    treatments = set_names(txs$data, txs$treatment),
    curves = set_names(curves$value, curves$name),
    demand = set_names(demand$data, demand$service)
  )
}

#' @importFrom dplyr %>%
#' @importFrom jsonlite write_json
update_params_json <- function(params) {
  params %>%
    write_json("params.json", pretty = TRUE, auto_unbox = TRUE)
}
