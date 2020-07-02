library(shiny)

shinyServer(function(input, output, session) {
  ###################
  ## CSV Outputs ####
  ###################

  params <- lift_dl(reactiveValues)(params_raw)

  population_groups <- lift_dl(reactiveValues)(population_groups_raw)

  ################################
  ## Update Selectise Options ####
  ################################

  observe({
    updateSelectInput(session, "sliders_select", choices = names(params))
    updateSelectInput(session, "popn_subgroup", choices = names(population_groups_raw))
    updateSelectInput(session, "subpopulation_curve", choices = names(curves[, -1]))
  })

  ## Population values change ####

  c("size", "pcnt", "curve") %>%
    walk(function(x) {
      ix <- paste0("subpopulation_", x)
      observeEvent(input[[ix]], {
        req(input$popn_subgroup)
        if (input$popn_subgroup %in% names(population_groups)) {
          population_groups[[input$popn_subgroup]][[x]] <- input[[ix]]
        }
      })
    })

  observeEvent(input$popn_subgroup,{
    updateNumericInput(session,
                       "subpopulation_size",
                       value = population_groups[[input$popn_subgroup]]$size)
    updateNumericInput(session,
                       "subpopulation_pcnt",
                       value = population_groups[[input$popn_subgroup]]$pcnt)
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
        req(input$sliders_select)
        if (input$sliders_select %in% names(params)) {
          params[[input$sliders_select]][[x]] <- input[[input_name]]
        }
      })
  })

  #############
  ## Model ####
  #############

  # Run model ----
  o <- reactive({
    # convert the reactive values params back to a matrix to use with the model
    p <- reactiveValuesToList(params)

    m <- matrix(unlist(p),
                nrow = length(p[[1]]),
                dimnames = list(names(p[[1]]),
                                names(p)))

    g <- reactiveValuesToList(population_groups) %>%
      map(~curves[[.x$curve]] * .x$size * .x$pcnt / 100) %>%
      map(approxfun, x = seq_len(24) - 1, rule = 2)

    s <- seq(0, input$totalmonths-1, by = 1 / 30)

    run_model(m, g, s)
  })

  appointments <- reactive({
    c("cmht", "iapt", "psych-liason") %>%
      map_dfr(~list(treatment = .x,
                    average_monthly_appointments = input[[paste0(.x, "_appointments")]]))
  })

  #############
  ## Plots ####
  #############

  output$pop_plot <- renderPlotly(ggplotly(pop_plot(o())))

  output$demand_plot <- renderPlotly(ggplotly(demand_plot(o(), appointments()),
                                              tooltip = c("text")))

})
