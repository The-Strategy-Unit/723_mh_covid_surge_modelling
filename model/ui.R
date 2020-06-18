#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse, quietly = TRUE)
library(deSolve)
library(patchwork)

source("../half_life_factor.R")
source("../run_model.R")

# Params ----
param_csv <- read_csv("../sample_params.csv", col_types = "cccddddd") %>%
    unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
    mutate_at("decay", ~half_life_factor(days, .x)) %>%
    select(-days)

params <- param_csv %>%
    select(pcnt:decay) %>%
    as.matrix() %>%
    t()
colnames(params) <- param_csv$rowname

# Simulated demand surges ----
new_potential <- list(
    unemployed = approxfun(
        c(0, 4, 6, 10, 16),
        c(100, 2000, 8000, 6000, 0),
        rule = 2
    ),
    bereaved = approxfun(
        c(0, 4, 6, 10, 16),
        c(0, 100, 500, 2000, 1500),
        rule = 2
    )
)

inputs_required <- colnames(params) %>%
    map(~list(
        sliderInput(paste0(.x, "_pcnt"),
                    paste0(.x, "_pcnt"),
                    min = 0,
                    max = 100,
                    step = 0.1,
                    value = params["pcnt", .x]*100),
        sliderInput(paste0(.x, "_treat"),
                    paste0(.x, "_treat"),
                    min = 0,
                    max = 100,
                    step = 0.1,
                    value = params["treat", .x]*100)
        )) %>%
    flatten()

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("COVID-19 Surge Modelling"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            inputs_required,
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
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot1"),
            plotOutput("plot2")
        )
    )
))
