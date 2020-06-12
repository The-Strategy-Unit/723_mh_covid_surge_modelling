# Covid Surge Modelling to Mental Health Services

| Item         | Value          |
|--------------|----------------|
| Project Code | 723            |
| Project Lead | Andrew Hood    |


## Running the model


```r
library(tidyverse, quietly = TRUE)
```

```
## ── [1mAttaching packages[22m ─────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## [32m✔[39m [34mggplot2[39m 3.3.1     [32m✔[39m [34mpurrr  [39m 0.3.4
## [32m✔[39m [34mtibble [39m 3.0.1     [32m✔[39m [34mdplyr  [39m 1.0.0
## [32m✔[39m [34mtidyr  [39m 1.1.0     [32m✔[39m [34mstringr[39m 1.4.0
## [32m✔[39m [34mreadr  [39m 1.3.1     [32m✔[39m [34mforcats[39m 0.5.0
```

```
## ── [1mConflicts[22m ────────────────────────────────────────── tidyverse_conflicts() ──
## [31m✖[39m [34mdplyr[39m::[32mfilter()[39m masks [34mstats[39m::filter()
## [31m✖[39m [34mdplyr[39m::[32mlag()[39m    masks [34mstats[39m::lag()
```

```r
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
## [90m# A tibble: 4,869 x 6[39m
##      time type        group      treatment    condition   value
##     [3m[90m<dbl>[39m[23m [3m[90m<chr>[39m[23m       [3m[90m<chr>[39m[23m      [3m[90m<chr>[39m[23m        [3m[90m<chr>[39m[23m       [3m[90m<dbl>[39m[23m
## [90m 1[39m 0      no-mh-needs [31mNA[39m         [31mNA[39m           [31mNA[39m              0
## [90m 2[39m 0      at-risk     bereaved   [31mNA[39m           [31mNA[39m              0
## [90m 3[39m 0      at-risk     unemployed [31mNA[39m           [31mNA[39m              0
## [90m 4[39m 0      treatment   bereaved   cmht         bereavement     0
## [90m 5[39m 0      treatment   unemployed cmht         insomnia        0
## [90m 6[39m 0      treatment   unemployed cmht         stress          0
## [90m 7[39m 0      treatment   unemployed iapt         anxiety         0
## [90m 8[39m 0      treatment   unemployed iapt         depression      0
## [90m 9[39m 0      treatment   unemployed psych-liason suicide         0
## [90m10[39m 0.033[4m3[24m no-mh-needs [31mNA[39m         [31mNA[39m           [31mNA[39m              0
## [90m# … with 4,859 more rows[39m
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
