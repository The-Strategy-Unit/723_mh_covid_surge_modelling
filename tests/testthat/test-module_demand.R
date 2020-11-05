library(testthat)
library(mockery)

# demand ui ----

test_that("it creates the UI correctly", {
  expect_snapshot(demand_ui("x"))
})

# demand server ----

demand_args <- function() list(
  params = lift_dl(reactiveValues)(params),
  upload_event = reactiveValues(
    counter = 0,
    success = FALSE,
    msg = ""
  )
)

test_that("services works correctly", {
  testServer(demand_server, args = demand_args(), {
    session$private$flush()

    expect_length(services(), 37)

    params$demand <- params$demand[1:2]
    session$private$flush()

    expect_equal(services(),
                 c("24/7 Crisis Response Line", "Assertive Outreach Team"))
  })
})

test_that("it reacts to upload events", {
  m <- mock()
  stub(demand_server, "updateSelectInput", m)

  testServer(demand_server, args = demand_args(), {
    upload_event$counter <- 1
    upload_event$success <- TRUE
    session$private$flush()

    upload_event$counter <- 2
    upload_event$success <- FALSE
    session$private$flush()
  })

  expect_called(m, 1)
  expect_call(m, 1, updateSelectInput(session, "service", choices = services()))
})

test_that("it creates a table correctly when input$service is changed", {
  testServer(demand_server, args = demand_args(), {
    session$setInputs(service = "24/7 Crisis Response Line")
    expect_equal(nchar(output$container$html), 26702)
    expect_snapshot(output$container$html)
  })
})

test_that("it handles the observerables for the table correctly", {
  testServer(demand_server, args = demand_args(), {
    session$setInputs(service = "24/7 Crisis Response Line")
    expect_length(session$env$demand_observables, 72)

    mocks <- map(session$env$demand_observables, ~mock())
    session$env$demand_observables <- map(mocks, ~list(destroy = .x))
    session$setInputs(service = "IAPT")

    walk(mocks, ~expect_called(.x, 1))
  })
})

test_that("it updates params correctly", {
  month <- params$demand$`24/7 Crisis Response Line`$month[[1]]

  testServer(demand_server, args = demand_args(), {
    session$setInputs(service = "24/7 Crisis Response Line")

    d <- function() params$demand$`24/7 Crisis Response Line`

    expect_equal(d()$underlying[[1]], 1999)
    expect_equal(d()$suppressed[[1]], 0)

    session$setInputs("May-20-underlying" = 123,
                      "May-20-suppressed" = 456)


    expect_equal(d()$underlying[[1]], 123)
    expect_equal(d()$suppressed[[1]], 456)
  })
})
