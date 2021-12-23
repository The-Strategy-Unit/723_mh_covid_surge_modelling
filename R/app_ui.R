#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
#' @importFrom shinyjs useShinyjs
#' @importFrom plotly plotlyOutput
app_ui <- function(request) {
  # hack the header
  header <- dashboardHeader(
    title = "MH Surge Modelling"
  )

  header$children[[3]]$children[[3]]$children[[1]] <- tags$img(
    src = "https://www.strategyunitwm.nhs.uk/themes/custom/ie_bootstrap/logo.svg",
    title = "The Strategy Unit",
    alt = "The Strategy Unit Logo",
    align = "right",
    height = "40"
  )

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    tags$link(rel = "stylesheet", type = "text/css", href = "www/skin-su.css"),
    # List the first level UI elements here
    dashboardPage(
      header,
      dashboardSidebar(
        sidebarMenu(
          menuItem(
            "Home",
            tabName = "home",
            icon = icon("home"),
            selected = TRUE
          ),
          menuItem(
            "Parameters",
            tabName = "params",
            icon = icon("tachometer-alt")
          ),
          menuItem(
            "Demand",
            tabName = "demand",
            icon = icon("history")
          ),
          menuItem(
            "Results",
            tabName = "results",
            icon = icon("th")
          ),
          menuItem(
            "Surge Demand",
            startExpanded = TRUE,
            menuSubItem(
              "Population Group",
              tabName = "surgetab_subpopn"
            ),
            menuSubItem(
              "Condition",
              tabName = "surgetab_condition"
            ),
            menuSubItem(
              "Service",
              tabName = "surgetab_service"
            )
          )
        )
      ),
      dashboardBody(
        tabItems(
          tabItem("home", home_ui("home_page")),
          tabItem("params", params_ui("params_page")),
          tabItem("demand", demand_ui("demand_page")),
          tabItem("results", results_ui("results_page")),
          tabItem("surgetab_subpopn", surgetab_ui("surge_subpopn")),
          tabItem("surgetab_condition", surgetab_ui("surge_condition")),
          tabItem("surgetab_service", surgetab_ui("surge_service"))
        )
      ),
      useShinyjs()
    )
  ) %>%
    replace_bootstrap_cols(from = "sm", to = "lg")
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
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
      app_title = "Mental Health Surge Modelling | The Strategy Unit"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
