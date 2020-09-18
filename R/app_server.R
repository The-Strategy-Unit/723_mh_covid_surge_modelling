#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% select tibble tribble
#' @importFrom purrr map walk walk2 pmap map_dbl lift_dl modify_at set_names discard
#' @importFrom plotly renderPlotly
#' @importFrom utils write.csv
#' @importFrom shinyjs disabled
#' @noRd
app_server <- function(input, output, session) {

  params <- lift_dl(reactiveValues)(params)

  # Model ----

  model_output <- reactive({
    params %>%
      run_all_models(24, sim_time) %>%
      get_model_output()
  })

  # Params Tab ----

  params_server("params_page", params, model_output)

  # Results Tab ----

  results_server("results_page", model_output, params)

  # Surge Tabs ----

  # Surge subpopn tab
  surgetab_server("surge_subpopn", model_output, .data$group, "Subpopulation group")

  # Surge conditions tab
  surgetab_server("surge_condition", model_output, .data$condition, "Condition")

  # Surge service tab
  surgetab_server("surge_service", model_output, .data$treatment, "Treatment")

  # Bubble Plot Tab ----

  output$bubble_plot_baselinepopn <- renderPlotly({
    bubble_plot(params)
  })

  # Graph Tab ----

  graph_server("graph_page", params, model_output)

}
