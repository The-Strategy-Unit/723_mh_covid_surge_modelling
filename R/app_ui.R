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
  params_upload_params <- primary_box(
    title = "Upload parameters",
    width = 12,
    fileInput(
      "user_upload_xlsx",
      label = NULL,
      multiple = FALSE,
      accept = ".xlsx",
      placeholder = "Previously downloaded parameters"
    )
  )

  params_population_groups <- primary_box(
    title = "Population Groups",
    width = 12,
    selectInput(
      "popn_subgroup",
      "Choose subgroup",
      choices = NULL
    ),
    numericInput(
      "subpopulation_size",
      "Subpopulation Figure",
      value = NULL, step = 100
    ),
    sliderInput(
      "subpopulation_pcnt",
      "% in subgroup",
      value = 100, min = 0, max = 100, step = 1,
      post = "%"
    ),
    textOutput("subpopulation_size_pcnt"),
    selectInput(
      "subpopulation_curve",
      "Choose scenario",
      choices = NULL
    ),
    plotlyOutput(
      "subpopulation_curve_plot",
      height = "100px"
    )
  )

  params_group_to_cond <- primary_box(
    title = "Condition group of sub-group population",
    width = 12,
    div(id = "div_slider_cond_pcnt")
  )

  params_cond_to_treat <- primary_box(
    title = "People being treated of condition group",
    width = 12,
    selectInput(
      "sliders_select_cond",
      "Condition",
      choices = NULL
    ),
    div(id = "div_slider_treatmentpathway"),
  )

  params_demand <- primary_box(
    title = "Treatment",
    width = 12,
    selectInput(
      "treatment_type",
      "Treatment type",
      choices = NULL
    ),
    sliderInput(
      "treatment_appointments",
      "Average demand per person",
      min = 0, max = 10, step = .01, value = 0
    ),
    sliderInput(
      "slider_success",
      "Success % of Treatment",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      "slider_tx_months",
      "Decay Months",
      min = 0, max = 24, value = 1, step = 0.1
    ),
    sliderInput(
      "slider_decay",
      "Decay Percentage",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    ),
    sliderInput(
      "slider_treat_pcnt",
      "Treating Percentage",
      min = 0, max = 100, value = 0, step = 0.01, post = "%"
    )
  )

  params_downloads <- primary_box(
    title = "Download's",
    width = 12,
    downloadButton(
      "download_params",
      "Download current parameters"
    ),
    downloadButton(
      "download_output",
      "Download model output"
    )
  )

  body_params <- tabItem(
    "params",
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
  )

  # Results Tab ----

  results_services <- primary_box(
    title = "Service",
    width = 2,
    selectInput(
      "services",
      "Service",
      choices = NULL
    ),
    radioButtons(
      "download_choice",
      "Download option",
      c("Selected" = "selected", "All" = "all"),
      inline = TRUE
    ),
    downloadButton("download_results")
  )

  results_value_boxes <- primary_box(
    title = "Summary",
    width = 5,
    valueBoxOutput("total_referrals"),
    valueBoxOutput("total_demand"),
    valueBoxOutput("total_newpatients")
  )

  results_popgroups <- primary_box(
    title = "Population group source of 'surge'",
    width = 5,
    withSpinner(
      plotlyOutput(
        "results_popgroups"
      )
    )
  )

  results_referrals_plot <- primary_box(
    title = "Modelled Referrals",
    withSpinner(
      plotlyOutput(
        "referrals_plot"
      )
    )
  )

  results_demand_plot <- primary_box(
    title = "Modelled Demand",
    withSpinner(
      plotlyOutput(
        "demand_plot"
      )
    )
  )

  results_combined_plot <- primary_box(
    title = "Combined Modelled and Projected Patients in Service",
    withSpinner(
      plotlyOutput(
        "combined_plot",
        height = "600px"
      )
    ),
    width = 12
  )

  results_graph <- primary_box(
    title = "Flows from population groups to conditions to services",
    withSpinner(
      plotlyOutput(
        "graph",
        height = "600px"
      )
    ),
    width = 12
  )

  body_results <- tabItem(
    "results",
    fluidRow(
      results_services,
      results_value_boxes,
      results_popgroups
    ),
    fluidRow(
      results_referrals_plot,
      results_demand_plot,
      results_combined_plot,
      results_graph
    )
  )

  # Surge Subpopulation Tab ----

  body_surgesubpopn <- tabItem(
    "surgetab_subpopn",
    fluidRow(
      box(
        tableOutput("surge_subpopn_table")
      ),
      box(
        withSpinner(
          plotlyOutput(
            "surge_subpopn_plot",
            height = "600px"
          )
        )
      )
    )
  )

  # Surge Condition Tab ----

  body_surgecondition <- tabItem(
    "surgetab_condition",
    fluidRow(
      box(
        tableOutput("surge_condition_table")
      ),
      box(
        withSpinner(
          plotlyOutput(
            "surge_condition_plot",
            height = "600px"
          )
        )
      )
    )
  )

  # Surge Treatment Tab ----

  body_surgetreatment <- tabItem(
    "surgetab_service",
    fluidRow(
      box(
        tableOutput("surge_service_table")
      ),
      box(
        withSpinner(
          plotlyOutput(
            "surge_service_plot",
            height = "600px"
          )
        )
      )
    )
  )

  # Surge Bubbleplot Tab ----

  body_bubbleplot <- tabItem(
    "bubbleplot",
    plotlyOutput(
      "bubble_plot_baselinepopn",
      height = "900px"
    )
  )

  # Surge Graph Tab ----

  graph_groups <- primary_box(
    title = "Filter Groups",
    width = 4,
    selectInput(
      "graphpage_select_groups",
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_conditions <- primary_box(
    title = "Filter Conditions",
    width = 4,
    selectInput(
      "graphpage_select_conditions",
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_services <- primary_box(
    title = "Filter Services",
    width = 4,
    selectInput(
      "graphpage_select_treatments",
      label = NULL,
      choices = NA,
      multiple = TRUE
    )
  )

  graph_graph <- primary_box(
    title = "Flows from population groups to conditions to services",
    width = 12,
    withSpinner(
      plotlyOutput(
        "graphpage_graph",
        height = "600px"
      )
    )
  )

  body_graph <- tabItem(
    "graphpage",
    fluidRow(
      graph_groups,
      graph_conditions,
      graph_services,
      graph_graph
    )
  )

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
            tabName = "graphpage"
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
