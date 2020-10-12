#' Params Module
#'
#' A shiny module that renders all of the content for the params page.
#'
#' @name params_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params,model_output, reactive objects passed in from the main server

#' @rdname params_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
params_ui <- function(id) {
  params_upload_params <- primary_box(
    title = "Upload parameters",
    width = 12,
    fileInput(
      NS(id, "user_upload_xlsx"),
      label = NULL,
      multiple = FALSE,
      accept = ".xlsx",
      placeholder = "Previously downloaded parameters"
    ),
    actionLink(
      NS(id, "upload_params_help"),
      "",
      icon("question")
    )
  )

  params_population_groups <- primary_box(
    title = "Population Groups",
    width = 12,
    selectInput(
      NS(id, "popn_subgroup"),
      "Choose subgroup",
      choices = NULL
    ),
    numericInput(
      NS(id, "subpopulation_size"),
      "Subpopulation Figure",
      value = NULL, step = 100
    ),
    sliderInput(
      NS(id, "subpopulation_pcnt"),
      "% in subgroup",
      value = 100, min = 0, max = 100, step = 1,
      post = "%"
    ),
    textOutput(NS(id, "subpopulation_size_pcnt")),
    selectInput(
      NS(id, "subpopulation_curve"),
      "Choose scenario",
      choices = NULL
    ),
    plotlyOutput(
      NS(id, "subpopulation_curve_plot"),
      height = "100px"
    ),
    actionLink(
      NS(id, "population_group_help"),
      "",
      icon("question")
    )
  )

  params_group_to_cond <- primary_box(
    title = "Condition group of sub-group population",
    width = 12,
    div(id = "div_slider_cond_pcnt"),
    actionLink(
      NS(id, "group_to_cond_params_help"),
      "",
      icon("question")
    )
  )

  params_cond_to_treat <- primary_box(
    title = "People being treated of condition group",
    width = 12,
    selectInput(
      NS(id, "sliders_select_cond"),
      "Condition",
      choices = NULL
    ),
    div(id = "div_slider_treatmentpathway"),
    actionLink(
      NS(id, "cond_to_treat_params_help"),
      "",
      icon("question")
    )
  )

  params_demand <- primary_box(
    title = "Treatment",
    width = 12,
    selectInput(
      NS(id, "treatment_type"),
      "Treatment type",
      choices = NULL
    ),
    sliderInput(
      NS(id, "treatment_appointments"),
      "Average demand per person",
      min = 0, max = 10, step = .01, value = 0
    ),
    sliderInput(
      NS(id, "slider_success"),
      "Success % of Treatment",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      NS(id, "slider_tx_months"),
      "Decay Months",
      min = 0, max = 24, value = 1, step = 0.1
    ),
    sliderInput(
      NS(id, "slider_decay"),
      "Decay Percentage",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      NS(id, "slider_treat_pcnt"),
      "Treating Percentage",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    actionLink(
      NS(id, "treatment_params_help"),
      "",
      icon("question")
    )
  )

  params_downloads <- primary_box(
    title = "Download's",
    width = 12,
    downloadButton(
      NS(id, "download_params"),
      "Download current parameters"
    ),
    downloadButton(
      NS(id, "download_output"),
      "Download model output"
    ),
    actionLink(
      NS(id, "download_params_help"),
      "",
      icon("question")
    )
  )

  fluidRow(
    column(
      3,
      params_upload_params,
      params_population_groups
    ),
    column(3, params_group_to_cond),
    column(3, params_cond_to_treat),
    column(
      3,
      params_demand,
      params_downloads
    )
  )
}

#' @rdname params_module
#' @import shiny
#' @importFrom shinyjs disabled
#' @importFrom dplyr %>%
#' @importFrom purrr walk discard map_dbl map iwalk
#' @importFrom jsonlite read_json
#' @importFrom utils write.csv
#' @importFrom shinyWidgets ask_confirmation
params_server <- function(id, params, model_output) {
  stopifnot("params must be a reactive values" = is.reactivevalues(params),
            "model_output must be a reactive" = is.reactive(model_output))

  moduleServer(id, function(input, output, session) {
    counter <- methods::new("Counter")

    population_groups <- reactiveVal()
    treatments <- reactiveVal()
    curves <- reactiveVal()

    # initialise reactiveVals on load
    params_server_init <- observe({
      population_groups(names(params$groups))
      treatments(names(params$treatments))
      curves(names(params$curves))
      # remove initialiser
      params_server_init$destroy()
    })

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

      # if the treatment selected is the first one, and this is replaced, the values don't update correctly
      u <- counter$get()

      redraw_dropdowns(u)

      params$groups <- new_params$groups
      params$treatments <- new_params$treatments
      params$curves <- new_params$curves
      params$demand <- new_params$demand

      population_groups(names(new_params$groups))
      treatments(names(new_params$treatments))
      curves(names(new_params$curves))

      redraw_treatments(u)
      redraw_groups(u)
    })

    # Update main select options

    observe({
      # trigger update of selects, even if the choices haven't changed
      force(redraw_dropdowns())

      updateSelectInput(session, "popn_subgroup", choices = population_groups())
      updateSelectInput(session, "subpopulation_curve", choices = curves())
      updateSelectInput(session, "treatment_type", choices = treatments())
    })

    # population_groups ====

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

    # group_to_cond ====

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
          NS(id, "slider_cond_pcnt_no_mh_needs"),
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
          NS(id, slider_name), label = i,
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

    # cond_to_treat ====

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
          NS(id, split_name),
          label = paste("split", i),
          value = px$treatments[[i]]
        )

        insertUI("#div_slider_treatmentpathway", "beforeEnd", split)

        div_slider_treatpath_obs[[split_name]] <<- observeEvent(input[[split_name]], {
          v <- input[[split_name]]
          params$groups[[sg]]$conditions[[ssc]]$treatments[[i]] <- v
        })
      })

      treat_split_plot <- plotlyOutput(NS(id, "treat_split_plot"))
      insertUI("#div_slider_treatmentpathway", "beforeEnd", treat_split_plot)
      output$treat_split_plot <- renderPlotly({
        treatment_split_plot(params$groups[[sg]]$conditions[[ssc]]$treatments)
      })
    })

    # demand ====

    # treatment_type (selectInput)
    observeEvent(input$treatment_type, {
      redraw_treatments(counter$get())
    })

    observeEvent(redraw_treatments(), {
      # resolves issue #90: if a new params file is uploaded, and the first treatment is renamed, then the value of
      # input$treatment_type will be the first value from the old params file. This handles this issue by skipping this
      # section (redraw_treatments() is called again and this code succeeds then)
      if (req(input$treatment_type) %in% names(params$treatments)) {
        tx <- params$treatments[[req(input$treatment_type)]]
        updateSliderInput(session, "treatment_appointments", value = tx$demand)
        updateSliderInput(session, "slider_success", value = tx$success * 100)
        updateSliderInput(session, "slider_tx_months", value = tx$months)
        updateSliderInput(session, "slider_decay", value = tx$decay * 100)
        updateSliderInput(session, "slider_treat_pcnt", value = tx$treat_pcnt * 100)
      }
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

    # downloads ====

    # download_params (downloadButton)
    output$download_params <- downloadHandler(
      "params.xlsx",
      function(file) {
        params_to_xlsx(params, file)
      }
    )

    # download_output (downloadButton)
    output$download_output <- downloadHandler(
      function() paste0("model_run_", format(Sys.time(), "%Y-%m-%d_%H%M%S"), ".csv"),
      function(file) {
        download_output(model_output(), params) %>%
          write.csv(file, row.names = FALSE)
      },
      "text/csv"
    )

    # help ====

    # load in the params help file
    app_sys("app/data/params_help.json") %>%
      read_json(TRUE) %>%
      iwalk(function(data, input_name) {
        # extract the text field. each line of text is converted to a paragraph. if that paragraph starts with a ":",
        # then we put the text before the ":" in bold text, followed by the rest of the text.
        text <- data$text %>%
          strsplit(": ") %>%
          map(~if (length(.x) >= 2) {
            tags$p(tags$strong(.x[[1]]), paste(.x[-1], collapse = " "))
          } else {
            tags$p(.x)
          })

        # observe the event of the help button being pressed, and show an ask_confirmation
        observeEvent(input[[input_name]], {
          ask_confirmation(
            paste0(input_name, "_box"),
            data$title,
            tagList(text),
            "question",
            "ok",
            closeOnClickOutside = TRUE,
            showCloseButton = FALSE,
            html = TRUE
          )
        })
      })

  })
}
