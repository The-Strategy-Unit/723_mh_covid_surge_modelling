library(shiny)

shinyServer(function(input, output, session) {

  models <- lift_dl(reactiveValues)(models)
  params <- lift_dl(reactiveValues)(params)


  # Update main select options ====

  observe({
    updateSelectInput(session, "popn_subgroup", choices = population_groups)
    updateSelectInput(session, "subpopulation_curve", choices = names(params$curves))
    updateSelectInput(session, "treatment_type", choices = treatments)
    updateSelectInput(session, "services", choices = treatments)
  })

  # params_population_groups ====

  # popn_subgroup (selectInput)
  observeEvent(input$popn_subgroup, {
    if (req(input$popn_subgroup) %in% population_groups) {
      vals <- names(params$groups[[input$popn_subgroup]]$conditions)
      updateSelectInput(session, "sliders_select_cond", choices = vals)

      px <- params$groups[[input$popn_subgroup]]
      updateNumericInput(session, "subpopulation_size", value = px$size)
      updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
      updateSliderInput(session, "subpopulation_curve", value = px$curve)

      removeUI("#div_slider_cond_pcnt > *", TRUE, TRUE)

      for (i in vals) {
        slider_name <- paste0("slider_cond_pcnt_", str_replace_all(i, " ", "_"))
        insertUI(
          "#div_slider_cond_pcnt",
          "beforeEnd",
          sliderInput(
            slider_name, label = i,
            value = px$conditions[[i]]$pcnt * 100,
            min = 0, max = 100, step = 0.01, post = "%"
          )
        )
      }
    }
  })

  # subpopulation_size (numericInput)
  observeEvent(input$subpopulation_size, {
    if (req(input$popn_subgroup) %in% population_groups) {
      params$groups[[input$popn_subgroup]]$size <- input$subpopulation_size
    }
  })

  # subpopulation_pcnt (numericInput)
  observeEvent(input$subpopulation_pcnt, {
    if (req(input$popn_subgroup) %in% population_groups) {
      params$groups[[input$popn_subgroup]]$pcnt <- input$subpopulation_pcnt
    }
  })

  # subpopulation_curve (selectInput)
  observeEvent(input$subpopulation_curve, {
    if (req(input$popn_subgroup) %in% population_groups) {
      params$groups[[input$popn_subgroup]]$curve <- input$subpopulation_curve
    }
  })

  # params_group_to_cond ====

  # sliders_select_cond (selectInput)
  observeEvent(input$sliders_select_cond, {
    if (req(input$popn_subgroup) %in% population_groups) {
      p <- params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]]

      updateSelectInput(session, "sliders_select_treat", choices = names(p$treatments))

      updateSliderInput(session, "slider_pcnt", value = p$pcnt * 100)
    }
  })

  # slider_pcnt (sliderInput)
  observeEvent(input$slider_pcnt, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)

    if (psg %in% population_groups) {
      v <- input$slider_pcnt / 100
      params$groups[[psg]]$conditions[[condition]]$pcnt <- v
    }
  })

  # params_cond_to_treat ====

  # sliders_select_treat (selectInput)
  observeEvent(input$sliders_select_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups) {
      v <- params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat * 100

      updateSliderInput(session, "slider_treat", value = v)
    }
  })

  # slider_treat (sliderInput)
  observeEvent(input$slider_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups) {
      v <- input$slider_treat / 100
      params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat <- v
    }
  })

  # params_demand ====

  # treatment_type (selectInput)
  observeEvent(input$treatment_type, {
    if (req(input$treatment_type) %in% treatments) {
      tx <- params$treatments[[input$treatment_type]]
      updateSliderInput(session, "treatment_appointments", value = tx$demand)
      updateSliderInput(session, "slider_success", value = tx$success * 100)
      updateSliderInput(session, "slider_tx_months", value = tx$months)
      updateSliderInput(session, "slider_decay", value = tx$decay * 100)
    }
  })

  # treatment_appointments (sliderInput)
  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$demand <- input$treatment_appointments
    }
  })

  # slider_success (sliderInput)
  observeEvent(input$slider_success, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$success <- input$slider_success / 100
    }
  })

  # slider_tx_months (sliderInput)
  observeEvent(input$slider_tx_months, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$months <- input$slider_tx_months
    }
  })

  # slider_decay (sliderInput)
  observeEvent(input$slider_decay, {
    if (req(input$treatment_type) %in% treatments) {
      params$treatments[[input$treatment_type]]$decay <- input$slider_decay / 100
    }
  })

  # download_params (downloadButton)
  output$downnload_params <- downloadHandler(
    "params.json",
    function(file) {
      js <- reactiveValuesToList(params) %>%
        toJSON(pretty = TRUE, auto_unbox = TRUE)

      writeLines(js, file)
    },
    "application/json"
  )

  # download_output (downloadButton)
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

  # Model ====

  model_output <- reactive({
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

  # Plots ====

  output$referrals_plot <- renderPlotly({
    df <- model_output() %>%
      filter(type == "new-referral",
             treatment == input$services) %>%
      group_by(time) %>%
      summarise_at("value", sum)

    if (nrow(df) < 1) return(NULL)
    referrals_plot(df)
  })

  output$demand_plot <- renderPlotly({
    df <- model_output() %>%
      filter(type == "treatment",
             treatment == input$services) %>%
      group_by(time, treatment) %>%
      summarise(across(value, sum), .groups = "drop") %>%
      inner_join(appointments(), by = "treatment") %>%
      mutate(no_appointments = value * average_monthly_appointments)

    if (nrow(df) < 1) return(NULL)
    demand_plot(df)
  })

  # Output boxes ====

  tribble(
    ~output_id,          ~value_type,     ~text,
    "total_referrals",   "new-referral",  "Total 'surge' referrals",
    "total_demand",      "treatment",     "Total additional demand per contact type",
    "total_newpatients", "new-treatment", "Total new patients in service"
  ) %>%
    pmap(function(output_id, value_type, text) {
      output[[output_id]] <- renderValueBox({
        value <- model_output() %>%
          filter(type == value_type,
                 treatment == input$services,
                 near(time, round(time))) %>%
          pull(value) %>%
          sum() %>%
          scales::comma()

        valueBox(value, text)
      })
    })

})
