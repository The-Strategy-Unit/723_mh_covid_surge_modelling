#' Params Module
#'
#' A shiny module that renders all of the content for the params page.
#'
#' @name params_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params,model_output reactive objects passed in from the main server

#' @rdname params_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
params_ui <- function(id) {
  # population groups ====
  params_population_groups <- primary_box(
    title = "Population Groups",
    width = 12,
    selectInput(
      NS(id, "popn_subgroup"),
      "Choose subgroup",
      choices = NULL
    ),
    numericInput(
      NS(id, "subpopulation_size"),
      "Subpopulation Figure",
      value = NULL, step = 100
    ),
    sliderInput(
      NS(id, "subpopulation_pcnt"),
      "Susceptibility and Resilience adjustment (see help notes)",
      value = 100, min = 0, max = 100, step = 1,
      post = "%"
    ),
    textOutput(NS(id, "subpopulation_size_pcnt")),
    selectInput(
      NS(id, "subpopulation_curve"),
      "Choose scenario",
      choices = NULL
    ),
    plotlyOutput(
      NS(id, "subpopulation_curve_plot"),
      height = "100px"
    ),
    actionLink(
      NS(id, "population_group_help"),
      "",
      icon("question")
    )
  )

  # group to conditions ====
  params_group_to_cond <- primary_box(
    title = "Impacts on population sub-group",
    width = 12,
    g2c_ui("g2c"),
    actionLink(
      NS(id, "group_to_cond_params_help"),
      "",
      icon("question")
    )
  )

  # condition to treatments ====
  params_cond_to_treat <- primary_box(
    title = "Referral/Service flows for impacts",
    width = 12,
    c2t_ui("c2t"),
    actionLink(
      NS(id, "cond_to_treat_params_help"),
      "",
      icon("question")
    )
  )

  # demand ====
  params_demand <- primary_box(
    title = "Service variables",
    width = 12,
    selectInput(
      NS(id, "treatment_type"),
      "Treatment type",
      choices = NULL
    ),
    sliderInput(
      NS(id, "slider_treat_pcnt"),
      "Referrals typically receiving a service",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      NS(id, "slider_tx_months"),
      "Months in service (a)",
      min = 0, max = 24, value = 1, step = 0.1
    ),
    sliderInput(
      NS(id, "slider_decay"),
      "Percentage discharged by month (a)",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      NS(id, "slider_success"),
      "Percentage of patients recovering",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      NS(id, "treatment_appointments"),
      "Average contacts per person per month",
      min = 0, max = 10, step = .01, value = 0
    ),
    actionLink(
      NS(id, "treatment_params_help"),
      "",
      icon("question")
    )
  )

  # downloads ====
  params_downloads <- primary_box(
    title = "Download Parameters",
    width = 12,
    downloadButton(
      NS(id, "download_params"),
      "Download current parameters"
    )
  )

  fluidRow(
    column(3, params_population_groups),
    column(3, params_group_to_cond),
    column(3, params_cond_to_treat),
    column(3, params_demand, params_downloads)
  )
}

