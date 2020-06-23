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
    if (isTruthy(input$file1)) return(df()) else return(read_csv("sample_params.csv", col_types = "cccddddd"))
  })

  ################################
  ## Update Selectise Options ####
  ################################

  variable_list <- reactive(df() %>% select(group, treatment, condition) %>% unique() %>% unite("group", sep = "-") %>% pull(group))
  #
  observe(updateSelectInput(session, "sliders_select", choices = variable_list()))

  ###############
  ## Sliders ####
  ###############

  observe(
    {
    mh_subgroup <- input[["sliders_select"]]

    updateSliderInput(session, "slider_pcnt", value = param_csv %>% filter(rowname == mh_subgroup) %>% pull(pcnt))
    updateSliderInput(session, "slider_treat", value = param_csv %>% filter(rowname == mh_subgroup) %>% pull(treat))
    updateSliderInput(session, "slider_success", value = param_csv %>% filter(rowname == mh_subgroup) %>% pull(success))
    }
  )


  #############
  ## Model ####
  #############

  # Params ----
  param_csv <- read_csv("sample_params.csv", col_types = "cccddddd") %>%
    unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
    mutate_at("decay", ~half_life_factor(days, .x)) %>%
    select(-days)

  params <- reactive({
    data <- param_csv %>%
    select(pcnt:decay) %>%
    as.matrix() %>%
    t()
  colnames(data) <- param_csv$rowname
  data[which(rownames(data) == "pcnt"),1] <- input[["slider_pcnt"]]
  data[which(rownames(data) == "treat"),1] <- input[["slider_treat"]]
  data[which(rownames(data) == "success"),1] <- input[["slider_success"]]
  return(data)
  }
  )

  # Simulated demand surges ----

  interp_months <- reactive(quantile(0:input$totalmonths, probs = seq(0,1,0.1)) %>% unname())

  ## probably put this in a list later ####
  unemployed <- reactive(input$subpopulation_figure*(input$pct_unemployed/100))
  bereaved <- reactive(input$subpopulation_figure-unemployed())


  new_potential <- reactive(
    {
      list(
    unemployed = approxfun(
      interp_months(),
      switch (input[["scenario"]],
        "Sudden shock" = sample(1:11, unemployed(), T, dgamma(1:11, 5, 1)) %>% tabulate(nbins = 11),
        "Follow the curve" = sample(1:11, unemployed(), T, dgamma(1:11, 5, 0.5)) %>% tabulate(nbins = 11),
        "Shallow mid-term" = sample(1:11, unemployed(), T, dnorm(1:11, 11/2, 8)) %>% tabulate(nbins = 11)
      ),
      rule = 2
    ),
    bereaved = approxfun(
      interp_months(),
      switch (input[["scenario"]],
              "Sudden shock" = sample(1:11, bereaved(), T, dgamma(1:11, 5, 1)) %>% tabulate(nbins = 11),
              "Follow the curve" = sample(1:11, bereaved(), T, dgamma(1:11, 5, 0.5)) %>% tabulate(nbins = 11),
              "Shallow mid-term" = sample(1:11, bereaved(), T, dnorm(1:11, 11/2, 8)) %>% tabulate(nbins = 11)
      ),
      rule = 2
    )
  )
    }
  )

  # Run model ----
  o <- reactive(run_model(params(), new_potential(), simtime = seq(0, input$totalmonths, by = 1/30)))

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
  }
  )

  p2 <- reactive({
    o() %>%
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
    p1()
  )

  output$myplot2 <- renderPlotly(
    ggplotly(p2(), tooltip = c("text"))
  )

})
