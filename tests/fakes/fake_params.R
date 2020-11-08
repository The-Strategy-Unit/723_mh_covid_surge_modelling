fake_params <- list(
  curves = list(
    a = c(0.1, 0.2, 0.3, 0.4),
    b = c(0.2, 0.3, 0.3, 0.2)
  ),
  groups = list(
    a = list(
      size = 1000,
      pcnt = 10,
      curve = "a",
      conditions = list(
        a = list(
          pcnt = 0.1,
          treatments = c(a = 1, b = 2)
        ),
        b = list(
          pcnt = 0.2,
          treatments = c(a = 3, b = 4)
        )
      )
    ),
    b = list(
      size = 2000,
      pcnt = 20,
      curve = "b",
      conditions = list(
        a = list(
          pcnt = 0.3,
          treatments = c(a = 5, b = 6)
        ),
        b = list(
          pcnt = 0.4,
          treatments = c(a = 7, b = 8)
        )
      )
    )
  ),
  treatments = list(
    a = list(
      success = 0.5,
      months = 1,
      decay = 0.5,
      demand = 1,
      treat_pcnt = 0.5
    ),
    b = list(
      success = 0.2,
      months = 2,
      decay = 0.5,
      demand = 1,
      treat_pcnt = 0.7
    )
  ),
  demand = list(
    a = tibble(
      month = ymd(c(20200501, 20200601, 20200701, 20200801)),
      underlying = c(10, 20, 30, 40),
      suppressed = c(5, 6, 7, 8)
    )
  )
)

saveRDS(fake_params, here::here("tests/fakes/fake_params.rds"))
