#' Markdown to Tags
#'
#' Takes a markdown file and converts it to a HTML tags object that can be used in a Shiny UI
#'
#' @param file the file to read and convert to html tags
#'
#' @importFrom markdown markdownToHTML
#' @import shiny
#'
#' @return a shiny.tag.list object
md_to_tags <- function(file) {
  md <- markdownToHTML(file, fragment.only = TRUE)
  htmlTemplate(text_ = md, document_ = FALSE)
}
