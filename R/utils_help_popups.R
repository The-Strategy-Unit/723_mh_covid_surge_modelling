#' Help Popups
#'
#' Adds help files to a page
#'
#' @param page the page to load help file for, stored in inst/app/data/\{\{page\}\}_help.json
#'
#' @import shiny
#' @importFrom purrr imap map
#' @importFrom jsonlite read_json
#' @importFrom shinyWidgets ask_confirmation
help_popups <- function(page) {
  file <- paste0("app/data/", page, "_help.json") %>%
    app_sys()

  if (!file.exists(file)) {
    stop(paste("no help file for", page, "exists"))
  }

  file %>%
    read_json(TRUE) %>%
    imap(function(data, input_name) {
      # extract the text field. each line of text is converted to a paragraph. if that paragraph starts with a ":",
      # then we put the text before the ":" in bold text, followed by the rest of the text.
      text <- data$text %>%
        strsplit(": ") %>%
        map(~if (length(.x) >= 2) {
          tags$p(tags$strong(.x[[1]]), paste(.x[-1], collapse = " "))
        } else {
          tags$p(.x)
        })

      function() ask_confirmation(
        paste0(input_name, "_box"),
        data$title,
        tagList(text),
        "question",
        "ok",
        closeOnClickOutside = TRUE,
        showCloseButton = FALSE,
        html = TRUE
      )
    })
}
