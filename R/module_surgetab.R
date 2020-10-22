#' Surge Tab Module
#'
#' A shiny module that renders all of the content of the surge tabs
#'
#' @name surgetab_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param model_output reactive object passed in from the main server
#' @param column a NSE column name to use to display
#' @param title the name to use to describe the column used


#' @rdname surgetab_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
surgetab_ui <- function(id) {
  fluidRow(
    primary_box(
      title = "Surge Table",
      width = 6,
      tableOutput(NS(id, "surge_table"))
    ),
    primary_box(
      title = "Surge Chart",
      width = 6,
      withSpinner(
        plotlyOutput(
          NS(id, "surge_plot"),
          height = "600px"
        )
      )
    )
  )
}

#' @rdname surgetab_module
#' @import shiny
#' @importFrom plotly renderPlotly
surgetab_server <- function(id, model_output, column, title) {
  moduleServer(id, function(input, output, session) {
    output$surge_table <- renderTable({
      surge_table(model_output(), {{column}}, title)
    })

    output$surge_plot <- renderPlotly({
      surge_plot(model_output(), {{column}})
    })
  })
}
