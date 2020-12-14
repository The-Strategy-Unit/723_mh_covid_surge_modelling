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
#' @importFrom plotly renderPlotly
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
      c("Selected Service" = "selected", "All Services" = "all"),
      inline = TRUE
    ),
    downloadButton(
      NS(id, "download_report"),
      "Download report (.pdf)"
    ),
    tags$br(),
    tags$br(),
    downloadButton(
      NS(id, "download_output"),
      "Download model output (.csv)"
    )
  )

  results_value_boxes <- primary_box(
    title = "Summary",
    width = 5,
    id = "results_value_boxes",
    valueBoxOutput(NS(id, "total_referrals")),
    valueBoxOutput(NS(id, "total_demand")),
    valueBoxOutput(NS(id, "total_newpatients")),
    valueBoxOutput(NS(id, "pcnt_surgedemand")),
    tableOutput(NS(id, "pct_surgedemand_table")),
    textOutput(NS(id, "pcnt_surgedemand_note"))
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
    title = "Modelled referrals and treatments",
    withSpinner(
      plotlyOutput(
        NS(id, "referrals_plot")
      )
    )
  )

  results_demand_plot <- primary_box(
    title = "Modelled service contacts (demand)",
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
    actionLink(
      NS(id, "combined_help"),
      "",
      icon("question")
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
#' @importFrom lubridate year month
#' @importFrom dplyr %>% tribble
#' @importFrom purrr pmap
results_server <- function(id, params, model_output) {
  stopifnot("params must be a reactive values" = is.reactivevalues(params),
            "model_output must be a reactive" = is.reactive(model_output))

  moduleServer(id, function(input, output, session) {
    output$download_report <- downloadHandler(
      filename = if (input$download_choice == "all") {
        paste0(Sys.Date(), "_AllServices.pdf")
      } else {
        paste0(Sys.Date(), "_", gsub(" ", "", input$services, fixed = TRUE), ".pdf")
      },
      content = function(file) {
        model_output <- model_output()
        params <- reactiveValuesToList(params)
        services <- if (input$download_choice == "all") {
          names(params$treatments)
        } else {
          input$services
        }

        rmarkdown::render(
          app_sys("app/data/report.Rmd"),
          output_file = file,
          envir = current_env()
        )
      }
    )

    output$download_output <- downloadHandler(
      filename = function() paste0("model_run_", format(Sys.time(), "%Y-%m-%d_%H%M%S"), ".csv"),
      content = function(file) {
        download_output(model_output(), params) %>%
          write.csv(file, row.names = FALSE)
      },
      contentType = "text/csv"
    )

    appointments <- reactive({
      params %>%
        reactiveValuesToList() %>%
        get_appointments()
    })

    # ensure that if you alter some of the treatment params we only update the treatments list when a change to the
    # names of treatments occurs
    treatments <- reactive_changes(names(params$treatments))

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

    pcnt_surgedemand_denominator <- reactive({
      params$demand[[input$services]] %>%
        filter(.data$month < min(.data$month) %m+% months(12)) %>%
        pull("underlying") %>%
        sum()
    })

    output$pcnt_surgedemand <- renderValueBox({
      denominator <- pcnt_surgedemand_denominator()

      value <- if (denominator == 0) {
        "NA*"
      } else {
        numerator <- model_output() %>%
          filter(day(.data$date) == 1,
                 .data$type == "new-referral",
                 .data$treatment == input$services) %>%
          pull(.data$value) %>%
          sum()

        sprintf("%.1f%%", numerator / denominator * 100)
      }
      valueBox(value, "Cumulative surge demand")
    })

    output$pct_surgedemand_table <- renderTable({
      date_to_n_months <- function(d) {
        as.integer(year(d) * 12L + month(d))
      }
      denominator <- pcnt_surgedemand_denominator()

      value <- if (denominator == 0) {
        NULL
      } else {
        model_output() %>%
          filter(day(.data$date) == 1,
                 .data$type == "new-referral",
                 .data$treatment == input$services) %>%
          mutate(d1 = date_to_n_months(.data$date),
                 d2 = date_to_n_months(min(.data$date))) %>%
          group_by(Year = paste("Y", (.data$d1 - .data$d2) %/% 12L + 1)) %>%
          summarise(Surge = sprintf("%.1f%%", sum(.data$value) / denominator * 100))
      }
    })

    output$pcnt_surgedemand_note <- renderText({
      if (pcnt_surgedemand_denominator() == 0) {
        "* underlying demand data not available"
      } else {
        ""
      }
    })

    output$results_popgroups <- renderPlotly({
      popgroups_plot(model_output(), input$services)
    })

    help_popups("results") %>%
      iwalk(function(popup_fn, input_name) {
        observeEvent(input[[input_name]], popup_fn())
      })
  })
}
