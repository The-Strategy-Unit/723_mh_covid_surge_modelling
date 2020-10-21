#' Home Module
#'
#' A shiny module that renders all of the content for the home page.
#'
#' @name home_module
#'
#' @param id An ID string that uniquely identifies an instance of this module

#' @rdname home_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
home_ui <- function(id) {
  tagList(
    tags$h1("Mental Health Surge Modelling"),
    tags$p(
      "A description of the application..."
    )
  )
}

home_server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}
