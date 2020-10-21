#' Home Module
#'
#' A shiny module that renders all of the content for the home page.
#'
#' @name home_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params_file_path a reactiveVal that contains the path to the current params file

#' @rdname home_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
#' @importFrom dplyr %>%
#' @importFrom purrr set_names
home_ui <- function(id) {
  files <- app_sys("app/data") %>%
    dir("^params\\_.*\\.xlsx$", full.names = TRUE) %>%
    (function(f) {
      n <- f %>%
        gsub("^.*\\/params\\_(.*)\\.xlsx$", "\\1", .) %>%
        gsub("\\-", " ", .)
      f <- set_names(f, n)

      # reorder to make sure England is first
      c(f[n == "England"], sort(f[n != "England"]))
    })()

  tagList(
    tags$h1("Mental Health Surge Modelling"),
    tags$p(
      "A description of the application..."
    ),
    selectInput(
      NS(id, "default_params"),
      "Default Parameters",
      files
    )
  )
}

#' @rdname home_module
home_server <- function(id, params_file_path) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$default_params, {
      params_file_path(input$default_params)
    })
  })
}
