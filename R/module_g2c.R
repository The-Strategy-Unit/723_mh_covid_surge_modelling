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
  tags$div(id = NS(id, "container"))
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

    container_id <- paste0("#", NS(id, "container"))

    observeEvent(redraw_g2c(), {
      sg <- req(popn_subgroup())
      px <- params$groups[[sg]]
      conditions <- names(px$conditions)

      # first, remove the previous sliders and observers
      walk(observers, ~.x$destroy())
      removeUI(paste(container_id, "> *"), TRUE, TRUE)

      # create the no mental health group slider
      nmh_slider <- disabled(
        sliderInput(
          NS(id, "slider_cond_pcnt_no_mh_needs"),
          "No Mental Health Needs",
          value = (1 - map_dbl(px$conditions, "pcnt") %>% sum()) * 100,
          min = 0, max = 100, step = 0.01, post = "%"
        )
      )

      # when the sliders are updated we need to ensure that the sum of the sliders does not exceed 100%
      observer_handler <- quote({
        # can't use the px element here: must use full params
        params$groups[[sg]]$conditions[[i]]$pcnt <- input[[slider_name]] / 100

        # if we have exceeded 100%, reduce each slider evenly to maintain 100%
        # if we are going to reduce a slider by more than its current amount, reduce all the sliders by that
        # amount and then start again with the remaining sliders
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
          walk(current_conditions, function(k) {
            v <- params$groups[[sg]]$conditions[[k]]$pcnt - tgt_pcnt
            params$groups[[sg]]$conditions[[k]]$pcnt <- v
            updateSliderInput(session,
                              gsub(" ", "_", paste0("slider_cond_pcnt_", k)),
                              value = v * 100)
          })

          # remove the smallest group(s) j and loop
          current_conditions <- current_conditions[!current_conditions %in% j]
        }

        updateSliderInput(session, "slider_cond_pcnt_no_mh_needs", value = (1 - pcnt_sum) * 100)
      })

      # loop over conditions and create the sliders and observers
      x <- conditions %>%
        set_names() %>%
        map(function(i) {
          # slider names can't have spaces, replace with _
          slider_name <- gsub(" ", "_", paste0("slider_cond_pcnt_", i))

          list(
            sliders = sliderInput(
              NS(id, slider_name), label = i,
              value = px$conditions[[i]]$pcnt * 100,
              min = 0, max = 100, step = 0.01, post = "%"
            ),
            observers = observeEvent(input[[slider_name]], observer_handler, handler.quoted = TRUE)
          )
        }) %>%
        transpose()

      insertUI(container_id, "beforeEnd", tagList(x$sliders, nmh_slider))
      observers <<- x$observers

      redraw_c2t(counter$get())
    })
  })
}
