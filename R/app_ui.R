#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
#' @importFrom plotly plotlyOutput
#' @noRd
app_ui <- function(request) {

  params_population_groups <- box(
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
    numericInput(
      "subpopulation_pcnt",
      "% in subgroup",
      value = 100, min = 0, max = 100, step = 1
    ),
    selectInput(
      "subpopulation_curve",
      "Choose scenario",
      choices = NULL
    )
  )

  params_group_to_cond <- box(
    title = "Condition group of sub-group population",
    width = 12,
    div(id = "div_slider_cond_pcnt")
  )

  params_cond_to_treat <- box(
    title = "People being treated of condition group",
    width = 12,
    selectInput(
      "sliders_select_cond",
      "Condition",
      choices = NULL
    ),
    div(id = "div_slider_treatmentpathway"),
  )

  params_demand <- box(
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
        4,
        box(
          title = "Upload parameters",
          width = 12,
          fileInput(
            "user_upload_xlsx",
            label = NULL,
            multiple = FALSE,
            accept = ".xlsx",
            placeholder = "Previously downloaded parameters"
          )
        ),
        params_population_groups
      ),
      column(4, params_group_to_cond, params_cond_to_treat),
      column(4, params_demand)
    )
  )

  body_report <- tabItem(
    "results",
    fluidRow(
      box(
        width = 2,
        selectInput(
          "services",
          "Service",
          choices = NULL
        )
      ),
      box(
        width = 5,
        valueBoxOutput("total_referrals"),
        valueBoxOutput("total_demand"),
        valueBoxOutput("total_newpatients")
      ),
      box(
        width = 5,
        withSpinner(
          plotlyOutput(
            "results_popgroups"
          )
        ),
        title = "Population group source of 'surge'",
        solidHeader = TRUE,
        status = "primary"
      )
    ),
    fluidRow(
      box(
        withSpinner(
          plotlyOutput(
            "referrals_plot"
          )
        )
      ),
      box(
        withSpinner(
          plotlyOutput(
            "demand_plot"
          )
        )
      ),
      box(
        withSpinner(
          plotlyOutput(
            "graph",
            height = "600px"
          )
        ),
        width = 12
      ),
      box(
        withSpinner(
          plotlyOutput(
            "combined_plot",
            height = "600px"
          )
        ),
        width = 12
      )
    )
  )

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

  body_bubbleplot <- tabItem(
    "bubbleplot",
    plotlyOutput(
      "bubble_plot_baselinepopn",
      height = "900px"
    )
  )

  body_graph <- tabItem(
    "graphpage",
    fluidRow(
      box(
        selectInput(
          "graphpage_select_groups",
          "Filter Groups",
          choices = NA,
          multiple = TRUE
        ),
        width = 4
      ),
      box(
        selectInput(
          "graphpage_select_conditions",
          "Filter Conditions",
          choices = NA,
          multiple = TRUE
        ),
        width = 4
      ),
      box(
        selectInput(
          "graphpage_select_treatments",
          "Filter Treatments",
          choices = NA,
          multiple = TRUE
        ),
        width = 4
      ),
      box(
        withSpinner(
          plotlyOutput(
            "graphpage_graph",
            height = "600px"
          )
        ),
        width = 12
      )
    )
  )

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
          body_report,
          body_surgesubpopn,
          body_surgecondition,
          body_surgetreatment,
          body_bubbleplot,
          body_graph
        )
      )
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
