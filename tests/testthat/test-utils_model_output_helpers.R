library(testthat)
library(mockery)

model_output <- params %>%
  run_model(0.5) %>%
  get_model_output(ymd(20200501))

# get_model_output ----

test_that("get_model_output errors if start_month is not the first of the month", {
  expect_error(get_model_output(NULL, ymd(20200502)))
})

test_that("get_model_output returns correct model_output", {
  expect_equal(nrow(model_output), 125883)
  expect_s3_class(model_output, "tbl_df")
  expect_equal(colnames(model_output),
               c("time", "date", "type", "group", "condition", "treatment", "value"))
  expect_equal(map_chr(model_output, class) %>% unname(),
               c("numeric", "Date", "character", "character", "character", "character", "numeric"))
})

# get_appointments ----

test_that("get_appointments returns correct data", {
  actual <- get_appointments(params)

  expect_s3_class(actual, "tbl_df")
  expect_equal(nrow(actual), 34)
  expect_equal(sum(actual$average_monthly_appointments), 156.443, tolerance = 1e-3)
})

# model_totals ----

test_that("model_totals returns the correct data", {
  expect_equal(model_totals(model_output, "new-referral", "IAPT"), "857,314")
  expect_equal(model_totals(model_output, "new-treatment", "IAPT"), "531,754")
  expect_equal(model_totals(model_output, "new-referral", "General Practice"), "418,359")
  expect_equal(model_totals(model_output, "new-treatment", "General Practice"), "418,359")
})

# surge_summary ----

test_that("surge_summary returns the correct data", {
  ag <- surge_summary(model_output, group) %>%
    purrr::discard(is.factor) %>%
    map_dbl(sum)
  expect_equal(ag, c(`new-at-risk` = 10841496, `new-referral` = 2556299, `new-treatment` = 2015319))

  ac <- surge_summary(model_output, condition) %>%
    purrr::discard(is.factor) %>%
    map_dbl(sum)
  expect_equal(ac, c(`new-referral` = 2556297, `new-treatment` = 2015320))

  at <- surge_summary(model_output, treatment) %>%
    purrr::discard(is.factor) %>%
    map_dbl(sum)
  expect_equal(at, c(`new-referral` = 2556296, `new-treatment` = 2015324))
})

# surge_table ----
test_that("surge_table", {
  ag <- surge_table(model_output, group, "Group")
  expect_equal(
    colnames(ag),
    c("Group",
      "Adjusted exposed / at risk @ baseline",
      "Total symptomatic over period referrals",
      "Total receiving services over period")
  )
  expect_equal(nrow(ag), 16)
  expect_equal(
    ag %>%
      purrr::discard(is.factor) %>%
      map_dbl(mean),
    c(`Adjusted exposed / at risk @ baseline` = 677593.5,
      `Total symptomatic over period referrals` = 159858.5,
      `Total receiving services over period` = 126353.4),
    tolerance = 0.1
  )

  ac <- surge_table(model_output, condition, "Condition")
  expect_equal(
    colnames(ac),
    c("Condition",
      "Total symptomatic over period referrals",
      "Total receiving services over period")
  )
  expect_equal(nrow(ac), 12)
  expect_equal(
    ac %>%
      purrr::discard(is.factor) %>%
      map_dbl(mean),
    c(`Total symptomatic over period referrals` = 213144.8,
      `Total receiving services over period` = 168471.2),
    tolerance = 0.1
  )

  at <- surge_table(model_output, treatment, "Treatment")
  expect_equal(
    colnames(at),
    c("Treatment",
      "Total symptomatic over period referrals",
      "Total receiving services over period")
  )
  expect_equal(nrow(at), 34)
  expect_equal(
    at %>%
      purrr::discard(is.factor) %>%
      map_dbl(mean),
    c(`Total symptomatic over period referrals` = 75185.18,
      `Total receiving services over period` = 59274.24),
    tolerance = 0.01
  )
})

# summarise_model_output ----

test_that("summarise_model_output returns correct data", {
  expect_equal(
    mean(
      summarise_model_output(model_output,
                             "treatment",
                             "IAPT")$value
    ),
    44344,
    tolerance = 0.1
  )

  expect_equal(
    mean(
      summarise_model_output(model_output,
                             "new-referral",
                             "IAPT")$value
    ),
    21947,
    tolerance = 0.1
  )

  expect_equal(
    mean(
      summarise_model_output(model_output,
                             "new-referral",
                             c("General Practice", "IAPT"))$value
    ),
    35881,
    tolerance = 0.1
  )
})
