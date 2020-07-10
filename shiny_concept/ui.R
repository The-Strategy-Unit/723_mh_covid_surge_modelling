library(shiny)

shinyUI(navbarPage(
  title = "Covid Surge MH Modelling",
  tabPanel(
    "Plot",
    tags$style(css_table),
    sidebarPanel(
      panel(
        heading = "Population Groups",
        selectInput(
          "popn_subgroup",
          "Choose subgroup",
          choices = NA
        ),
        numericInput(
          "totalmonths",

          "Months in Model",
          min = 1,
          max = 24,
          value = 24,
          step = 1
        ),
        fluidRow(column(
          6,
          numericInput(
            "subpopulation_size",
            "Subpopulation Figure",
            value = NA,
            step = 100
          )
        ),
        column(
          6,
          numericInput(
            "subpopulation_pcnt",
            "% in subgroup",
            value = 100,
            min = 0,
            max = 100,
            step = 1
          )
        )),
        selectInput(
          "subpopulation_curve",
          "Choose scenario",
          selected = NA,
          choices = NA
        )
      ),
      panel(
        heading = "Treatments",
        selectInput(
          "sliders_select",
          label = "Group-Treatment-Cond. combination",
          choices = NA
        ),
        paste0(
          "Idea here is to have the same sliders for each of the treatment ",
          "groups, but the figures will change accordingly based on the ",
          "selected group in the dropbox above and these will modify the ",
          "parameters/graphs"
        ),
        sliderInput(
          "slider_pcnt",
          "Prevalence in sub-population",
          min = 0,
          max = 1,
          value = 0.01
        ),
        sliderInput(
          "slider_treat",
          "% Requiring Treatment",
          min = 0,
          max = 1,
          value = 0.01
        ),
        sliderInput(
          "slider_success",
          "Success % of Treatment",
          min = 0,
          max = 1,
          value = 0.01
        )
      ),
      panel(
        heading = "Demand",
        selectInput(
          "treatment_type",
          "Treatment type",
          choices = NA
        ),
        sliderInput(
          "treatment_appointments",
          "Average demand per person",
          min = 0,
          max = 10,
          step = .01,
          value = 0
        )
      ),
      downloadButton("download_params", "Download current parameters")
    ),
    mainPanel(
      selectInput(
        "popn_subgroup_plot",
        "Choose subgroups to plot",
        choices = NA,
        multiple = T
      ),
      withSpinner(plotlyOutput("pop_plot")),
      withSpinner(plotlyOutput("demand_plot"))
    )
  ),
  tabPanel(
    "Example Distribution",
    verbatimTextOutput("unemployed_y_vec"),
    verbatimTextOutput("bereaved_y_vec"),
    verbatimTextOutput("o_print_test")
  ),
  tabPanel(
    "Demand",
    sidebarPanel(
      selectInput(
        "demand_treatment_type",
        "Treatment type",
        choices = NA
      ),
      sliderInput(
        "demand_treatment_demand",
        "Average # appointments per person",
        min = 0,
        max = 10,
        step = .01,
        value = 0
      )
    ),
    mainPanel(
      plotlyOutput("demand_demand_plot"),
      tableOutput("demand_table")
    )
  )
))
