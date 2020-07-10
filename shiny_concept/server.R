library(shiny)

shinyServer(function(input, output, session) {

  ###################
  ## CSV Outputs ####
  ###################

  models <- lift_dl(reactiveValues)(models)
  params <- lift_dl(reactiveValues)(params)

  ################################
  ## Update Selectise Options ####
  ################################

  observe({
    updateSelectInput(session, "popn_subgroup", choices = population_groups)
    updateSelectInput(session, "subpopulation_curve", choices = names(curves[, -1]))
    updateSelectInput(session, "treatment_type", choices = treatments)
    updateSelectInput(session, "demand_treatment_type", choices = treatments)
    updateSelectInput(session,
                      "popn_subgroup_plot",
                      choices = population_groups)
  })

  observeEvent(input$popn_subgroup, {
    if (req(input$popn_subgroup) %in% population_groups) {
      updateSelectInput(session, "popn_subgroup_plot", selected = input$popn_subgroup)
      updateSelectInput(session, "sliders_select", choices = conditions[[input$popn_subgroup]])
    }
  })

  ## Population values change ####

  group_variables %>%
    walk(function(x) {
      ix <- paste0("subpopulation_", x)
      observeEvent(input[[ix]], {
        if (req(input$popn_subgroup) %in% population_groups) {
          params$groups[[input$popn_subgroup]][[x]] <- input[[ix]]
        }
      })
    })

  observeEvent(input$popn_subgroup, {
    px <- params$groups[[input$popn_subgroup]]
    updateNumericInput(session, "subpopulation_size", value = px$size)
    updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
    updateSliderInput(session, "subpopulation_curve", value = px$curve)
  })

  observeEvent(input$treatment_type, {
    if (req(input$treatment_type) %in% treatments) {
      updateSliderInput(session, "treatment_appointments", value = params$demand[[input$treatment_type]])
    }
  })

  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatments) {
      params$demand[[input$treatment_type]] <- input$treatment_appointments
    }
  })

  observeEvent(input$demand_treatment_type, {
    if (req(input$demand_treatment_type) %in% treatments) {
      updateSliderInput(session, "demand_treatment_demand", value = params$demand[[input$demand_treatment_type]])
    }
  })

  observeEvent(input$demand_treatment_demand, {
    if (req(input$demand_treatment_type) %in% treatments) {
      params$demand[[input$demand_treatment_type]] <- input$demand_treatment_demand
    }
  })

  ###############
  ## Sliders ####
  ###############

  # when the sliders_select drop down is changed, set the values of the sliders from params
  observeEvent(input$sliders_select, {
    sliders %>%
      walk(function(.x) {
        psg <- req(input$popn_subgroup)
        iss <- req(input$sliders_select)

        if (psg %in% population_groups & iss %in% conditions[[psg]]) {
          condition <- str_remove(iss, "-.*$")
          treatment <- str_remove(iss, "^.*-")

          s <- paste0("slider_", .x)
          v <- params$groups[[psg]]$conditions[[condition]][[treatment]][[.x]]

          updateSliderInput(session, s, value = v)
        }
      })
  })

  # when any of the sliders are changed, update the value in params
  sliders %>%
    walk(function(.x) {
      s <- paste0("slider_", .x)

      observeEvent(input[[s]], {
        psg <- req(input$popn_subgroup)
        iss <- req(input$sliders_select)

        if (psg %in% population_groups & iss %in% conditions[[psg]]) {
          condition <- str_remove(iss, "-.*$")
          treatment <- str_remove(iss, "^.*-")

          v <- input[[s]]

          params$groups[[psg]]$conditions[[condition]][[treatment]][[.x]] <- v
        }
      })
    })

  #############
  ## Model ####
  #############

  # Run model ----
  o <- reactive({
    # only run current selected population group

    if (req(input$popn_subgroup) %in% population_groups) {
      px <- reactiveValuesToList(params)$groups
      models[[input$popn_subgroup]] <- run_single_model(px[input$popn_subgroup],
                                                        input$totalmonths,
                                                        SIM_TIME)
    }

    # combine models
    bind_rows(reactiveValuesToList(models))
  })

  o_filter <- reactive({
    o() %>% filter(group %in% input$popn_subgroup_plot)
  })

  appointments <- reactive({
    v <- reactiveValuesToList(params)$demand
    tibble(treatment = names(v),
           average_monthly_appointments = unlist(v))
  })

  demand <- reactive({
    model_data <- o()
    appointments <- appointments()
    df <- model_data %>%
      filter(type == "treatment") %>%
      group_by(time, treatment) %>%
      summarise(across(value, sum), .groups = "drop") %>%
      inner_join(appointments, by = "treatment") %>%
      mutate(no_appointments = value * average_monthly_appointments)
  })

  #############
  ## Plots ####
  #############

  output$pop_plot <- renderPlotly({
    o <- o_filter()

    if (nrow(o) < 1) return(NULL)

    p <- pop_plot(o)

    ggplotly(p, tooltip = c("text"))
  })

  output$demand_plot <- renderPlotly({
    d <- demand()

    if (nrow(d) < 1) return(NULL)

    p <- d %>%
      demand_plot()

    ggplotly(p, tooltip = c("text"))
  })

  output$demand_demand_plot <- renderPlotly({
    d <- demand() %>%
      filter(treatment == input$demand_treatment_type)

    if (nrow(d) < 1) return(NULL)

    p <- d %>%
      demand_plot() +
      theme(legend.position = "none")

    ggplotly(p, tooltip = c("text"))
  })

  output$demand_table <- renderTable(
    demand() %>%
      filter(treatment == input$demand_treatment_type,
             dplyr::near(time, round(time))) %>%
      select(month = time,
             referrals = value,
             demand = no_appointments),
    digits = 1
  )

  #######################
  ## Download Params ####
  #######################

  output$download_params <- downloadHandler(filename = "parameters.json", content = function(file) {
    writeLines(toJSON(reactiveValuesToList(params), pretty = TRUE, auto_unbox = TRUE), file)
  })

  ## Test ####

  output$o_print_test <- renderPrint(o())

})
