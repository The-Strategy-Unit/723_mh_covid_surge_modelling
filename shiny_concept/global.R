library(tidyverse, quietly = TRUE)
library(deSolve)
library(patchwork)
library(plotly)

options(scipen = 999)

source("half_life_factor.R")
source("run_model.R")

css_table <- "#contents {
font-size: 10px
}
"

