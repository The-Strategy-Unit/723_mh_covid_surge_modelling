#' Conditions to Treatments Module
#'
#' A shiny module that renders all of the content for the c2t section in the params page
#'
#' @name c2t_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params,redraw_c2t,popn_subgroup,conditions reactive objects passed in from the params page
#' @param counter the counter object from the params page

#' @rdname c2t_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
c2t_ui <- function(id) {
  tagList(
    selectInput(
      NS(id, "sliders_select_cond"),
      "Condition",
      choices = NULL
    ),
    uiOutput(NS(id, "container"))
  )
}

#' @rdname c2t_module
#' @import shiny
#' @importFrom dplyr %>%
#' @importFrom purrr walk set_names map_dbl map transpose
#' @importFrom shinyjs disabled
c2t_server <- function(id, params, redraw_c2t, counter, popn_subgroup, conditions) {
  moduleServer(id, function(input, output, session) {
    observers <- list()

    observeEvent(conditions(), {
      req(conditions())
      updateSelectInput(session, "sliders_select_cond", choices = conditions())
    })

    observeEvent(input$sliders_select_cond, {
      redraw_c2t(counter$get())
    })

    output$container <- renderUI({
      force(redraw_c2t())
      sg <- req(popn_subgroup())
      isolate({
        ssc <- req(input$sliders_select_cond)

        # destroy previous observers
        walk(observers, ~.x$destroy())

        # now, add the new sliders
        px <- params$groups[[sg]]$conditions[[ssc]]

        # add timestamp to input names
        ts <- as.numeric(Sys.time())

        table_style <- "padding: 0px 5px 0px 0px;"
        x <- px$treatments %>%
          names() %>%
          # loop over the treatments
          map(function(i) {
            # slider names can't have spaces, replace with _
            ix <- gsub(" ", "_", i)

            split_input_name <- paste0("numeric_treat_split_", ix, "_", ts)
            split_input <- numericInput(NS(id, split_input_name), NULL, value = px$treatments[[i]], width = "75px")

            split_pcnt_name <- paste0("pcnt_treat_split_", ix, "_", ts)
            split_pcnt <- textOutput(NS(id, split_pcnt_name), inline = TRUE)

            output[[split_pcnt_name]] <- renderText({
              # the render function hangs around after output has been removed.
              req(sg  %in% names(params$groups),
                  ssc %in% names(params$groups[[sg]]$conditions),
                  i   %in% names(params$groups[[sg]]$conditions[[ssc]]$treatments))

              n <- params$groups[[sg]]$conditions[[ssc]]$treatments[[i]]
              d <- sum(params$groups[[sg]]$conditions[[ssc]]$treatments)

              sprintf("%.1f%%", n / d * 100)
            })

            list(
              table_rows = list(i, split_input, split_pcnt) %>%
                map(tags$td, style = table_style) %>%
                tags$tr(),
              observers = observeEvent(input[[split_input_name]], {
                v <- input[[split_input_name]]
                params$groups[[sg]]$conditions[[ssc]]$treatments[[i]] <- v
              })
            )
          }) %>%
          transpose()

        observers <<- x$observers

        table_header <- list("Treatment", "Split", "Split %") %>%
          map(tags$th, style = table_style) %>%
          tags$tr()

        treat_split_plot <- plotlyOutput(NS(id, "treat_split_plot"))
        output$treat_split_plot <- renderPlotly({
          treatment_split_plot(params$groups[[sg]]$conditions[[ssc]]$treatments)
        })

        tagList(
          tags$table(
            tagList(
              table_header,
              x$table_rows
            )
          ),
          treat_split_plot
        )
      })

    })

  })
}
