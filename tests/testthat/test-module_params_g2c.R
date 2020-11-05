library(testthat)
library(mockery)

# ui ----

test_that("it generates the ui correctly", {
  ui <- g2c_ui("a")
  expect_equal(as.character(ui), "<div id=\"a-container\" class=\"shiny-html-output\"></div>")
  expect_s3_class(ui, "shiny.tag")
})

# server ----

params_g2c_args <- function() list(
  params = lift_dl(reactiveValues)(params),
  redraw_g2c = reactiveVal(),
  redraw_c2t = reactiveVal(),
  counter = methods::new("Counter"),
  popn_subgroup = reactiveVal()
)

test_that("condition_slider_name() returns correct names", {
  stub(g2c_server,
       "reduce_condition_pcnts",
       function(conditions, ...) conditions)

  testServer(g2c_server, args = params_g2c_args(), {
    expect_equal(condition_slider_name("a"),
                 "slider_cond_pcnt_a")
    expect_equal(condition_slider_name("a b"),
                 "slider_cond_pcnt_a_b")
  })
})

test_that("it responds to events correctly and redraws the UI", {
  stub(g2c_server,
       "reduce_condition_pcnts",
       function(conditions, ...) conditions)

  m <- mock("a", "b", "c")
  stub(g2c_server, "isolate", m)

  testServer(g2c_server, args = params_g2c_args(), {
    # initial call, set redraw_g2c and leave null popn_subgroup
    cv <- counter$get()
    redraw_g2c(cv)
    session$private$flush()
    expect_null(redraw_c2t())
    expect_called(m, 0)

    popn_subgroup("Children & young people")
    session$private$flush()

    expect_equal(redraw_c2t(), cv + 1)
    expect_called(m, 1)
    expect_equal(as.character(output$container$html), "a")

    cv <- counter$get()
    redraw_g2c(cv)
    session$private$flush()

    expect_equal(redraw_c2t(), cv + 1)
    expect_called(m, 2)
    expect_equal(as.character(output$container$html), "b")

    popn_subgroup("Domestic abuse victims")
    session$private$flush()

    expect_equal(redraw_c2t(), cv + 2)
    expect_called(m, 3)
    expect_equal(as.character(output$container$html), "c")
  })
})

test_that("it generates the dynamic ui", {
  stub(g2c_server,
       "reduce_condition_pcnts",
       function(conditions, ...) conditions)

  testServer(g2c_server, args = params_g2c_args(), {
    cv <- counter$get()
    redraw_g2c(cv)
    popn_subgroup("Children & young people")
    session$private$flush()

    a <- as.character(output$container$html)
    expect_snapshot(a)
    expect_equal(nchar(a), 3345)

    popn_subgroup("Domestic abuse victims")
    session$private$flush()

    b <- as.character(output$container$html)
    expect_snapshot(b)
    expect_equal(nchar(b), 2347)

    expect_true(a != b)
  })
})

test_that("changing popn_subgroup() will cause previous observers to be destroyed", {
  stub(g2c_server,
       "reduce_condition_pcnts",
       function(conditions, ...) conditions)

  testServer(g2c_server, args = params_g2c_args(), {
    cv <- counter$get()
    redraw_g2c(cv)
    popn_subgroup("Children & young people")
    session$private$flush()

    expect_length(session$env$observers, 6)

    mocks <- map(session$env$observers, ~mock())
    session$env$observers <- map(mocks, ~list(destroy = .x))

    popn_subgroup("Domestic abuse victims")
    session$private$flush()

    expect_length(session$env$observers, 4)
    walk(mocks, ~expect_called(.x, 1))
  })
})

test_that("it calles reduce_condition_pcnts", {
  m <- mock()
  stub(g2c_server, "reduce_condition_pcnts", m)

  testServer(g2c_server, args = params_g2c_args(), {
    cv <- counter$get()
    redraw_g2c(cv)
    popn_subgroup("Children & young people")
    session$setInputs(slider_cond_pcnt_Anxiety = 1)

    expect_called(m, 1)
    expect_call(m, 1, reduce_condition_pcnts(conditions, discard(condition_names, ~.x == i)))
  })
})

test_that("changing values in the dynamic ui updates params", {
  stub(g2c_server,
       "reduce_condition_pcnts",
       function(conditions, current_conditions) {
         for (i in current_conditions) {
           conditions[[i]]$pcnt <- 0
         }
         conditions
       })

  m <- mock()
  stub(g2c_server, "updateSliderInput", m)

  testServer(g2c_server, args = params_g2c_args(), {
    expect_equal(params$groups$`Children & young people`$conditions$Anxiety$pcnt, 0.12)
    cv <- counter$get()
    redraw_g2c(cv)
    popn_subgroup("Children & young people")
    session$setInputs(slider_cond_pcnt_Anxiety = 1)

    expect_equal(params$groups$`Children & young people`$conditions$Anxiety$pcnt, 0.01)
    expect_true(all(map_dbl(params$groups$`Children & young people`$conditions[-1], "pcnt") == 0))

    expect_called(m, 7)

    expect_args(m, 1, session, "slider_cond_pcnt_Anxiety", value = 1)
    expect_args(m, 2, session, "slider_cond_pcnt_Depression", value = 0)
    expect_args(m, 3, session, "slider_cond_pcnt_Neurological_symptom_disorder_(ADHD/Aspergers)", value = 0)
    expect_args(m, 4, session, "slider_cond_pcnt_PTSD", value = 0)
    expect_args(m, 5, session, "slider_cond_pcnt_Self_harm", value = 0)
    expect_args(m, 6, session, "slider_cond_pcnt_Stress_and_Distress", value = 0)
    expect_args(m, 7, session, "slider_cond_pcnt_no_mh_needs", value = 99)
  })
})
