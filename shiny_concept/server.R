library(shiny)

shinyServer(function(input, output, session) {
  ###################
  ## CSV Outputs ####
  ###################

  params <- lift_dl(reactiveValues)(params_raw)

  population_groups <- lift_dl(reactiveValues)(population_groups_raw)

  treatment_appointments <- rep(3, length(treatment_types)) %>%
    set_names(treatment_types) %>%
    (lift_dl(reactiveValues))

  ################################
  ## Update Selectise Options ####
  ################################

  observe({
    updateSelectInput(session, "sliders_select", choices = names(params_raw))
    updateSelectInput(session, "popn_subgroup", choices = names(population_groups_raw))
    updateSelectInput(session, "subpopulation_curve", choices = names(curves[, -1]))
    updateSelectInput(session, "treatment_type", choices = treatment_types)
  })

  ## Population values change ####

  names(population_groups_raw[[1]]) %>%
    walk(function(x) {
      ix <- paste0("subpopulation_", x)
      observeEvent(input[[ix]], {
        if (req(input$popn_subgroup) %in% names(population_groups)) {
          population_groups[[input$popn_subgroup]][[x]] <- input[[ix]]
        }
      })
    })

  observeEvent(input$popn_subgroup, {
    updateNumericInput(session,
                       "subpopulation_size",
                       value = population_groups[[input$popn_subgroup]]$size)
    updateNumericInput(session,
                       "subpopulation_pcnt",
                       value = population_groups[[input$popn_subgroup]]$pcnt)
  })

  observeEvent(input$treatment_type, {
    updateSliderInput(session,
                      "treatment_appointments",
                      value = treatment_appointments[[input$treatment_type]])
  })

  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatment_types) {
      treatment_appointments[[input$treatment_type]] <- input$treatment_appointments
    }
  })

  ###############
  ## Sliders ####
  ###############

  sliders <- names(params_raw[[1]]) %>% .[. != "decay"]

  # when the sliders_select drop down is changed, set the values of the sliders from params
  observeEvent(input$sliders_select, {
    sliders %>%
      walk(~updateSliderInput(session,
                              paste0("slider_", .x),
                              value = params[[input$sliders_select]][[.x]]))
  })

  # when any of the sliders are changed, update the value in params
  sliders %>%
    walk(function(x) {
      input_name <- paste0("slider_", x)

      observeEvent(input[[input_name]], {
        if (req(input$sliders_select) %in% names(params)) {
          params[[input$sliders_select]][[x]] <- input[[input_name]]
        }
      })
  })

  #############
  ## Model ####
  #############

  get_model_params <- function(p) {
    matrix(unlist(p),
           nrow = length(p[[1]]),
           dimnames = list(names(p[[1]]),
                           names(p)))
  }

  get_model_potential_functions <- function(g) {
    g %>%
      map(~curves[[.x$curve]] * .x$size * .x$pcnt / 100) %>%
      map(approxfun, x = seq_len(24) - 1, rule = 2)
  }

  # Run model ----
  o <- reactive({
    # convert the reactive values params back to a matrix to use with the model
    m <- params %>% reactiveValuesToList() %>% get_model_params()

    g <- population_groups %>% reactiveValuesToList() %>% get_model_potential_functions()

    s <- seq(0, input$totalmonths - 1, by = 1 / 30)

    run_model(m, g, s)
  })


  run_model_fn <- function(params, population_groups, months) {
    m <- matrix(unlist(params),
                nrow  = length(params[[1]]),
                dimnames = list(names(params[[1]]),
                                names(params)))

    g <- population_groups %>%
      map(~curves[[.x$curve]] * .x$size * .x$pcnt / 100) %>%
      map(approxfun, x = seq_len(24) - 1, rule = 2)

    s <- seq(0, months - 1, by = 1 / 30)

    run_model(m, g, s)
  }

  appointments <- reactive({
    v <- reactiveValuesToList(treatment_appointments)
    tibble(treatment = names(v),
           average_monthly_appointments = flatten_dbl(v))
  })

  #############
  ## Plots ####
  #############

  output$pop_plot <- renderPlotly(ggplotly(pop_plot(o())))

  output$demand_plot <- renderPlotly( {
    ggplotly(demand_plot(o(), appointments()),
             tooltip = c("text"))
    })
})
