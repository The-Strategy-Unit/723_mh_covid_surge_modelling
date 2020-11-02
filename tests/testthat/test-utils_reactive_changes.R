library(testthat)
library(mockery)

test_that("it returns a reactiveValue", {
  actual <- reactive_changes(TRUE)

  expect_s3_class(actual, "reactiveVal")
})

test_that("it updates with changes", {
  server <- function(id) {
    moduleServer(id, function(input, output, session) {
      v <- reactiveValues(values = list())
      rc <- reactive_changes(names(v$values))

      observe({
        v$values <- if (!is.null(input$v)) {
          as.list(set_names(input$v))
        } else {
          list()
        }
      })
    })
  }

  testServer(server, {
    session$setInputs(v = c("a", "b", "c"))
    expect_equal(rc(), c("a", "b", "c"))

    session$setInputs(v = c("a", "b"))
    expect_equal(rc(), c("a", "b"))

    # it should also allow setting to NULL
    session$setInputs(v = NULL)
    expect_null(rc())
  })
})

test_that("it shouldn't fire if the values don't change", {
  m <- mock()
  server <- function(id) {
    moduleServer(id, function(input, output, session) {
      v <- reactiveValues(values = list())
      rc <- reactive_changes(names(v$values))

      observe({
        v$values <- if (!is.null(input$v)) {
          as.list(set_names(input$v))
        } else {
          list()
        }
      })
    })
  }

  stub(reactive_changes, "reactiveVal", function() m)
  testServer(server, {
    session$setInputs(v = c("a", "b", "c"))
    # a second call with the same arguments should only call rv() once
    session$setInputs(v = c("a", "b", "c"))

    expect_called(m, 3)
    expect_call(m, 1, rv())
    expect_call(m, 2, rv(nv))
    expect_call(m, 3, rv())
  })
})
