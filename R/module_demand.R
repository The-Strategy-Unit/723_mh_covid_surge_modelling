#' Demand Module
#'
#' A shiny module that renders all of the content for the demand page.
#'
#' @name demand_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params reactive object passed in from the main server

#' @rdname demand_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
demand_ui <- function(id) {
  # a drop down for the service
  # a line per month with the following:
  # - underlying demand numeric input
  # - surpressed demand numeric input

  tagList(
    fluidRow(
      selectInput(NS(id, "service"), "Service", NULL),
      primary_box(
        title = "Demand",
        div(id = "demand-data"),
        width = 12
      )
    )
  )
}

#' @rdname results_module
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% mutate
#' @importFrom purrr walk pwalk
demand_server <-  function(id, params) {
  moduleServer(id, function(input, output, session) {
    # need to be able to hook into upload event from params
    services <- reactive_changes(names(params$demand))

    observeEvent(services, {
      updateSelectInput(session, "service", choices = names(params$demand))
    })

    demand_observables <- list()

    observeEvent(input$service, {
      # update the demand-data div
      demand <- params$demand[[input$service]]

      req(demand)

      walk(demand_observables, ~.x$destroy())
      demand_observables <<- list()
      removeUI("#demand-data > *", TRUE, TRUE)

      demand %>%
        mutate(month_ix = row_number()) %>%
        pwalk(function(month, underlying, suppressed, month_ix) {
          month_fmt <- format(month, "%b-%y")

          m_text <- div(style="display: inline-block;vertical-align:top; width: 25%;",
                        month_fmt)

          u_name <- paste0(month_fmt, "-underlying")
          u_input <- div(style="display: inline-block;vertical-align:top; width: 25%;",
                         numericInput(NS(id, u_name), NULL, underlying, min = 0, step = 1))

          s_name <- paste0(month_fmt, "-suppressed")
          s_input <- div(style="display: inline-block;vertical-align:top; width: 25%;",
                         numericInput(NS(id, s_name), NULL, suppressed, min = 0, step = 1))

          demand_row <- fluidRow(m_text, u_input, s_input)
          insertUI("#demand-data", "beforeEnd", demand_row)

          demand_observables[[u_name]] <<- observeEvent(input[[u_name]], {
            params$demand[[input$service]]$underlying[[month_ix]] <- input[[u_name]]
          })

          demand_observables[[s_name]] <<- observeEvent(input[[s_name]], {
            params$demand[[input$service]]$suppressed[[month_ix]] <- input[[s_name]]
          })

        })
    })
  })
}
