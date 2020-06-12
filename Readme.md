# Covid Surge Modelling to Mental Health Services

| Item         | Value          |
|--------------|----------------|
| Project Code | 723            |
| Project Lead | Andrew Hood    |


## Running the model


```r
library(tidyverse, quietly = TRUE)
library(deSolve)
library(patchwork)

source("half_life_factor.R")
source("run_model.R")

# Params ----
params <- matrix(
  # Unemployed
  c(0.01, 0.10, 0.90, half_life_factor(4), # stress
    0.02, 0.01, 0.80, half_life_factor(6), # insomnia
    0.06, 0.04, 0.95, half_life_factor(3), # anxiety
    0.03, 0.06, 0.80, half_life_factor(2), # depression
    0.001, 0.9, 0.05, half_life_factor(1), # suicide
    # Bereaved
    0.01, 1.00, 1.00, half_life_factor(1, 0.9) # Bereavement
  ),
  nrow = 4,
  dimnames = list(c("pcnt", "treat", "success", "decay"),
                  # names should be of form group_treatment_condition
                  c("unemployed_cmht_stress",
                    "unemployed_cmht_insomnia",
                    "unemployed_iapt_anxiety",
                    "unemployed_iapt_depression",
                    "unemployed_psych-liason_suicide",
                    "bereaved_cmht_bereavement"))
)

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

# Run model ----
o <- run_model(params, new_potential)

o
```

```
## # A tibble: 4,869 x 6
##      time type        group      treatment    condition   value
##     <dbl> <chr>       <chr>      <chr>        <chr>       <dbl>
##  1 0      no-mh-needs <NA>       <NA>         <NA>            0
##  2 0      at-risk     bereaved   <NA>         <NA>            0
##  3 0      at-risk     unemployed <NA>         <NA>            0
##  4 0      treatment   bereaved   cmht         bereavement     0
##  5 0      treatment   unemployed cmht         insomnia        0
##  6 0      treatment   unemployed cmht         stress          0
##  7 0      treatment   unemployed iapt         anxiety         0
##  8 0      treatment   unemployed iapt         depression      0
##  9 0      treatment   unemployed psych-liason suicide         0
## 10 0.0333 no-mh-needs <NA>       <NA>         <NA>            0
## # ... with 4,859 more rows
```


```r
# Show plots ----
p1 <- o %>%
  filter(type == "at-risk") %>%
  ggplot(aes(time, value, colour = group)) +
  geom_line() +
  labs(x = "Simulation Month",
       y = "# at Risk",
       colour = "")

p2 <- o %>%
  filter(type == "treatment") %>%
  group_by(time, treatment) %>%
  summarise(across(value, sum), .groups = "drop") %>%
  inner_join(tribble(
    ~treatment, ~average_monthly_appointments,
    "cmht", 4,
    "iapt", 6,
    "psych-liason", 30
  ), by = "treatment") %>%
  ggplot(aes(time, value * average_monthly_appointments, colour = treatment)) +
  geom_line() +
  labs(x = "Simulation Month",
       y = "# Appointments",
       colour = "")

p1 + p2 + plot_layout(ncol = 1)
```

![plot of chunk model_sample_output](figure/model_sample_output-1.png)
