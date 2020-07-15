library(shiny)

params_population_groups <- box(
  title = "Population Groups",
  width = 4,
  selectInput(
    "popn_subgroup",
    "Choose subgroup",
    choices = NA
  ),
  numericInput(
    "subpopulation_size",
    "Subpopulation Figure",
    value = NA, step = 100
  ),
  numericInput(
    "subpopulation_pcnt",
    "% in subgroup",
    value = 100, min = 0, max = 100, step = 1
  ),
  selectInput(
    "subpopulation_curve",
    "Choose scenario",
    selected = NA, choices = NA
  )
)

params_treatments <- box(
  title = "Treatments",
  width = 4,
  selectInput(
    "sliders_select_cond",
    "Condition",
    choices = NA
  ),
  selectInput(
    "sliders_select_treat",
    "Treatment Pathway",
    choices = NA
  ),
  sliderInput(
    "slider_pcnt",
    "Prevalence in sub-population",
    min = 0, max = 100, value = 0, step = 0.01, post = "%"
  ),
  sliderInput(
    "slider_treat",
    "% Requiring Treatment",
    min = 0, max = 100, value = 0, step = 0.01, post = "%"
  ),
  sliderInput(
    "slider_success",
    "Success % of Treatment",
    min = 0, max = 100, value = 0, step = 0.01, post = "%"
  )
)

params_demand <- box(
  title = "Demand",
  width = 4,
  selectInput(
    "treatment_type",
    "Treatment type",
    choices = NA
  ),
  sliderInput(
    "treatment_appointments",
    "Average demand per person",
    min = 0, max = 10, step = .01, value = 0
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
    params_population_groups,
    params_treatments,
    params_demand
  )
)

body_report <- tabItem(
  "results",
  fluidRow(
    box(selectInput("services", "Service", choices = NA))
    ,
    box(fluidRow(column(
      width = 6,
      valueBoxOutput("total_referrals"),
      valueBoxOutput("total_demand"),
      valueBoxOutput("total_newpatients")
    )),
    fluidRow(column(width = 6)))
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
