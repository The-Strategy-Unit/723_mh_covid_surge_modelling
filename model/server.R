#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse, quietly = TRUE)
library(deSolve)
library(patchwork)

source("half_life_factor.R")
source("run_model.R")

# Params ----
param_csv <- read_csv("sample_params.csv", col_types = "cccddddd") %>%
    unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
    mutate_at("decay", ~half_life_factor(days, .x)) %>%
    select(-days)

params <- param_csv %>%
    select(pcnt:decay) %>%
    as.matrix() %>%
    t()
colnames(params) <- param_csv$rowname

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    rerun_model <- reactive({

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


        for (p in colnames(params)) {
            params["pcnt", p] <- input[[paste0(p, "_pcnt")]]/100
            params["treat", p] <- input[[paste0(p, "_treat")]]/100
        }

        # Run model ----
        run_model(params, new_potential)
    })

    output$plot1 <- renderPlot({
        rerun_model() %>%
            filter(type == "at-risk") %>%
            ggplot(aes(time, value, colour = group)) +
            geom_line() +
            labs(x = "Simulation Month",
                 y = "# at Risk",
                 colour = "") +
            theme(axis.line = element_line(),
                  axis.ticks = element_line(),
                  panel.background = element_blank(),
                  panel.grid = element_blank())
    })

    output$plot2 <- renderPlot({
        rerun_model() %>%
            filter(type == "treatment") %>%
            group_by(time, treatment) %>%
            summarise(across(value, sum), .groups = "drop") %>%
            inner_join(tribble(
                ~treatment, ~average_monthly_appointments,
                "cmht", input[["cmht_appointments"]],
                "iapt", input[["iapt_appointments"]],
                "psych-liason", input[["psych-liason_appointments"]]
            ), by = "treatment") %>%
            ggplot(aes(time, value * average_monthly_appointments, colour = treatment)) +
            geom_line() +
            labs(x = "Simulation Month",
                 y = "# Appointments",
                 colour = "") +
            theme(axis.line = element_line(),
                  axis.ticks = element_line(),
                  panel.background = element_blank(),
                  panel.grid = element_blank())
    })

})
