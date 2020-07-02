options(tidyverse.quiet = TRUE)
library(tidyverse,    quietly = TRUE)
library(deSolve,      quietly = TRUE)
library(patchwork,    quietly = TRUE)
library(plotly,       quietly = TRUE)
library(shinyWidgets, quietly = TRUE)

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")
source("plots.R")

css_table <- "#contents {
font-size: 9px
}
"

