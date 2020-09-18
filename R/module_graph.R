#' Graph Module
#'
#' A shiny module that renders all of the content for the graph page.
#'
#' @name graph_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params,model_output reactive objects passed in from the main server

#' @rdname graph_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
graph_ui <- function(id) {
  graph_groups <- primary_box(
    title = "Filter Groups",
    width = 4,
    selectInput(
      NS(id, "graph_select_groups"),
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_conditions <- primary_box(
    title = "Filter Conditions",
    width = 4,
    selectInput(
      NS(id, "graph_select_conditions"),
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_services <- primary_box(
    title = "Filter Services",
    width = 4,
    selectInput(
      NS(id, "graph_select_treatments"),
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_plot <- primary_box(
    title = "Flows from population groups to conditions to services",
    width = 12,
    withSpinner(
      plotlyOutput(
        NS(id, "graph_plot"),
        height = "600px"
      )
    )
  )

  fluidRow(
    graph_groups,
    graph_conditions,
    graph_services,
    graph_plot
  )
}

#' @rdname graph_module
#' @import shiny
#' @importFrom plotly renderPlotly
graph_server <- function(id, params, model_output) {
  moduleServer(id, function(input, output, session) {
    stopifnot("params is not a reactiveValues" = is.reactivevalues(params),
              "model_output is not a reactive" = is.reactive(model_output))

    population_groups <- reactive({
      names(params$groups)
    })

    all_conditions <- reactive({
      get_all_conditions(params)
    })

    treatments <- reactive({
      names(params$treatments)
    })

    observe({
      updateSelectInput(session,
                        "graph_select_groups",
                        choices = population_groups(),
                        selected = population_groups())

      updateSelectInput(session,
                        "graph_select_conditions",
                        choices = all_conditions(),
                        selected = all_conditions())

      updateSelectInput(session,
                        "graph_select_treatments",
                        choices = treatments(),
                        selected = treatments())
    })

    output$graph_plot <- renderPlotly({
      create_graph(model_output(),
                   input$graph_select_groups,
                   input$graph_select_conditions,
                   input$graph_select_treatments)
    })
  })
}
