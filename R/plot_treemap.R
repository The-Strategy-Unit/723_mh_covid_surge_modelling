#' Treemap plot
#'
#' Creates a treemap of the population group sizes at baseline.
#'
#' @param params the current `params` object used to model the data
#'
#' @return a plotly chart
#'
#' @importFrom purrr map_dbl
#' @importFrom dplyr %>% left_join tribble mutate group_by summarise across bind_rows transmute
#' @importFrom tidyr fill
#' @import rlang
#' @importFrom plotly plot_ly config
treemap_plot <- function(params) {
  subpopn_to_level_2 <- tribble(
    ~subpopn,                         ~level_2,
    "Children & young people",        "Children & young people",
    "Students FE & HE",               NA,
    "Elderly alone",                  "Elderly alone",
    "General population",             "General population",
    "Domestic abuse victims",         "Other Adults and Specific Groups",
    "Family of COVID deceased",       NA,
    "Family of ICU survivors",        NA,
    "Newly unemployed",               NA,
    "Pregnant & New Mothers",         NA,
    "Parents",                        NA,
    "Health and care workers",        "Directly affected individuals",
    "ICU survivors",                  NA,
    "Learning disabilities & autism", "Existing Conditions",
    "Pre existing CMH illness",       NA,
    "Pre existing LTC",               NA,
    "Pre existing SMI",               NA
  ) %>%
    fill(.data$level_2) %>%
    # plotly treemap needs to have unique names between these levels
    mutate(across(.data$level_2, ~paste0("'", .x, "'")))

  params$groups %>%
    map_dbl("size") %>%
    (function(population_group_sizes) {
      tibble(
        subpopn = names(population_group_sizes),
        value = unname(population_group_sizes)
      )
    })() %>%
    left_join(subpopn_to_level_2, by = "subpopn") %>%
    (function(.x) {
      bind_rows(
        .x %>%
          mutate(label = .data$level_2) %>%
          group_by(.data$label) %>%
          summarise(across(.data$value, sum), parent = "", .groups = "drop"),
        transmute(.x, label = .data$subpopn, parent = .data$level_2, .data$value)
      )
    })() %>%
    group_by(.data$parent) %>%
    filter(dplyr::n() > 1) %>%
    plot_ly(labels = ~label,
            parents = ~parent,
            values = ~value,
            type = "treemap") %>%
    config(displayModeBar = FALSE)
}
