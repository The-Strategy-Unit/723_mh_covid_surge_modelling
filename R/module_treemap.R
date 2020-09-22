#' Treemap Module
#'
#' A shiny module that renders all of the content for the treemap page.
#'
#' @name treemap_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params reactive object passed in from the main server

#' @rdname treemap_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
treemap_ui <- function(id) {
  plotlyOutput(
    NS(id, "treemap_plot"),
    height = "900px"
  )
}

#' @rdname treemap_module
#' @import shiny
#' @import shinydashboard
#' @importFrom plotly renderPlotly
treemap_server <- function(id, params) {
  moduleServer(id, function(input, output, session) {
    stopifnot("params must be a reactive values" = is.reactivevalues(params))

    output$treemap_plot <- renderPlotly({
      treemap_plot(params)
    })
  })
}
