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

  params <- lift_dl(reactiveValues)(read_params_from_csv("sample_params.csv"))

  ################################
  ## Update Selectise Options ####
  ################################

  observe({
    updateSelectInput(session, "sliders_select", choices = names(params))
  })

  ## Population values change ####

  popn_subgroups <- reactiveValues()
  popn_subgroups[["Unemployed_Total"]] <- 10000
  popn_subgroups[["Bereaved_Total"]] <- 2000
  popn_subgroups[["Unemployed_PCT"]] <- 100
  popn_subgroups[["Bereaved_PCT"]] <- 100
  popn_subgroups[["Unemployed_scenario"]] <- "Sudden shock"
  popn_subgroups[["Bereaved_scenario"]] <- "Sudden shock"

  observeEvent(input$subpopulation_figure, {
    popn_subgroups[[paste0(input$popn_subgroup, "_Total")]] <- input$subpopulation_figure
  })
  observeEvent(input$pct_unemployed, {
    popn_subgroups[[paste0(input$popn_subgroup, "_PCT")]] <- input$pct_unemployed
  })
  observeEvent(input$scenario, {
    popn_subgroups[[paste0(input$popn_subgroup, "_scenario")]] <- input$scenario
  })

  observeEvent(input$popn_subgroup,{
    updateNumericInput(session, 'subpopulation_figure',
                       label = "Subpopulation Figure",
                       value = popn_subgroups[[paste0(input$popn_subgroup, "_Total")]],
                       step = 100)
    updateNumericInput(session, 'pct_unemployed',
                       label = "% in subgroup",
                       value = popn_subgroups[[paste0(input$popn_subgroup, "_PCT")]],
                       min = 0,
                       max = 100,
                       step = 1)
    updateSelectInput(session,
                      "scenario",
                      label = "Choose scenario",
                      choices = c("Sudden shock", "Follow the curve", "Shallow mid-term", "Sustained impact"))
  })

  ## Subpopulation scenario change ####

  output$scenario_select <- renderUI({
    selectInput("popn_subgroup",
                "Choose scenario",
                choices = c("Sudden shock",
                            "Follow the curve",
                            "Shallow mid-term",
                            "Sustained impact"))
  })

  ###############
  ## Sliders ####
  ###############

  # when the sliders_select drop down is changed, set the values of the sliders from params
  observeEvent(input$sliders_select, {
    p <- params[[input$sliders_select]]
    updateSliderInput(session, "slider_pcnt",    value = p[["pcnt"]])
    updateSliderInput(session, "slider_treat",   value = p[["treat"]])
    updateSliderInput(session, "slider_success", value = p[["success"]])
  })

  # when any of the sliders are changed, update the value in params
  walk(c("pcnt", "treat", "success"), function(x) {
    input_name <- paste0("slider_", x)

    observeEvent(input[[input_name]], {
      params[[input$sliders_select]][[x]] <- input[[input_name]]
    })
  })

  #############
  ## Model ####
  #############

  curves <- read_csv("curves.csv", col_types = "ddddd")

  new_potential <- reactive({
    list(
      unemployed = approxfun(seq_len(24) - 1,
                             curves[[popn_subgroups$Unemployed_scenario]] * popn_subgroups[["Unemployed_PCT"]]/100,
                             rule = 2),
      bereaved = approxfun(seq_len(24) - 1,
                           curves[[popn_subgroups$Bereaved_scenario]] * popn_subgroups[["Bereaved_PCT"]]/100,
                           rule = 2)
    )
  })

  # Run model ----
  o <- reactive({
    # convert the reactive values params back to a matrix to use with the model
    p <- reactiveValuesToList(params)

    m <- matrix(unlist(p),
                nrow = length(p[[1]]),
                dimnames = list(names(p[[1]]),
                                names(p)))

    run_model(
      m,
      new_potential(),
      simtime = seq(0, input$totalmonths, by = 1 / 30)
    )
  })

  #############
  ## Plots ####
  #############

  p1 <- reactive({
    o() %>%
      filter(type == "at-risk") %>%
      ggplot(aes(time, value, colour = group)) +
      geom_line() +
      labs(x = "Simulation Month",
           y = "# at Risk",
           colour = "")
  })

  p2 <- reactive({
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
        group = treatment
      )) +
      geom_line(aes(
        text = paste0(
          "Time: ",
          time,
          "\n",
          "# Appointments: ",
          round(no_appointments, 0),
          "\n",
          "Treatment: ",
          treatment
        )
      )) +
      labs(x = "Simulation Month",
           y = "# Appointments",
           colour = "")
  })

  output$myplot <- renderPlotly(p1())

  output$myplot2 <- renderPlotly(ggplotly(p2(), tooltip = c("text")))

})
