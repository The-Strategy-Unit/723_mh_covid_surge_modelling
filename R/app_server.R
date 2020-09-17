#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% select tibble tribble
#' @importFrom purrr map walk walk2 pmap map_dbl lift_dl modify_at set_names discard
#' @importFrom plotly renderPlotly
#' @importFrom utils write.csv
#' @importFrom shinyjs disabled
#' @noRd
app_server <- function(input, output, session) {
  counter <- methods::new("Counter")

  population_groups <- reactiveVal(population_groups)
  all_conditions <- reactiveVal(get_all_conditions(params))
  treatments <- reactiveVal(treatments)
  curves <- reactiveVal(names(params$curves))

  models <- lift_dl(reactiveValues)(models)
  params <- lift_dl(reactiveValues)(params)

  # Params Tab ----

  redraw_dropdowns <- reactiveVal()
  redraw_groups <- reactiveVal()
  redraw_treatments <- reactiveVal()
  redraw_g2c <- reactiveVal()
  redraw_c2t <- reactiveVal()

  # store observers so we can destroy them
  div_slider_cond_pcnt_obs <- list()
  div_slider_treatpath_obs <- list()

  # Upload new params

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
    redraw_groups(u)
    redraw_treatments(u)
    redraw_g2c(u)
    redraw_c2t(u)
  })

  # Update main select options

  observe({
    # trigger update of selects, even if the choices haven't changed
    force(redraw_dropdowns())

    updateSelectInput(session, "popn_subgroup", choices = population_groups())
    updateSelectInput(session, "subpopulation_curve", choices = curves())
    updateSelectInput(session, "treatment_type", choices = treatments())
  })

  # params_population_groups ====

  # popn_subgroup (selectInput)
  observeEvent(input$popn_subgroup, {
    redraw_groups(counter$get())
  })

  observeEvent(redraw_groups(), {
    sg <- req(isolate(input$popn_subgroup))
    px <- isolate(params)$groups[[sg]]
    conditions <- names(px$conditions)

    updateSelectInput(session, "sliders_select_cond", choices = conditions)
    updateNumericInput(session, "subpopulation_size", value = px$size)
    updateNumericInput(session, "subpopulation_pcnt", value = px$pcnt)
    updateSliderInput(session, "subpopulation_curve", value = px$curve)

    redraw_g2c(counter$get())
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

  # subpopulation_size_pcnt (textOutput)
  output$subpopulation_size_pcnt <- renderText({
    paste0("Modelled population: ", comma(input$subpopulation_size * input$subpopulation_pcnt / 100))
  })

  # subpopulation_curve (selectInput)
  observeEvent(input$subpopulation_curve, {
    sg <- req(input$popn_subgroup)
    params$groups[[sg]]$curve <- input$subpopulation_curve
  })

  # subpopulation_curve_plot (plotlyOutput)
  output$subpopulation_curve_plot <- renderPlotly({
    subpopulation_curve_plot(params$curves[[input$subpopulation_curve]],
                             input$subpopulation_size,
                             input$subpopulation_pcnt)
  })

  # params_group_to_cond ====

  observeEvent(redraw_g2c(), {
    sg <- req(isolate(input$popn_subgroup))
    px <- isolate(params)$groups[[sg]]
    conditions <- names(px$conditions)

    # update the condition percentage sliders
    # first, remove the previous elements
    walk(div_slider_treatpath_obs, ~.x$destroy())
    div_slider_treatpath_obs <<- list()

    walk(div_slider_cond_pcnt_obs, ~.x$destroy())
    div_slider_cond_pcnt_obs <<- list()
    removeUI("#div_slider_cond_pcnt > *", TRUE, TRUE)
    # now, add the new sliders

    # create the no mental health group slider
    nmh_slider <- disabled(
      sliderInput(
        "slider_cond_pcnt_no_mh_needs",
        "No Mental Health Needs",
        value = (1 - map_dbl(px$conditions, "pcnt") %>% sum()) * 100,
        min = 0, max = 100, step = 0.01, post = "%"
      )
    )

    # loop over the conditions (and the corresponding max values)
    walk(conditions, function(i) {
      # slider names can't have spaces, replace with _
      slider_name <- gsub(" ", "_", paste0("slider_cond_pcnt_", i))
      slider <- sliderInput(
        slider_name, label = i,
        value = px$conditions[[i]]$pcnt * 100,
        min = 0, max = 100, step = 0.01, post = "%"
      )
      insertUI("#div_slider_cond_pcnt", "beforeEnd", slider)

      div_slider_cond_pcnt_obs[[slider_name]] <<- observeEvent(input[[slider_name]], {
        # can't use the px element here: must use full params
        params$groups[[sg]]$conditions[[i]]$pcnt <- input[[slider_name]] / 100

        # if we have exceeded 100%, reduce each slider evenly to maintain 100%
        isolate({
          # if we are going to reduce a slider by more than its current amount, reduce all the sliders by that amount
          # and then start again with the remaining sliders
          current_conditions <- params$groups[[sg]]$conditions %>%
            names() %>%
            discard(~.x == i)

          repeat {
            # check that we do not exceed 100% for conditions
            pcnt_sum <- params$groups[[sg]]$conditions %>%
              map_dbl("pcnt") %>%
              sum()
            # break out the loop
            if (pcnt_sum <= 1) break

            # get the pcnt's for the "current" conditions
            current_pcnts <- params$groups[[sg]]$conditions[current_conditions] %>%
              map_dbl("pcnt")

            # find the smallest percentage currently
            min_pcnt <- min(current_pcnts)
            # what is(are) the smallest group(s)?
            j <- names(which(current_pcnts == min_pcnt))
            # find the target reduction (either the minimum percentage present, or an equal split of the amount of the
            # sum over 100%)
            tgt_pcnt <- min(min_pcnt, (pcnt_sum - 1) / length(current_conditions))

            # now, reduce the pcnts by the target
            map(current_conditions, function(k) {
              v <- params$groups[[sg]]$conditions[[k]]$pcnt - tgt_pcnt
              params$groups[[sg]]$conditions[[k]]$pcnt <- v
              updateSliderInput(session,
                                gsub(" ", "_", paste0("slider_cond_pcnt_", k)),
                                value = v * 100)
            })

            # remove the smallest group(s) j and loop
            current_conditions <- current_conditions[!current_conditions %in% j]
          }

          updateSliderInput(session,
                            "slider_cond_pcnt_no_mh_needs",
                            value = (1 - pcnt_sum) * 100)
        })
      })
    })

    insertUI("#div_slider_cond_pcnt", "beforeEnd", nmh_slider)

    redraw_c2t(counter$get())
  })

  # params_cond_to_treat ====

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

    # loop over the treatments
    walk(treatments_pathways, function(i) {
      # slider names can't have spaces, replace with _
      ix <- gsub(" ", "_", i)
      split_name <- paste0("numeric_treatpath_split_", ix)

      split <- numericInput(
        split_name,
        label = paste("split", i),
        value = px$treatments[[i]]
      )

      insertUI("#div_slider_treatmentpathway", "beforeEnd", split)

      div_slider_treatpath_obs[[split_name]] <<- observeEvent(input[[split_name]], {
        v <- input[[split_name]]
        params$groups[[sg]]$conditions[[ssc]]$treatments[[i]] <- v
      })
    })

    treat_split_plot <- plotlyOutput("treat_split_plot")
    insertUI("#div_slider_treatmentpathway", "beforeEnd", treat_split_plot)
    output$treat_split_plot <- renderPlotly({
      treatment_split_plot(params$groups[[sg]]$conditions[[ssc]]$treatments)
    })
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
    updateSliderInput(session, "slider_treat_pcnt", value = tx$treat_pcnt * 100)
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

  # slider_treat_pcnt (sliderInput)
  observeEvent(input$slider_treat_pcnt, {
    ttype <- req(input$treatment_type)
    params$treatments[[ttype]]$treat_pcnt <- input$slider_treat_pcnt / 100
  })

  # params_downloads ====

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

  # Model ----

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

  # Results Tab ----

  results_server("results_page", model_output, params)

  # Surge Tabs ----

  # Surge subpopn tab
  surgetab_server("surge_subpopn", model_output, group, "Subpopulation group")

  # Surge conditions tab
  surgetab_server("surge_condition", model_output, condition, "Condition")

  # Surge service tab
  surgetab_server("surge_service", model_output, treatment, "Treatment")

  # Bubble Plot Tab ----

  output$bubble_plot_baselinepopn <- renderPlotly({
    params %>%
      reactiveValuesToList() %>%
      bubble_plot()
  })

  # Graph Tab ----

  graph_server("graph_page", model_output, population_groups, all_conditions, treatments)

}
