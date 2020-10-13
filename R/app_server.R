#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>%
#' @importFrom purrr lift_dl
#' @noRd
app_server <- function(input, output, session) {

  params <- lift_dl(reactiveValues)(params)

  # Model ----

  model_output <- reactive({
    start_month <- min(params$demand[[1]]$month)

    params %>%
      run_model(sim_time) %>%
      get_model_output(start_month)
  })

  # Params Tab ----

  params_server("params_page", params, model_output)

  # Demand Tab ----

  demand_server("demand_page", params)

  # Results Tab ----

  results_server("results_page", params, model_output)

  # Surge Tabs ----

  # Surge subpopn tab
  surgetab_server("surge_subpopn", model_output, .data$group, "Subpopulation group")

  # Surge conditions tab
  surgetab_server("surge_condition", model_output, .data$condition, "Condition")

  # Surge service tab
  surgetab_server("surge_service", model_output, .data$treatment, "Treatment")

  # Treemap Tab ----

  treemap_server("treemap_page", params)

  # Graph Tab ----

  graph_server("graph_page", params, model_output)

}
