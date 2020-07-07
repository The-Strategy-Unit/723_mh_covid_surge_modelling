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
    updateSelectInput(session,
                      "sliders_select",
                      choices = names(params_raw)[names(params_raw) %>% str_which(input$popn_subgroup)])
    updateSelectInput(session, "popn_subgroup", choices = names(population_groups_raw))
    updateSelectInput(session, "subpopulation_curve", choices = names(curves[, -1]))
    updateSelectInput(session, "treatment_type", choices = treatment_types)
    updateSelectInput(session, "demand_treatment_type", choices = treatment_types)
    updateSelectInput(session,
                      "popn_subgroup_plot",
                      choices = names(population_groups_raw),
                      selected = input$popn_subgroup)
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

  observeEvent(input$demand_treatment_type, {
    updateSliderInput(session,
                      "demand_treatment_demand",
                      value = treatment_appointments[[input$demand_treatment_type]])
  })

  observeEvent(input$demand_treatment_demand, {
    if (req(input$demand_treatment_type) %in% treatment_types) {
      treatment_appointments[[input$demand_treatment_type]] <- input$demand_treatment_demand
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

  o_filter <- reactive({
    o() %>% filter(group %in% input$popn_subgroup_plot)
  })

  appointments <- reactive({
    v <- reactiveValuesToList(treatment_appointments)
    tibble(treatment = names(v),
           average_monthly_appointments = flatten_dbl(v))
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

  output$pop_plot <- renderPlotly(
    ggplotly(pop_plot(o_filter()),
             tooltip = c("text"))
  )

  output$demand_plot <- renderPlotly(
    ggplotly(demand_plot(demand()),
             tooltip = c("text"))
  )

  output$demand_demand_plot <- renderPlotly({
    p <- demand() %>%
      filter(treatment == input$demand_treatment_type) %>%
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

  parameters_tibble <- reactive({
    tibble(Type = c(rep("Population Group", 5),
                    rep("Treatments", 4)
                    # ,
                    # rep("Appointments", 17)
                    ),
           Variable = c("Subgroup",
                        "Months in Model",
                        "Subpopulation Figure",
                        "% in subgroup",
                        "Scenario",
                        "Group-Treatment-Condition combination",
                        "Prevalence",
                        "% Requiring Treatment",
                        "Success % of Treatment"
                        # ,
                        # treatment_types
                        ),
           Value = c(input$popn_subgroup,
                     input$totalmonths,
                     input$subpopulation_size,
                     input$subpopulation_pcnt,
                     input$subpopulation_curve,
                     input$sliders_select,
                     input$slider_pcnt,
                     input$slider_treat,
                     input$slider_success)
     )
  })

  output$download_params <- downloadHandler(filename = "parameters.csv",
                                            content = function(file) {
                                              write.csv(parameters_tibble(), file)
                                            })

  output$download_params <- downloadHandler(filename = "parameters.csv",
                                            content = function(file) {
                                              write.csv(parameters_tibble(), file)
                                            })

  ## Test ####

  output$o_print_test <- renderPrint(o())

})
