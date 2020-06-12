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
## Error in library(tidyverse, quietly = TRUE): there is no package called 'tidyverse'
```

```r
library(deSolve)
library(patchwork)
```

```
## Error in library(patchwork): there is no package called 'patchwork'
```

```r
source("half_life_factor.R")
source("run_model.R")

# Params ----
param_csv <- read_csv("sample_params.csv", col_types = "cccddddd") %>%
  unite(rowname, group:condition, sep = "_", na.rm = TRUE) %>%
  mutate_at("decay", ~half_life_factor(days, .x)) %>%
  select(-days)
```

```
## Error in read_csv("sample_params.csv", col_types = "cccddddd") %>% unite(rowname, : could not find function "%>%"
```

```r
params <- param_csv %>%
  select(pcnt:decay) %>%
  as.matrix() %>%
  t()
```

```
## Error in param_csv %>% select(pcnt:decay) %>% as.matrix() %>% t(): could not find function "%>%"
```

```r
colnames(params) <- param_csv$rowname
```

```
## Error in eval(expr, envir, enclos): object 'param_csv' not found
```

```r
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
```

```
## Error in run_model(params, new_potential): object 'params' not found
```

```r
o
```

```
## Error in eval(expr, envir, enclos): object 'o' not found
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
```

```
## Error in o %>% filter(type == "at-risk") %>% ggplot(aes(time, value, colour = group)): could not find function "%>%"
```

```r
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
```

```
## Error in o %>% filter(type == "treatment") %>% group_by(time, treatment) %>% : could not find function "%>%"
```

```r
p1 + p2 + plot_layout(ncol = 1)
```

```
## Error in eval(expr, envir, enclos): object 'p1' not found
```
