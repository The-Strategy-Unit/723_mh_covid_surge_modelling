library(shiny)

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
        title = "Upload JSON parameters",
        width = 12,
        fileInput(
          "user_upload_json",
          label = NULL,
          multiple = FALSE,
          accept = ".json",
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
      selectInput(
        "services",
        "Service",
        choices = NULL
      )
    ),
    box(
      valueBoxOutput("total_referrals"),
      valueBoxOutput("total_demand"),
      valueBoxOutput("total_newpatients")
    )
  ),
  fluidRow(
    box(withSpinner(plotlyOutput("referrals_plot"))),
    box(withSpinner(plotlyOutput("demand_plot")))
  )
)

dashboardPage(
  dashboardHeader(title = "Mersey Care MH Surge Modelling"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Parameters", tabName = "params", icon = icon("dashboard"), selected = TRUE),
      menuItem("Results", tabName = "results", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      body_report,
      body_params
    )
  )
)
