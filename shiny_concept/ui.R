library(shiny)

shinyUI(

  navbarPage(title = "Covid Surge MH Modelling",
                   tabPanel(
                     "Plot",
                     tags$style(css_table),
                     sidebarPanel(fileInput(
                       "file1",
                       "Upload CSV with parameters",
                       accept = c("text/csv",
                                  "text/comma-separated-values,text/plain",
                                  ".csv")
                     ),
                     tableOutput("contents"),
                     numericInput("totalmonths", "Months in Model", value = 23, step = 1),
                     fluidRow(column(6, numericInput("subpopulation_figure", "Subpopulation Figure", 10000, step = 100)),
                              column(6, numericInput("pct_unemployed", "% in unemployed cat.", 80, step = 1))
                              ),
                     selectInput("scenario", "Choose scenario", choices = c("Sudden shock", "Follow the curve", "Shallow mid-term", "Sustained impact")),
                     selectInput(
                       "sliders_select",
                       label = "Group-Treatment-Cond. combination",
                       choices = c(
                         "unemployed_cmht_stress",
                         "unemployed_cmht_insomnia",
                         "unemployed_iapt_anxiety",
                         "unemployed_iapt_depression",
                         "unemployed_psych-liason_suicide",
                         "bereaved_cmht_bereavement"
                       )
                     ),
                     "Idea here is to have the same sliders for each of the treatment groups, but the figures will change accordingly based on the selected group in the dropbox above and these will modify the parameters/graphs",
                     sliderInput("slider_pcnt", "Prevalence in sub-population", min = 0, max = 1, value = 0.01),
                     sliderInput("slider_treat", "% Requiring Treatment", min = 0, max = 1, value = 0.01),
                     sliderInput("slider_success", "Success % of Treatment", min = 0, max = 1, value = 0.01),
                     sliderInput("cmht_appointments",
                                 "Average # CMHT appointments per person",
                                 min = 0,
                                 max = 10,
                                 step = 1,
                                 value = 3),
                     sliderInput("iapt_appointments",
                                 "Average # IAPT appointments per person",
                                 min = 0,
                                 max = 10,
                                 step = 1,
                                 value = 6),
                     sliderInput("psych-liason_appointments",
                                 "Average # Psych-Liason appointments per person",
                                 min = 0,
                                 max = 60,
                                 step = 1,
                                 value = 30),
                     verbatimTextOutput("sampletext")),
                     mainPanel(plotlyOutput("myplot"),
                               plotlyOutput("myplot2"))
                   ),
             tabPanel("Example Distribution",
                      verbatimTextOutput("unemployed_y_vec"),
                      verbatimTextOutput("bereaved_y_vec"))
             )

  )
