#' Results Module
#'
#' A shiny module that renders all of the content for the results page.
#'
#' @name results_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param model_output,params reactive objects passed in from the main server

#' @rdname results_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
results_ui <- function(id) {
  results_services <- primary_box(
    title = "Service",
    width = 2,
    selectInput(
      NS(id, "services"),
      "Service",
      choices = NULL
    ),
    radioButtons(
      NS(id, "download_choice"),
      "Download option",
      c("Selected" = "selected", "All" = "all"),
      inline = TRUE
    ),
    downloadButton(NS(id, "download_results"))
  )

  results_value_boxes <- primary_box(
    title = "Summary",
    width = 5,
    valueBoxOutput(NS(id, "total_referrals")),
    valueBoxOutput(NS(id, "total_demand")),
    valueBoxOutput(NS(id, "total_newpatients"))
  )

  results_popgroups <- primary_box(
    title = "Population group source of 'surge'",
    width = 5,
    withSpinner(
      plotlyOutput(
        NS(id, "results_popgroups")
      )
    )
  )

  results_referrals_plot <- primary_box(
    title = "Modelled referrals",
    withSpinner(
      plotlyOutput(
        NS(id, "referrals_plot")
      )
    )
  )

  results_demand_plot <- primary_box(
    title = "Modelled demand",
    withSpinner(
      plotlyOutput(
        NS(id, "demand_plot")
      )
    )
  )

  results_combined_plot <- primary_box(
    title = "Combined modelled and projected referrals to service",
    withSpinner(
      plotlyOutput(
        NS(id, "combined_plot"),
        height = "600px"
      )
    ),
    width = 12
  )

  results_graph <- primary_box(
    title = "Flows from population groups to conditions to service",
    withSpinner(
      plotlyOutput(
        NS(id, "graph"),
        height = "600px"
      )
    ),
    width = 12
  )

  tagList(
    fluidRow(
      results_services,
      results_value_boxes,
      results_popgroups
    ),
    fluidRow(
      results_referrals_plot,
      results_demand_plot,
      results_combined_plot,
      results_graph
    )
  )
}

#' @rdname results_module
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% tribble
#' @importFrom purrr pmap
results_server <- function(id, params, model_output) {
  moduleServer(id, function(input, output, session) {
    stopifnot("params must be a reactive values" = is.reactivevalues(params),
              "model_output must be a reactive" = is.reactive(model_output))

    appointments <- reactive({
      params %>%
        reactiveValuesToList() %>%
        get_appointments()
    })

    treatments <- reactive({
      names(params$treatments)
    })

    observe({
      updateSelectInput(session, "services", choices = treatments())
    })

    output$referrals_plot <- renderPlotly({
      referrals_plot(model_output(), input$services)
    })

    output$demand_plot <- renderPlotly({
      demand_plot(model_output(), appointments(), input$services)
    })

    output$graph <- renderPlotly({
      create_graph(model_output(), treatments = input$services)
    })

    output$combined_plot <- renderPlotly({
      combined_plot(model_output(), input$services, reactiveValuesToList(params))
    })

    # Output boxes

    tribble(
      ~output_id,          ~value_type,     ~text,
      "total_referrals",   "new-referral",  "Total 'surge' referrals",
      "total_demand",      "treatment",     "Total additional demand per contact type",
      "total_newpatients", "new-treatment", "Total new patients in service"
    ) %>%
      pmap(function(output_id, value_type, text) {
        output[[output_id]] <- renderValueBox({
          value <- model_output() %>%
            model_totals(value_type, input$services)

          valueBox(value, text)
        })
      })

    output$results_popgroups <- renderPlotly({
      popgroups_plot(model_output(), input$services)
    })

    download_report_services <- reactive({
      if (input$download_choice == "all") {
        names(params$treatments)
      } else {
        input$services
      }
    })

    output$download_results <- downloadHandler(
      filename = "report.pdf",
      content = download_report(model_output(),
                                reactiveValuesToList(params),
                                download_report_services())
    )
  })
}
