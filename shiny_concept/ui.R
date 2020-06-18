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
                     selectInput("sliders_select", label = "Group-Treatment-Cond. combination", choices = ""),
                     "Idea here is to have the same sliders for each of the treatment groups, but the figures will change accordingly based on the selected group in the dropbox above and these will modify the parameters/graphs",
                     sliderInput("pcnt", "pcnt", min = 0, max = 1, value = 0.01),
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
                                 value = 30)),
                     mainPanel(plotlyOutput("myplot"),
                               plotlyOutput("myplot2"))
                   ))

  )
