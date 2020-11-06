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
      )
    ),

    tags$h2("Basic instructions – please read before starting:"),
    tags$p(
      "These notes should help you navigate the various tabs and inputs for the model. Additional help notes within",
      "each tab provide extra information on certain elements."
    ),
    tags$h3("Home tab"),
    tags$p(
      "This is where you choose from a default set of model parameters or to upload your own. If you choose ‘custom’",
      "to upload your own you will be directed to an excel file template which you will need to populate with your",
      "own data, parameters and variables prior to loading."
    ),
    tags$h3("Parameters tab"),
    tags$p(
      "The main control centre for the model, this will be pre-populated with the parameters and variables for the",
      "selection from the Home tab or the details you have uploaded. You can then manually override information for",
      "population groups, effect sizes, service flows and service behaviours. NB. It is best to apply any changes to",
      "all other boxes as you change the population sub-group to keep track of your inputs as some options will",
      "change once you change the population group."
    ),
    tags$h3("Population groups"),
    tags$p(
      "Cycle through the various risk populations and set the size of the population for each; an adjustment for",
      "susceptibility/resilience (this is a pragmatic value included to try and mitigate risk of double-counting of",
      "populations and also accounting for unknown benefits of covid and lockdown on each group. This value is art not",
      "science); the scenario to determine the nature of impacts over time. Unless you upload a parameter file you",
      "will have to repeat this for each population group."
    ),
    tags$h4("Impacts on population groups"),
    tags$p(
      "This will change for each population group you select in the previous box as determined by our early",
      "literature search. Change the incidence/prevalence rates (%’s) for each potential impact condition. Please",
      "note, we have halved each of the published rates on the basis that on average people tend to present with",
      "around 2 co-morbid psychiatric issues but our model only address problems in a unitary way."
    ),
    tags$h4("Referral/Service flows"),
    tags$p(
      "This will change for each condition you select at the top of the box. Enter any values for the number of",
      "patients (with the above condition) likely to end up in each service. It is easiest to think of a notional",
      "population of 100 or 1000 with that condition and apportion them accordingly. Unless you have uploaded your",
      "own service team names in a parameter file, these will remain as the Service/Team types as per the MHSDS."
    ),
    tags$h4("Service variables"),
    tags$p(
      "These options are the same regardless of which service you choose to change and determine the % of referrals",
      "that might require treatment, the typical times spent in treatment, the likelihood of mental health ‘recovery’",
      "and the typical contact volumes per patient per month. For fuller descriptions of these variables please see",
      "the help pop-up at bottom of the box."
    ),
    tags$p(
      "After changing all or even some of your inputs, you may wish to save (by download button) all of the adjusted",
      "parameters so you can use them again in the future by direct upload. IMPORTANT – the parameters will all revert",
      "to the national defaults if your browser timeouts (this is currently set at 15 minutes of inactivity); if you",
      "refresh your browser window or if you go back to the Home tab and change to another pre-set version. You will",
      "lose all of your changes!"
    ),
    tags$h3("Demand tab"),
    tags$p(
      "This will be pre-populated with the selection from the Home tab or the details you have uploaded. You can",
      "overwrite the data in the underlying tab with your actual referral volumes and/or some other prediction",
      "values. The suppressed activity can also be over-written if local planning dictates a change. It will need to",
      "be updated by each service manually or via the demand tab in the uploaded excel parameter file."
    ),
    tags$h3("Results tab"),
    tags$p(
      "Here the model outputs for all the inputs you have set or changed will be presented. You can choose to cycle",
      "through and review these on screen by each service line, export a basic pdf report of the selected or all",
      "services or you could download a csv file of the full set of model results for use in your own analysis. The",
      "outputs show the summary changes in referral and service demand, the (population) source of the surges and how",
      "the demands may vary over time."
    ),
    tags$h3("Surge Demand tabs"),
    tags$p(
      "More detailed counts of the modelled surges for each of the population groups, conditions and services are",
      "shown here respectively. Presented as tables and stacked bar charts for referrals and those likely to",
      "receive/need services at current thresholds."
    )
  )
}

#' @rdname home_module
home_server <- function(id, params_file_path, upload_event) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$params_select, {
      ps <- req(input$params_select)

      if (ps == "custom") {
        shinyjs::show("user_upload_xlsx")
        # don't immediately show the upload msg, only show after an upload has occurred
      } else {
        shinyjs::hide("user_upload_xlsx")
        shinyjs::hide("user_upload_xlsx_msg")
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
