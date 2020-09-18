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
            "Treemap",
            tabName = "treemap"
          ),
          menuItem(
            "Graph",
            tabName = "graph"
          )
        )
      ),
      dashboardBody(
        tabItems(
          tabItem("params", params_ui("params_page")),
          tabItem("results", results_ui("results_page")),
          tabItem("surgetab_subpopn", surgetab_ui("surge_subpopn")),
          tabItem("surgetab_condition", surgetab_ui("surge_condition")),
          tabItem("surgetab_service", surgetab_ui("surge_service")),
          tabItem("treemap", treemap_ui("treemap_page")),
          tabItem("graph", graph_ui("graph_page"))
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
