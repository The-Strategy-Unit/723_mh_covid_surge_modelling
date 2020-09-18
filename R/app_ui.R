#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
#' @importFrom shinyjs useShinyjs
#' @importFrom plotly plotlyOutput
#' @noRd
app_ui <- function(request) {

  # Params Tab ----
  body_params <- tabItem("params", params_ui("params_page"))

  # Results Tab ----
  body_results <- tabItem("results", results_ui("results_page"))

  # Surge Tabs ----
  # Subpopulation
  body_surgesubpopn <- tabItem("surgetab_subpopn", surgetab_ui("surge_subpopn"))
  # Condition
  body_surgecondition <- tabItem("surgetab_condition", surgetab_ui("surge_condition"))
  # Treatment
  body_surgetreatment <- tabItem("surgetab_service", surgetab_ui("surge_service"))

  # Bubbleplot Tab ----
  body_bubbleplot <- tabItem(
    "bubbleplot",
    plotlyOutput(
      "bubble_plot_baselinepopn",
      height = "900px"
    )
  )

  # Graph Tab ----
  body_graph <- tabItem("graph", graph_ui("graph_page"))

  # Render Page ----

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here
    dashboardPage(
      dashboardHeader(
        title = "Mersey Care MH Surge Modelling"
      ),
      dashboardSidebar(
        sidebarMenu(
          menuItem(
            "Parameters",
            tabName = "params",
            icon = icon("dashboard"),
            selected = TRUE
          ),
          menuItem(
            "Results",
            tabName = "results",
            icon = icon("th")
          ),
          menuItem(
            "Surge Demand - Population Group",
            tabName = "surgetab_subpopn"
          ),
          menuItem(
            "Surge Demand - Condition",
            tabName = "surgetab_condition"
          ),
          menuItem(
            "Surge Demand - Service",
            tabName = "surgetab_service"
          ),
          menuItem(
            "Bubble Plot Test",
            tabName = "bubbleplot"
          ),
          menuItem(
            "Graph",
            tabName = "graph"
          )
        )
      ),
      dashboardBody(
        tabItems(
          body_params,
          body_results,
          body_surgesubpopn,
          body_surgecondition,
          body_surgetreatment,
          body_bubbleplot,
          body_graph
        )
      ),
      useShinyjs()
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom htmltools tags
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {

  add_resource_path(
    "www", app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "mhSurgeModelling"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
