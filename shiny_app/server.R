library(shiny)
library(uuid)

shinyServer(function(input, output, session) {

  ## needs to be after upload function

  population_groups <- reactiveVal(population_groups)
  curves <- reactiveVal(names(params$curves))
  treatments <- reactiveVal(treatments)

  models <- lift_dl(reactiveValues)(models)
  params <- lift_dl(reactiveValues)(params)

  redraw_dropdowns <- reactiveVal()
  redraw_treatments <- reactiveVal()
  redraw_g2c <- reactiveVal()
  redraw_c2t <- reactiveVal()

  # store observers so we can destroy them
  div_slider_cond_pcnt_obs <- list()
  div_slider_treatpath_obs <- list()

  ## New params

  observeEvent(input$user_upload_json, {
    new_params <- read_json(input$user_upload_json$datapath, simplifyVector = TRUE)

    params$groups <- new_params$groups
    params$treatments <- new_params$treatments
    params$curves <- new_params$curves

    population_groups(names(new_params$groups))
    treatments(names(new_params$treatments))
    curves(names(new_params$curves))

    u <- UUIDgenerate()
    redraw_dropdowns(u)
    redraw_treatments(u)
    redraw_g2c(u)
    redraw_c2t(u)
  })

  # Update main select options ====

  observe({
    # trigger update of selects, even if the choices haven't changed
    force(redraw_dropdowns())

    updateSelectInput(session, "popn_subgroup", choices = population_groups())
    updateSelectInput(session, "subpopulation_curve", choices = curves())
    updateSelectInput(session, "treatment_type", choices = treatments())
    updateSelectInput(session, "services", choices = treatments())
  })

  # params_population_groups ====

  # popn_subgroup (selectInput)
  observeEvent(input$popn_subgroup, {
    redraw_g2c(UUIDgenerate())
  })

  observeEvent(redraw_g2c(), {
    sg <- req(isolate(input$popn_subgroup))

    px <- isolate(params)$groups[[sg]]

    conditions <- names(px$conditions)
    updateSelectInput(session, "sliders_select_cond", choices = conditions)
    redraw_c2t(UUIDgenerate())

    updateNumericInput(session, "subpopulation_size", value = px$size)
    updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
    updateSliderInput(session, "subpopulation_curve", value = px$curve)

    # update the condition percentage sliders
    # first, remove the previous elements
    walk(div_slider_treatpath_obs, ~.x$destroy())
    div_slider_treatpath_obs <<- list()

    walk(div_slider_cond_pcnt_obs, ~.x$destroy())
    div_slider_cond_pcnt_obs <<- list()
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

      div_slider_cond_pcnt_obs[[slider_name]] <<- observeEvent(input[[slider_name]], {
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
    sg <- req(input$popn_subgroup)
    params$groups[[sg]]$size <- input$subpopulation_size
  })

  # subpopulation_pcnt (numericInput)
  observeEvent(input$subpopulation_pcnt, {
    sg <- req(input$popn_subgroup)
    params$groups[[sg]]$pcnt <- input$subpopulation_pcnt
  })

  # subpopulation_curve (selectInput)
  observeEvent(input$subpopulation_curve, {
    sg <- req(input$popn_subgroup)
    params$groups[[sg]]$curve <- input$subpopulation_curve
  })

  # params_group_to_cond ====

  # sliders_select_cond (selectInput)
  observeEvent(input$sliders_select_cond, {
    redraw_c2t(UUIDgenerate())
  })

  observeEvent(redraw_c2t(), {
    sg <- req(input$popn_subgroup)
    ssc <- input$sliders_select_cond

    # first, remove the previous elements
    walk(div_slider_treatpath_obs, ~.x$destroy())
    div_slider_treatpath_obs <<- list()
    removeUI("#div_slider_treatmentpathway > *", TRUE, TRUE)

    # now, add the new sliders
    px <- params$groups[[sg]]$conditions[[ssc]]

    treatments_pathways <- names(px$treatments)

    updateSelectInput(session, "sliders_select_treat", choices = treatments_pathways)

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

      div_slider_treatpath_obs[[split_name]] <<- observeEvent(input[[split_name]], {
        v <- input[[split_name]]
        params$groups[[sg]]$conditions[[ssc]]$treatments[[i]]$split <- v
      })

      div_slider_treatpath_obs[[treat_name]] <<- observeEvent(input[[treat_name]], {
        v <- input[[treat_name]] / 100
        params$groups[[sg]]$conditions[[ssc]]$treatments[[i]]$treat <- v
      })
    })
  })

  # params_cond_to_treat ====

  observeEvent(input$sliders_select_treat, {
    sg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    v <- params$groups[[sg]]$conditions[[condition]]$treatments[[treatment]]$treat * 100
    updateSliderInput(session, "slider_treat", value = v)
  })

  # slider_treat (sliderInput)
  observeEvent(input$slider_treat, {
    sg <- req(input$popn_subgroup)
    condition <- req(input$sliders_select_cond)
    treatment <- req(input$sliders_select_treat)

    v <- input$slider_treat / 100
    params$groups[[sg]]$conditions[[condition]]$treatments[[treatment]]$treat <- v
  })

  # params_demand ====

  # treatment_type (selectInput)
  observeEvent(input$treatment_type, {
    redraw_treatments(UUIDgenerate())
  })

  observeEvent(redraw_treatments(), {
    tx <- params$treatments[[req(input$treatment_type)]]
    updateSliderInput(session, "treatment_appointments", value = tx$demand)
    updateSliderInput(session, "slider_success", value = tx$success * 100)
    updateSliderInput(session, "slider_tx_months", value = tx$months)
    updateSliderInput(session, "slider_decay", value = tx$decay * 100)
  })

  # treatment_appointments (sliderInput)
  observeEvent(input$treatment_appointments, {
    ttype <- req(input$treatment_type)
    params$treatments[[ttype]]$demand <- input$treatment_appointments
  })

  # slider_success (sliderInput)
  observeEvent(input$slider_success, {
    ttype <- req(input$treatment_type)
    params$treatments[[ttype]]$success <- input$slider_success / 100
  })

  # slider_tx_months (sliderInput)
  observeEvent(input$slider_tx_months, {
    ttype <- req(input$treatment_type)
    params$treatments[[ttype]]$months <- input$slider_tx_months
  })

  # slider_decay (sliderInput)
  observeEvent(input$slider_decay, {
    ttype <- req(input$treatment_type)
    params$treatments[[ttype]]$decay <- input$slider_decay / 100
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
    ps <- req(input$popn_subgroup)
    px <- reactiveValuesToList(params)
    models[[ps]] <- run_single_model(px, ps, 24, sim_time)
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


  ## Surge Tabs ####

  summary_outputs <- reactive({
    model_output() %>%
      filter(near(time, round(time))) %>%
      group_by_at(vars(time:treatment)) %>%
      summarise_all(sum) %>%
      rename(treatment_pathway = treatment)
  })

  ## Tab - Subpopn ####

  output$surge_subpopn <- renderTable({
    summary_outputs() %>%
      pivot_wider(names_from = type, values_from = value) %>%
      dplyr::group_by(group) %>%
      filter(!is.na(group)) %>%
      summarise(`Adjusted exposed / at risk @ baseline` = as.integer(round(sum(`new-at-risk`, na.rm = T), 0)),
                `Total symptomatic over period referrals` = as.integer(round(sum(`new-referral`, na.rm = T), 0)),
                `Total receiving services over period` = as.integer(round(sum(`new-treatment`, na.rm = T), 0))) %>%
      arrange(-`Total symptomatic over period referrals`)
  })

  ## Tab - Conditions ####

  output$surge_condition <- renderTable({
    summary_outputs() %>%
      pivot_wider(names_from = type, values_from = value) %>%
      dplyr::group_by(condition) %>%
      filter(!is.na(condition)) %>%
      summarise(`Adjusted exposed / at risk @ baseline` = as.integer(round(sum(`new-at-risk`, na.rm = T), 0)),
                `Total symptomatic over period referrals` = as.integer(round(sum(`new-referral`, na.rm = T), 0)),
                `Total receiving services over period` = as.integer(round(sum(`new-treatment`, na.rm = T), 0))) %>%
      arrange(-`Total symptomatic over period referrals`)
  })


  ## Tab - Treatment Pathway ####

  summary_treatment_pathway <- reactive({
    summary_outputs() %>%
    pivot_wider(names_from = type, values_from = value) %>%
    dplyr::group_by(treatment_pathway) %>%
    filter(!is.na(treatment_pathway)) %>%
    summarise(`Total new referrals/presentations over period` = as.integer(round(sum(`new-referral`, na.rm = T), 0)),
              `Total services offered over period` = as.integer(round(sum(`new-treatment`, na.rm = T), 0))) %>%
    arrange(-`Total new referrals/presentations over period`)
  })

  output$surge_treatmentpathway <- renderTable({
    summary_treatment_pathway()
  })

  output$surge_treatmentpathwayplot <- renderPlot({
    summary_treatment_pathway() %>%
      pivot_longer(!contains("treatment_pathway")) %>%
      ggplot(aes(treatment_pathway, value)) +
      geom_col(position = "dodge") +
      labs(y = "Number",
             x = "Treatment Pathway") +
      scale_x_discrete(labels = function(x) str_wrap(x, 8),
                       guide = guide_axis(n.dodge = 2)) +
      facet_wrap(~ name, ncol=1)

  })

  ## Bubble Pack testing ####

  output$bubble_plot_baselinepopn <- renderPlotly({

    circle_pack_plot <- map_dbl(params$groups, "size") %>%
      enframe(name = "subpopn") %>%
      mutate(level_2 = case_when(subpopn %in% c("Children & young people", "Students FE & HE") ~ "Children & young people",
                                 subpopn %in% c("Elderly alone") ~ "Elderly alone",
                                 subpopn %in% c("General population") ~ "General population",
                                 subpopn %in% c("Domestic abuse victims", "Family of COVID deceased", "Family of ICU survivors", "Newly unemployed", "Pregnant & New Mothers", "Parents") ~ "Other Adults and Specific Groups",
                                 subpopn %in% c("Health and care workers", "ICU survivors") ~ "Directly affected individuals",
                                 subpopn %in% c("Learning disabilities & autism", "Pre existing CMH illness", "Pre existing LTC", "Pre existing SMI") ~ "Existing Conditions",
                                 TRUE ~ NA_character_))



    packing <- circleProgressiveLayout(circle_pack_plot$value, sizetype='area')
    circle_pack_plot <- cbind(circle_pack_plot, packing)
    dat.gg <- circleLayoutVertices(packing, npoints=50)

    dat.gg <- dat.gg %>% left_join(tibble(level_2 = circle_pack_plot$level_2, id = 1:16),
                                   by = "id")

    my_plot <- ggplot() +
      geom_polygon(data = dat.gg, aes(x, y, group = id, fill=as.factor(level_2)), colour = "black", alpha = 0.6) +
      geom_text(data = circle_pack_plot, aes(x, y, size=value, label = subpopn)) +
      scale_size_continuous(range = c(1,4)) +
      theme_void() +
      theme(legend.position="none") +
      scale_fill_brewer(palette = "Set1") +
      coord_equal()
      ggplotly(my_plot)

  })

  ## Box testing ####

  output$test <- renderPlot(
    {
  surge_components <- model_output() %>%
    filter(type == "new-referral",
           treatment == input$services,
           near(time, round(time))) %>%
    group_by(group) %>%
    summarise(`# Referrals` = round(sum(value), 0)) %>%
  filter(`# Referrals` != 0)

  surge_components %>%
    ggplot(aes(reorder(group, `# Referrals`), `# Referrals`)) +
    theme_bw() +
    geom_col(fill = "#00c0ef") +
    geom_text(aes(label = `# Referrals`), hjust = -0.1, size = 80/length(surge_components$group)) +
    coord_flip(clip = ) +
    scale_x_discrete(labels = function(x) str_wrap(x, 13)) +
    theme(text = element_text(size = 20),
          axis.text.y = element_text(size = case_when(length(surge_components$group) <= 6 ~ 20,
                                                      between(length(surge_components$group), 7, 9) ~ 16,
                                                      between(length(surge_components$group), 10, 12) ~ 12,
                                                      length(surge_components$group) >= 13 ~ 10)),
          axis.title.y = element_blank(),
          plot.margin = margin(t = 0, r = 25, b = 0, l = 0, unit = "pt")
    )
    }
  )

  output$testvalue <- renderText({

    surge_components <- model_output() %>%
      filter(type == "new-referral",
             treatment == input$services,
             near(time, round(time))) %>%
      group_by(group) %>%
      summarise(`# Referrals` = round(sum(value), 0)) %>%
      filter(`# Referrals` != 0)

    length(surge_components$group)

  })


})
