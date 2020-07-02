library(shiny)

shinyServer(function(input, output, session) {
  ###################
  ## CSV Outputs ####
  ###################

  read_params_from_csv <- function(filename) {
    params_raw <- read_csv(filename, col_types = "cccddddd") %>%
      unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
      mutate_at("decay", ~ half_life_factor(days, .x)) %>%
      select(-days)

    data <- params_raw %>%
      select(pcnt:decay) %>%
      as.matrix() %>%
      t()
    colnames(data) <- params_raw$rowname

    asplit(data, 2)
  }

  params_raw <- read_params_from_csv("sample_params.csv")
  params <- lift_dl(reactiveValues)(params_raw)

  population_groups_raw <- read_csv("population_groups.csv", col_types = "ccdd") %>%
    group_nest(group) %$%
    set_names(data, group) %>%
    map(as.list)
  population_groups <- lift_dl(reactiveValues)(population_groups_raw)

  curves <- read_csv("curves.csv", col_types = "ddddd") %>%
    modify_at(vars(-Month), ~.x / sum(.x))

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

  #############
  ## Plots ####
  #############

  pop_plot <- reactive({
    o() %>%
      filter(type == "at-risk") %>%
      ggplot(aes(time,
                 value,
                 colour = group)) +
      geom_line() +
      labs(x = "Simulation Month",
           y = "# at Risk",
           colour = "")
  })

  demand_plot <- reactive({
    o() %>%
      filter(type == "treatment") %>%
      group_by(time, treatment) %>%
      summarise(across(value, sum), .groups = "drop") %>%
      inner_join(
        tribble(
          ~ treatment,
          ~ average_monthly_appointments,
          "cmht",
          input[["cmht_appointments"]],
          "iapt",
          input[["iapt_appointments"]],
          "psych-liason",
          input[["psych-liason_appointments"]]
        ),
        by = "treatment"
      ) %>%
      mutate(no_appointments = value * average_monthly_appointments) %>%
      ggplot(aes(
        time,
        no_appointments,
        colour = treatment,
        group = treatment,
        text = paste0(
          "Time: ",
          scales::number(time, accuracy = 0.1),
          "\n",
          "# Appointments: ",
          round(no_appointments, 0),
          "\n",
          "Treatment: ",
          treatment
        )
      )) +
      geom_line() +
      labs(x = "Simulation Month",
           y = "# Appointments",
           colour = "")
  })

  output$pop_plot <- renderPlotly(ggplotly(pop_plot()))

  output$demand_plot <- renderPlotly(ggplotly(demand_plot(), tooltip = c("text")))

})
