#' Home Module
#'
#' A shiny module that renders all of the content for the home page.
#'
#' @name home_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params_file_path a reactiveVal that contains the path to the current params file
#' @param upload_event a reactiveValues that is updated when a file is uploaded

#' @rdname home_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
#' @importFrom shinyjs hidden
#' @importFrom dplyr %>%
#' @importFrom purrr set_names
home_ui <- function(id) {
  files <- app_sys("app/data") %>%
    dir("^params\\_.*\\.xlsx$", full.names = TRUE) %>%
    (function(f) {
      n <- gsub("\\-", " ", gsub("^.*\\/params\\_(.*)\\.xlsx$", "\\1", f))
      f <- set_names(f, n)

      # reorder to make sure England is first
      c(f[n == "England"], sort(f[n != "England"]))
    })()

  tagList(
    tags$a(
      href = "https://www.strategyunitwm.nhs.uk/",
      tags$img(
        src = "https://www.strategyunitwm.nhs.uk/themes/custom/ie_bootstrap/logo.svg",
        title = "The Strategy Unit",
        alt = "The Strategy Unit Logo",
        align = "right",
        height = "80"
      )
    ),
    tags$h1("Mental Health Surge Modelling"),
    tags$p(
      "This is a system dynamic simulation of the potential impacts of covid-19 on mental health services in England.",
      "The model was developed and designed initially with and for staff at Mersey Care NHS Foundation Trust and",
      "subsequently as part of the",
      tags$a("national analytical Collaboration for Covid-19",
             href = "https://www.strategyunitwm.nhs.uk/covid19-and-coronavirus"),
      "."
    ),
    tags$p(
      "The application applies evidence-based effects to segmented populations, then maps the flows of referrals and",
      "service use to a basket of likely service destinations."
    ),
    tags$p(
      "The tool can support areas to estimate effects for their own population and services by either adapting the",
      "default data and parameters (e.g. England) or uploading their own to run within the model."
    ),
    primary_box(
      title = "Select parameters",
      width = 12,
      selectInput(
        NS(id, "params_select"),
        "Default Parameters",
        c(files, Custom = "custom")
      ),
      hidden(
        fileInput(
          NS(id, "user_upload_xlsx"),
          label = NULL,
          multiple = FALSE,
          accept = ".xlsx",
          placeholder = "Previously downloaded parameters"
        ),
        uiOutput(NS(id, "user_upload_xlsx_msg"))
        ,
        uiOutput(NS(id, "example_param_file_text"))
      )
    ),
    md_to_tags(app_sys("app/data/home_documentation.md"))
  )
}

#' @rdname home_module
home_server <- function(id, params_file_path, upload_event) {
  moduleServer(id, function(input, output, session) {

    output$example_param_file_text <- renderUI({
      HTML(
        paste0(
          "To view an example of the parameters file for the national model, please click ",
          a("here", href = "https://github.com/The-Strategy-Unit/723_mh_covid_surge_modelling/blob/master/inst/app/data/params_England.xlsx?raw=true", target =
              "_blank"),
          "."
        )
      )
    })

    observeEvent(input$params_select, {
      ps <- req(input$params_select)

      if (ps == "custom") {
        shinyjs::show("user_upload_xlsx")
        shinyjs::show("example_param_file_text")
        # don't immediately show the upload msg, only show after an upload has occurred

      } else {
        shinyjs::hide("user_upload_xlsx")
        shinyjs::hide("user_upload_xlsx_msg")
        shinyjs::hide("example_param_file_text")
        params_file_path(input$params_select)
      }
    })

    observeEvent(input$user_upload_xlsx, {
      x <- req(input$user_upload_xlsx)
      # now a file has been uploaded, show the msg
      shinyjs::show("user_upload_xlsx_msg")
      params_file_path(x$datapath)
    })

    output$user_upload_xlsx_msg <- renderUI({
      if (upload_event$success) {
        tags$span(upload_event$msg)
      } else {
        tags$span(
          tags$strong("Error: "),
          upload_event$msg,
          style = "color: red"
        )
      }
    })
  })
}