#' @rdname params_module
#' @import shiny
#' @importFrom shinyjs disabled
#' @importFrom dplyr %>%
#' @importFrom purrr walk discard map_dbl map iwalk
#' @importFrom jsonlite read_json
#' @importFrom utils write.csv
#' @importFrom shinyWidgets ask_confirmation
#' @importFrom plotly renderPlotly
#'
#' @return a list of reactives
params_server <- function(id, params, model_output) {
  stopifnot("params must be a reactive values" = is.reactivevalues(params),
            "model_output must be a reactive" = is.reactive(model_output))

  counter <- methods::new("Counter")

  redraw_groups <- reactiveVal()
  redraw_treatments <- reactiveVal()
  redraw_g2c <- reactiveVal()
  redraw_c2t <- reactiveVal()

  popn_subgroup <- reactiveVal()
  conditions <- reactiveVal()

  g2c_server("g2c", params, redraw_g2c, redraw_c2t, counter, popn_subgroup)
  c2t_server("c2t", params, redraw_c2t, counter, popn_subgroup, conditions)

  upload_event <- reactiveValues(
    counter = 0,
    success = FALSE,
    msg = ""
  )
  params_file_path <- reactiveVal()

  moduleServer(id, function(input, output, session) {

    observeEvent(params_file_path(), {
      # if the treatment selected is the first one, and this is replaced, the values don't update correctly
      u <- counter$get()

      path <- req(params_file_path())

      tryCatch({
        new_params <- extract_params_from_excel(path)

        upload_event$success <- TRUE
        upload_event$msg <- "Success"

        params$groups <- new_params$groups
        params$treatments <- new_params$treatments
        params$curves <- new_params$curves
        params$demand <- new_params$demand

        redraw_treatments(u)
        redraw_groups(u)

        updateSelectInput(session, "popn_subgroup", choices = names(new_params$groups))
        updateSelectInput(session,
                          "subpopulation_curve",
                          choices = names(new_params$curves),
                          selected = new_params$groups[[1]]$curve)
        updateSelectInput(session, "treatment_type", choices = names(new_params$treatments))
      }, error = function(e) {
        upload_event$success <- FALSE
        upload_event$msg <- e$message
      })
      upload_event$counter <- u
    })

    # population groups ====

    observeEvent(input$popn_subgroup, {
      req(input$popn_subgroup)
      popn_subgroup(input$popn_subgroup)
      redraw_groups(counter$get())
    })

    observeEvent(redraw_groups(), {
      sg <- req(isolate(input$popn_subgroup))
      px <- isolate(params)$groups[[sg]]
      conditions(names(px$conditions))

      updateNumericInput(session, "subpopulation_size", value = px$size)
      updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
      updateSliderInput(session, "subpopulation_curve", value = px$curve)

      redraw_g2c(counter$get())
    })

    observeEvent(input$subpopulation_size, {
      sg <- req(input$popn_subgroup)
      params$groups[[sg]]$size <- input$subpopulation_size
    })

    # subpopulation_pcnt (numericInput)
    observeEvent(input$subpopulation_pcnt, {
      sg <- req(input$popn_subgroup)
      params$groups[[sg]]$pcnt <- input$subpopulation_pcnt
    })

    # subpopulation_size_pcnt (textOutput)
    output$subpopulation_size_pcnt <- renderText({
      paste0("Modelled population: ", comma(input$subpopulation_size * input$subpopulation_pcnt / 100))
    })

    # subpopulation_curve (selectInput)
    observeEvent(input$subpopulation_curve, {
      sg <- req(input$popn_subgroup)
      params$groups[[sg]]$curve <- input$subpopulation_curve
    })

    # subpopulation_curve_plot (plotlyOutput)
    output$subpopulation_curve_plot <- renderPlotly({
      subpopulation_curve_plot(params$curves[[input$subpopulation_curve]],
                               input$subpopulation_size,
                               input$subpopulation_pcnt)
    })

    # group to conditions ====
      # handled in module_g2c.R

    # condition to treatments ====
      # handled in module_c2t.R

    # demand ====

    observeEvent(input$treatment_type, {
      redraw_treatments(counter$get())
    })

    observeEvent(redraw_treatments(), {
      # resolves issue #90: if a new params file is uploaded, and the first treatment is renamed, then the value of
      # input$treatment_type will be the first value from the old params file. This handles this issue by skipping this
      # section (redraw_treatments() is called again and this code succeeds then)
      if (req(input$treatment_type) %in% names(params$treatments)) {
        tx <- params$treatments[[input$treatment_type]]
        updateSliderInput(session, "treatment_appointments", value = tx$demand)
        updateSliderInput(session, "slider_success", value = tx$success * 100)
        updateSliderInput(session, "slider_tx_months", value = tx$months)
        updateSliderInput(session, "slider_decay", value = tx$decay * 100)
        updateSliderInput(session, "slider_treat_pcnt", value = tx$treat_pcnt * 100)
      }
    })

    observeEvent(input$treatment_appointments, {
      ttype <- req(input$treatment_type)
      params$treatments[[ttype]]$demand <- input$treatment_appointments
    })

    observeEvent(input$slider_success, {
      ttype <- req(input$treatment_type)
      params$treatments[[ttype]]$success <- input$slider_success / 100
    })

    observeEvent(input$slider_tx_months, {
      ttype <- req(input$treatment_type)
      params$treatments[[ttype]]$months <- input$slider_tx_months
    })

    observeEvent(input$slider_decay, {
      ttype <- req(input$treatment_type)
      params$treatments[[ttype]]$decay <- input$slider_decay / 100
    })

    observeEvent(input$slider_treat_pcnt, {
      ttype <- req(input$treatment_type)
      params$treatments[[ttype]]$treat_pcnt <- input$slider_treat_pcnt / 100
    })

    # downloads ====

    # download_params (downloadButton)
    output$download_params <- downloadHandler(
      "params.xlsx",
      function(file) {
        params_to_xlsx(params, file)
      }
    )

    # help ====

    # load in the params help file
    app_sys("app/data/params_help.json") %>%
      read_json(TRUE) %>%
      iwalk(function(data, input_name) {
        # extract the text field. each line of text is converted to a paragraph. if that paragraph starts with a ":",
        # then we put the text before the ":" in bold text, followed by the rest of the text.
        text <- data$text %>%
          strsplit(": ") %>%
          map(~if (length(.x) >= 2) {
            tags$p(tags$strong(.x[[1]]), paste(.x[-1], collapse = " "))
          } else {
            tags$p(.x)
          })

        # observe the event of the help button being pressed, and show an ask_confirmation
        observeEvent(input[[input_name]], {
          ask_confirmation(
            paste0(input_name, "_box"),
            data$title,
            tagList(text),
            "question",
            "ok",
            closeOnClickOutside = TRUE,
            showCloseButton = FALSE,
            html = TRUE
          )
        })
      })

    # return ====
    list(
      upload_event = upload_event,
      params_file_path = params_file_path
    )
  })
}
