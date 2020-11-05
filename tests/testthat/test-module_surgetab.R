library(testthat)
library(mockery)

# ui ----

test_that("it generates the UI correctly", {
  ui <- surgetab_ui("a")
  expect_s3_class(ui, "shiny.tag")
})

# server ----

column <- quo(group)

surgetab_server_args <- function() list(
  model_output = reactive("model_output"),
  column = column,
  title = "Group"
)

test_that("it renders table correctly", {
  m <- mock("table")

  stub(surgetab_server, "surge_table", m)
  stub(surgetab_server, "surge_plot", NULL)
  testServer(surgetab_server, args = surgetab_server_args(), {
    session$private$flush()
    expect_called(m, 1)
    expect_args(m, 1, "model_output", column, "Group")
    expect_equal(
      output$surge_table,
      paste0("<table  class = 'table shiny-table table- spacing-s' style = 'width:auto;'>\n",
             "<thead> <tr> <th style='text-align: left;'> data </th>  </tr> </thead> <tbody>\n",
             "  <tr> <td> table </td> </tr>\n   </tbody> </table>")
    )
  })
})

test_that("it renders plot correctly", {
  mp <- mock("surge_plot")
  mr <- mock()

  stub(surgetab_server, "surge_plot", mp)
  stub(surgetab_server, "renderPlotly", mr)

  testServer(surgetab_server, args = surgetab_server_args(), {
    expect_called(mp, 1)
    expect_args(mp, 1, "model_output", column)

    expect_called(mr, 1)
    expect_args(mr, 1, "surge_plot")
  })
})
