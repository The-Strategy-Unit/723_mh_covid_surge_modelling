#' Group to Conditions Module
#'
#' A shiny module that renders all of the content for the g2c section in the params page
#'
#' @name g2c_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params,redraw_g2c,redraw_c2t,popn_subgroup reactive objects passed in from the params page
#' @param counter the counter object from the params page

#' @rdname g2c_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
g2c_ui <- function(id) {
  uiOutput(NS(id, "container"))
}

#' @rdname g2c_module
#' @import shiny
#' @importFrom dplyr %>%
#' @importFrom purrr walk set_names map_dbl map transpose
#' @importFrom shinyjs disabled
g2c_server <- function(id, params, redraw_g2c, redraw_c2t, counter, popn_subgroup) {
  stopifnot("params is not a reactiveValues" = is.reactivevalues(params),
            "redraw_g2c is not a reactive" = is.reactive(redraw_g2c),
            "redraw_c2t is not a reactive" = is.reactive(redraw_c2t),
            "popn_subgroup is not a reative" = is.reactive(popn_subgroup))

  moduleServer(id, function(input, output, session) {
    observers <- list()

    condition_slider_name <- function(condition) {
      # add timestamp to input names
      ts <- as.numeric(Sys.time())
      gsub(" ", "_", paste0("slider_cond_pcnt_", condition, "_", ts))
    }

    output$container <- renderUI({
      # trigger the render by the redraw_g2c() reactive...
      force(redraw_g2c())
      # ...or by the popn_subgroup() reactive
      sg <- req(popn_subgroup())
      # once this has all completed make sure redraw_c2t happens
      redraw_c2t(counter$get())

      isolate({
        condition_names <- names(params$groups[[sg]]$conditions)

        # first, remove the previous sliders and observers
        walk(observers, ~.x$destroy())

        # add timestamp to input names
        ts <- as.numeric(Sys.time())

        # create the no mental health group slider
        nmh_slider <- disabled(
          sliderInput(
            NS(id, paste0("slider_cond_pcnt_no_mh_needs_", ts)),
            "No Mental Health Needs",
            value = 0,
            min = 0, max = 100, step = 0.01, post = "%"
          )
        )

        # when the sliders are updated we need to ensure that the sum of the sliders does not exceed 100%
        observer_handler <- quote({
          conditions <- params$groups[[sg]]$conditions
          conditions[[i]]$pcnt <- input[[slider_name]] / 100

          # if we have exceeded 100%, reduce each slider evenly to maintain 100%
          conditions <- reduce_condition_pcnts(conditions, discard(condition_names, ~.x == i))

          # update the sliders
          walk(condition_names, function(.x) {
            updateSliderInput(session,
                              condition_slider_name(.x),
                              value = conditions[[.x]]$pcnt * 100)
          })

          updateSliderInput(session,
                            "slider_cond_pcnt_no_mh_needs",
                            value = (1 - sum(map_dbl(conditions, "pcnt"))) * 100)

          # update the params object
          params$groups[[sg]]$conditions <- conditions
        })

        # loop over conditions and create the sliders and observers
        x <- condition_names %>%
          set_names() %>%
          map(function(i) {
            slider_name <- condition_slider_name(i)

            list(
              sliders = sliderInput(
                NS(id, slider_name), label = i,
                value = params$groups[[sg]]$conditions[[i]]$pcnt * 100,
                min = 0, max = 100, step = 0.01, post = "%"
              ),
              observers = observeEvent(
                input[[slider_name]],
                observer_handler,
                handler.quoted = TRUE
              )
            )
          }) %>%
          transpose()

        observers <<- x$observers

        tagList(x$sliders, nmh_slider)
      })
    })
  })
}
