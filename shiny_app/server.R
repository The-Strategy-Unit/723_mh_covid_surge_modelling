library(shiny)
library(uuid)

shinyServer(function(input, output, session) {

  ## needs to be after upload function

  population_groups <- reactiveVal(population_groups)
  curves <- reactiveVal(names(params$curves))
  treatments <- reactiveVal(treatments)

  models <- lift_dl(reactiveValues)(models)
  params <- lift_dl(reactiveValues)(params)

  param_uuid <- reactiveVal()

  ## New params

  observeEvent(input$user_upload_json, {
    new_params <- read_json(input$user_upload_json$datapath, simplifyVector = TRUE)

    params$groups <- new_params$groups
    params$treatments <- new_params$treatments
    params$curves <- new_params$curves

    population_groups(names(new_params$groups))
    treatments(names(new_params$treatments))
    curves(names(new_params$curves))

    param_uuid(UUIDgenerate())
  })

  # Update main select options ====

  observe({
    # trigger update of selects, even if the choices haven't changed
    force(param_uuid())

    updateSelectInput(session, "popn_subgroup", choices = population_groups())
    updateSelectInput(session, "subpopulation_curve", choices = curves())
    updateSelectInput(session, "treatment_type", choices = treatments())
    updateSelectInput(session, "services", choices = treatments())
  })

  # params_population_groups ====

  # popn_subgroup (selectInput)
  observe({
    # this is an observe rather than observeEvent on input$popn_subgroup in order to handle the case of a file being
    # uploaded, but the first value of population_groups() not changing and popn_subgroup having selected this first
    # value
    sg <- req(input$popn_subgroup)
    force(UUIDgenerate())

    conditions <- names(params$groups[[sg]]$conditions)
    updateSelectInput(session, "sliders_select_cond", choices = conditions)

    px <- params$groups[[sg]]
    updateNumericInput(session, "subpopulation_size", value = px$size)
    updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
    updateSliderInput(session, "subpopulation_curve", value = px$curve)

    # update the condition percentage sliders
    # first, remove the previous elements
    removeUI("#div_slider_cond_pcnt > *", TRUE, TRUE)
    # now, add the new sliders

    # get initial max values for the sliders
    mv <- map_dbl(px$conditions, "pcnt") %>% (function(x) x + 1 - sum(x)) * 100
    # loop over the conditions (and the corresponding max values)
    walk2(conditions, mv, function(i, mv) {
      # slider names can't have spaces, replace with _
      slider_name <- paste0("slider_cond_pcnt_", i) %>% str_replace_all(" ", "_")
      slider <- sliderInput(
        slider_name, label = i,
        value = px$conditions[[i]]$pcnt * 100,
        min = 0, max = mv, step = 0.01, post = "%"
      )
      insertUI("#div_slider_cond_pcnt", "beforeEnd", slider)

      observeEvent(input[[slider_name]], {
        # can't use the px element here: must use full params
        params$groups[[sg]]$conditions[[i]]$pcnt <- input[[slider_name]] / 100

        # update other sliders max values
        m <- 1 - params$groups[[sg]]$conditions %>% map_dbl("pcnt") %>% sum()
        walk(conditions, function(j) {
          v <- params$groups[[sg]]$conditions[[j]]$pcnt + m
          sn <- paste0("slider_cond_pcnt_", j) %>% str_replace_all(" ", "_")
          updateSliderInput(session, sn, max = v * 100)
        })
      })
    })
  })

  # subpopulation_size (numericInput)
  observeEvent(input$subpopulation_size, {
    if (req(input$popn_subgroup) %in% population_groups()) {
      params$groups[[input$popn_subgroup]]$size <- input$subpopulation_size
    }
  })

  # subpopulation_pcnt (numericInput)
  observeEvent(input$subpopulation_pcnt, {
    if (req(input$popn_subgroup) %in% population_groups()) {
      params$groups[[input$popn_subgroup]]$pcnt <- input$subpopulation_pcnt
    }
  })

  # subpopulation_curve (selectInput)
  observeEvent(input$subpopulation_curve, {
    if (req(input$popn_subgroup) %in% population_groups()) {
      params$groups[[input$popn_subgroup]]$curve <- input$subpopulation_curve
    }
  })

  # params_group_to_cond ====

  # sliders_select_cond (selectInput)
  observeEvent(input$sliders_select_cond, {
    if (req(input$popn_subgroup) %in% population_groups()) {
            # first, remove the previous elements
      px <- params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]]

      treatments_pathways <- names(px$treatments)

      updateSelectInput(session, "sliders_select_treat", choices = treatments_pathways)

      removeUI("#div_slider_treatmentpathway > *", TRUE, TRUE)
      # now, add the new sliders

      # loop over the treatments
      walk(treatments_pathways, function(i) {
        # slider names can't have spaces, replace with _
        ix <- str_replace(i, " ", "_")
        split_name <- paste0("numeric_treatpath_split_", ix)
        treat_name <- paste0("slider_treatpath_treat_", ix)

        split <- numericInput(
          split_name,
          label = paste("split", i),
          value = px$treatments[[i]]$split
        )

        treat <- sliderInput(
          treat_name,
          label = paste("treat %", i),
          value = px$treatments[[i]]$treat * 100,
          min = 0, max = 100, step = 0.01, post = "%"
        )

        insertUI("#div_slider_treatmentpathway", "beforeEnd", split)
        insertUI("#div_slider_treatmentpathway", "beforeEnd", treat)

        observeEvent(input[[split_name]], {
          v <- input[[split_name]]
          params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]]$treatments[[i]]$split <- v
        })

        observeEvent(input[[treat_name]], {
          v <- input[[treat_name]] / 100
          params$groups[[input$popn_subgroup]]$conditions[[input$sliders_select_cond]]$treatments[[i]]$treat <- v
        })
      })
    }
  })

  # params_cond_to_treat ====

  observeEvent(input$sliders_select_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups()) {
      v <- params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat * 100

      updateSliderInput(session, "slider_treat", value = v)
    }
  })

  # slider_treat (sliderInput)
  observeEvent(input$slider_treat, {
    psg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    if (psg %in% population_groups()) {
      v <- input$slider_treat / 100
      params$groups[[psg]]$conditions[[condition]]$treatments[[treatment]]$treat <- v
    }
  })

  # params_demand ====

  # treatment_type (selectInput)
  observeEvent(input$treatment_type, {
    if (req(input$treatment_type) %in% treatments()) {
      tx <- params$treatments[[input$treatment_type]]
      updateSliderInput(session, "treatment_appointments", value = tx$demand)
      updateSliderInput(session, "slider_success", value = tx$success * 100)
      updateSliderInput(session, "slider_tx_months", value = tx$months)
      updateSliderInput(session, "slider_decay", value = tx$decay * 100)
    }
  })

  # treatment_appointments (sliderInput)
  observeEvent(input$treatment_appointments, {
    if (req(input$treatment_type) %in% treatments()) {
      params$treatments[[input$treatment_type]]$demand <- input$treatment_appointments
    }
  })

  # slider_success (sliderInput)
  observeEvent(input$slider_success, {
    if (req(input$treatment_type) %in% treatments()) {
      params$treatments[[input$treatment_type]]$success <- input$slider_success / 100
    }
  })

  # slider_tx_months (sliderInput)
  observeEvent(input$slider_tx_months, {
    if (req(input$treatment_type) %in% treatments()) {
      params$treatments[[input$treatment_type]]$months <- input$slider_tx_months
    }
  })

  # slider_decay (sliderInput)
  observeEvent(input$slider_decay, {
    if (req(input$treatment_type) %in% treatments()) {
      params$treatments[[input$treatment_type]]$decay <- input$slider_decay / 100
    }
  })

  # download_params (downloadButton)
  output$download_params <- downloadHandler(
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
      df <- model_output() %>%
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

  observe({
    # only run current selected population group

    if (req(input$popn_subgroup) %in% population_groups()) {
      px <- reactiveValuesToList(params)
      models[[input$popn_subgroup]] <- run_single_model(px, input$popn_subgroup, 24, sim_time)
    }
  })

  model_output <- reactive({
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
