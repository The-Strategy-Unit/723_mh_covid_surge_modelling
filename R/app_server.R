#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% select tibble tribble
#' @importFrom purrr map walk walk2 pmap map_dbl lift_dl modify_at set_names
#' @importFrom plotly renderPlotly
#' @importFrom utils write.csv
#' @noRd
app_server <- function(input, output, session) {
  counter <- methods::new("Counter")

  population_groups <- reactiveVal(population_groups)
  all_conditions <- reactiveVal(get_all_conditions(params))
  treatments <- reactiveVal(treatments)
  curves <- reactiveVal(names(params$curves))

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

  observeEvent(input$user_upload_xlsx, {
    new_params <- extract_params_from_excel(input$user_upload_xlsx$datapath)

    params$groups <- new_params$groups
    params$treatments <- new_params$treatments
    params$curves <- new_params$curves

    population_groups(names(new_params$groups))
    all_conditions(get_all_conditions(params))
    treatments(names(new_params$treatments))
    curves(names(new_params$curves))

    u <- counter$get()
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
    redraw_g2c(counter$get())
  })

  observeEvent(redraw_g2c(), {
    sg <- req(isolate(input$popn_subgroup))

    px <- isolate(params)$groups[[sg]]

    conditions <- names(px$conditions)
    updateSelectInput(session, "sliders_select_cond", choices = conditions)
    redraw_c2t(counter$get())

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
      slider_name <- gsub(" ", "_", paste0("slider_cond_pcnt_", i))
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
          sn <- gsub(" ", "_", paste0("slider_cond_pcnt_", j))
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
    redraw_c2t(counter$get())
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
      ix <- gsub(" ", "_", i)
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
    redraw_treatments(counter$get())
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
    "params.xlsx",
    function(file) {
      params %>%
        reactiveValuesToList() %>%
        params_to_xlsx(file)
    }
  )

  # download_output (downloadButton)
  output$download_output <- downloadHandler(
    paste0("model_run_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".csv"),
    download_output(model_output(), appointments()),
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
    models %>%
      reactiveValuesToList() %>%
      get_model_output()
  })

  appointments <- reactive({
    params %>%
      reactiveValuesToList() %>%
      get_appointments()
  })

  # Results tab ====

  output$referrals_plot <- renderPlotly({
    referrals_plot(model_output(), input$services)
  })

  output$demand_plot <- renderPlotly({
    demand_plot(model_output(), appointments(), input$services)
  })

  output$graph <- renderPlotly({
    create_graph(model_output(), treatments = input$services)
  })

  output$combined_plot <- renderPlotly({
    combined_plot(model_output(), input$services, reactiveValuesToList(params))
  })

  # Output boxes

  tribble(
    ~output_id,          ~value_type,     ~text,
    "total_referrals",   "new-referral",  "Total 'surge' referrals",
    "total_demand",      "treatment",     "Total additional demand per contact type",
    "total_newpatients", "new-treatment", "Total new patients in service"
  ) %>%
    pmap(function(output_id, value_type, text) {
      output[[output_id]] <- renderValueBox({
        value <- model_output() %>%
          model_totals(value_type, input$services)

        valueBox(value, text)
      })
    })

  output$results_popgroups <- renderPlotly({
    popgroups_plot(model_output(), input$services)
  })

  # Surge Tabs ----

  # Surge subpopn tab ====

  output$surge_subpopn_table <- renderTable({
    model_output() %>%
      surge_summary(group) %>%
      surge_table("Subpopulation group")
  })

  output$surge_subpopn_plot <- renderPlotly({
    model_output() %>%
      surge_summary(group) %>%
      select(-.data$`new-at-risk`) %>%
      surge_plot()
  })

  # Surge conditions tab ====

  output$surge_condition_table <- renderTable({
    model_output() %>%
      surge_summary(condition) %>%
      surge_table("Condition")
  })

  output$surge_condition_plot <- renderPlotly({
    model_output() %>%
      surge_summary(condition) %>%
      surge_plot()
  })

  # Surge service tab ====

  output$surge_service_table <- renderTable({
    model_output() %>%
      surge_summary(treatment) %>%
      surge_table("Treatment")
  })

  output$surge_service_plot <- renderPlotly({
    model_output() %>%
      surge_summary(treatment) %>%
      surge_plot()
  })

  # Bubble plot tab ====

  output$bubble_plot_baselinepopn <- renderPlotly({
    params %>%
      reactiveValuesToList() %>%
      bubble_plot()
  })

  # graphpage ====

  observe({
    updateSelectInput(session,
                      "graphpage_select_groups",
                      choices = population_groups(),
                      selected = population_groups())

    updateSelectInput(session,
                      "graphpage_select_conditions",
                      choices = all_conditions(),
                      selected = all_conditions())

    updateSelectInput(session,
                      "graphpage_select_treatments",
                      choices = treatments(),
                      selected = treatments())
  })

  output$graphpage_graph <- renderPlotly({
    create_graph(model_output(),
                 input$graphpage_select_groups,
                 input$graphpage_select_conditions,
                 input$graphpage_select_treatments)
  })

}
