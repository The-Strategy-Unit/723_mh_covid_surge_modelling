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
    updateSelectInput(session, "subpopulation_curve", choices = names(params$curves))
    updateSelectInput(session, "treatment_type", choices = treatments)
    updateSelectInput(session, "demand_treatment_type", choices = treatments)
    updateSelectInput(session,
                      "popn_subgroup_plot",
                      choices = population_groups)
  })

  observeEvent(input$popn_subgroup, {
    if (req(input$popn_subgroup) %in% population_groups) {
      updateSelectInput(session, "popn_subgroup_plot", selected = input$popn_subgroup)
    }
  })

  ## Condition and treatment pathway split ####

  observeEvent(input$popn_subgroup, {
    if (req(input$popn_subgroup) %in% population_groups) {
      vals <- names(params$groups[[input$popn_subgroup]]$conditions)
      updateSelectInput(session, "sliders_select_cond", choices = vals)
    }
  })

  observeEvent(input$sliders_select_cond, {
    if (req(input$popn_subgroup) %in% population_groups) {
      vals <- names(params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]])
      updateSelectInput(session, "sliders_select_treat", choices = vals)
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
  observeEvent(input$sliders_select_treat, {
    sliders %>%
      walk(function(.x) {
        psg <- req(input$popn_subgroup)

        condition <- req(input$sliders_select_cond)
        treatment <- req(input$sliders_select_treat)

        if (psg %in% population_groups) {
          s <- paste0("slider_", .x)
          v <- params$groups[[psg]]$conditions[[condition]][[treatment]][[.x]] * 100

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
        condition <- req(input$sliders_select_cond)
        treatment <- req(input$sliders_select_treat)

        if (psg %in% population_groups) {
          v <- input[[s]]

          params$groups[[psg]]$conditions[[condition]][[treatment]][[.x]] <- v / 100
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
                                                        params$curves,
                                                        input$totalmonths,
                                                        sim_time)
    }

    # combine models
    bind_rows(reactiveValuesToList(models))
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
    df <- o() %>%
      filter(group %in% input$popn_subgroup_plot)

    if (nrow(df) < 1) return(NULL)

    pop_plot(df)
  })

  output$demand_plot <- renderPlotly({
    d <- demand()

    if (nrow(d) < 1) return(NULL)

    demand_plot(d)
  })

  output$download_output <- downloadHandler(
    paste0("model_run_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".csv"),
    function(file) {
      df <- o() %>%
        filter(near(time, round(time))) %>%
        group_by_at(vars(time:treatment)) %>%
        summarise_all(sum)

      bind_rows(
        df,
        # add the demand data
        df %>%
          filter(type == "treatment") %>%
          inner_join(appointments(), by = "treatment") %>%
          mutate(type = "demand",
                 value = value * average_monthly_appointments,
                 average_monthly_appointments = NULL)
      ) %>%
        write.csv(file, row.names = FALSE)
    },
    "text/csv"
  )
})
