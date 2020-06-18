library(shiny)

shinyServer(function(input, output, session) {

  ###################
  ## CSV Outputs ####
  ###################


  df <- reactive({
    req(input$file1)
    read_csv(input$file1$datapath, col_types = "cccddddd")
    })

  output$contents <- renderTable({
    req(input$file1)
    return(df())
  })

  ################################
  ## Update Selectise Options ####
  ################################

  variable_list <- reactive(df() %>% select(group, treatment, condition) %>% unique() %>% unite("group", sep = "-") %>% pull(group))

  observe(updateSelectInput(session, "sliders_select", choices = variable_list()))

  ###############
  ## Sliders ####
  ###############




  #############
  ## Model ####
  #############

  # Params ----
  param_csv <- read_csv("./../sample_params.csv", col_types = "cccddddd") %>%
    unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
    mutate_at("decay", ~half_life_factor(days, .x)) %>%
    select(-days)

  params <- param_csv %>%
    select(pcnt:decay) %>%
    as.matrix() %>%
    t()

  colnames(params) <- param_csv$rowname

  # Simulated demand surges ----
  new_potential <- list(
    unemployed = approxfun(
      c(0, 4, 6, 10, 16),
      c(100, 2000, 8000, 6000, 0),
      rule = 2
    ),
    bereaved = approxfun(
      c(0, 4, 6, 10, 16),
      c(0, 100, 500, 2000, 1500),
      rule = 2
    )
  )

  # Run model ----
  o <- run_model(params, new_potential)

  o



  #############
  ## Plots ####
  #############

  p1 <- o %>%
    filter(type == "at-risk") %>%
    ggplot(aes(time, value, colour = group)) +
    geom_line() +
    labs(x = "Simulation Month",
         y = "# at Risk",
         colour = "")

  p2 <- reactive({
    o %>%
    filter(type == "treatment") %>%
    group_by(time, treatment) %>%
    summarise(across(value, sum), .groups = "drop") %>%
    inner_join(tribble(
      ~treatment, ~average_monthly_appointments,
      "cmht", input[["cmht_appointments"]],
      "iapt", input[["iapt_appointments"]],
      "psych-liason", input[["psych-liason_appointments"]]
    ), by = "treatment") %>%
    mutate(no_appointments = value*average_monthly_appointments) %>%
    ggplot(aes(time, no_appointments, colour = treatment, group = treatment)) +
    geom_line(aes(text = paste0("Time: ", time, "\n",
      "# Appointments: ", round(no_appointments, 0), "\n",
                                "Treatment: ", treatment))) +
    labs(x = "Simulation Month",
         y = "# Appointments",
         colour = "")
  }
  )

  output$myplot <- renderPlotly(
    p1
  )

  output$myplot2 <- renderPlotly(
    ggplotly(p2(), tooltip = c("text"))
  )

})
