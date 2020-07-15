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
    updateSelectInput(session, "services", choices = treatments)
  })

  ## Condition and treatment pathway split ####

  observeEvent(input$popn_subgroup, {
    if (req(input$popn_subgroup) %in% population_groups) {
      vals <- names(params$groups[[input$popn_subgroup]]$conditions)
      updateSelectInput(session, "sliders_select_cond", choices = vals)

      px <- params$groups[[input$popn_subgroup]]
      updateNumericInput(session, "subpopulation_size", value = px$size)
      updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
      updateSliderInput(session, "subpopulation_curve", value = px$curve)
    }
  })

  observeEvent(input$sliders_select_cond, {
    if (req(input$popn_subgroup) %in% population_groups) {
      p <- params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]]

      updateSelectInput(session, "sliders_select_treat", choices = names(p$treatments))

      updateSliderInput(session, "slider_pcnt", value = p$pcnt * 100)
    }
  })

  observeEvent(input$treatment_type, {
    if (req(input$treatment_type) %in% treatments) {
      tx <- params$treatments[[input$treatment_type]]
      updateSliderInput(session, "treatment_appointments", value = tx$demand)
      updateSliderInput(session, "slider_success", value = tx$success * 100)
      updateSliderInput(session, "slider_tx_months", value = tx$months)
      updateSliderInput(session, "slider_decay", value = tx$decay * 100)
    }
  })

  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$demand <- input$treatment_appointments
    }
  })

  observeEvent(input$slider_success, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$success <- input$slider_success / 100
    }
  })

  observeEvent(input$slider_tx_months, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$months <- input$slider_tx_months
    }
  })

  observeEvent(input$slider_decay, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$decay <- input$slider_decay / 100
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

  observeEvent(input$treatment_type, {
    if (req(input$treatment_type) %in% treatments) {
      updateSliderInput(session, "treatment_appointments", value = params$treatments[[input$treatment_type]]$demand)
    }
  })

  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$demand <- input$treatment_appointments
    }
  })

  ###############
  ## Sliders ####
  ###############

  observeEvent(input$sliders_select_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups) {
      v <- params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat * 100

      updateSliderInput(session, "slider_treat", value = v)
    }
  })

  observeEvent(input$slider_pcnt, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)

    if (psg %in% population_groups) {
      v <- input$slider_pcnt / 100
      params$groups[[psg]]$conditions[[condition]]$pcnt <- v
    }
  })

  observeEvent(input$slider_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups) {
      v <- input$slider_treat / 100
      params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat <- v
    }
  })

  #############
  ## Model ####
  #############

  # Run model ----
  o <- reactive({
    # only run current selected population group

    if (req(input$popn_subgroup) %in% population_groups) {
      px <- reactiveValuesToList(params)
      models[[input$popn_subgroup]] <- run_single_model(px, input$popn_subgroup, 24, sim_time)
    }

    # combine models
    bind_rows(reactiveValuesToList(models))
  })

  appointments <- reactive({
    reactiveValuesToList(params)$treatments %>%
      map_dfr(bind_cols, .id = "treatment") %>%
      transmute(treatment, average_monthly_appointments = demand)
  })

  demand <- reactive({
    model_data <- o()
    appointments <- appointments()
    df <- model_data %>%
      filter(type == "treatment",
             treatment == input$services) %>%
      group_by(time, treatment) %>%
      summarise(across(value, sum), .groups = "drop") %>%
      inner_join(appointments, by = "treatment") %>%
      mutate(no_appointments = value * average_monthly_appointments)
  })

  #############
  ## Plots ####
  #############

  output$referrals_plot <- renderPlotly({
    df <- o() %>%
      filter(type == "new-referral",
             treatment == input$services) %>%
      group_by(time) %>%
      summarise_at("value", sum)

    if (nrow(df) < 1) return(NULL)

    referrals_plot(df)
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

  ## Testing ####

  extract_total_value <- function(what_total) {
    o() %>%
      filter(type == what_total,
             treatment == input$services,
             near(time, round(time))) %>%
      pull(value) %>%
      sum() %>%
      scales::comma()
  }

  output$total_referrals <- renderValueBox({
    valueBox(extract_total_value("new-referral"),
      "Total 'surge' referrals"
    )
  })

  output$total_demand <- renderValueBox({
    valueBox(extract_total_value("treatment"),
    "Total additional demand per contact type"
    )
  })

  output$total_newpatients <- renderValueBox({
    valueBox(extract_total_value("new-treatment"),
             "Total new patients in service"
    )
  })

})
