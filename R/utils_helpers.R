#' Half Life Factor
#'
#' Calculates from a time parameter and a percentage a value for the amount of a value that remains after
#' 1 period of time
#'
#' @param t A number, the time it takes for an initial value to decay to `p`\% of the original value
#' @param p A number, the percentage to reduce to (defaults to 50\%)
#'
#' @return A value in \[0, 1\] that is the percentage that would remain after 1 time period elapses
half_life_factor <- function(t, p = 0.5) {
  log(p) / t
}

#' Comma Format
#'
#' A simple version of scales::comma
#'
#' @param x a number to convert to comma format
#'
#' @return a string representation of the input in comma format
comma <- function(x) {
  format(round(x), big.mark = ",")
}

#' Where predicate
#'
#' reimplements tidyselect::where. This is far simpler but will suffice for our needs
#'
#' @param fn a predicate function that should accept a value and return a logical
#'
#' @return a function that applies \code{fn()} with an input \code{(x)} and optional additional arguments
where <- function(fn) {
  function(x, ...) fn(x, ...)
}

#' Primary Box
#'
#' returns a "box" with set arguments for solidHeader and status
#'
#' @param ... arguments passed to [shinydashboard::box()]
#'
#' @import shinydashboard
#'
#' @md
primary_box <- function(...) {
  box(..., solidHeader = TRUE, status = "primary")
}

#' Replace bootstrap grid columns
#'
#' By default shiny uses col-sm-* classes. We want to be able to replace these with a different column type, e.g.
#' col-xl-*. This function recursively iterates through shiny UI elements and replaces the classes of shiny.tag objects.
#'
#' @param x an object we want to iterate through, initialy should be a shiny.tag.list
#' @param from the column type we want to replace, defaults to "." (all)
#' @param to the column type we want to replace
replace_bootstrap_cols <- function(x,
                                   from = c(".", "xs", "sm", "md", "lg", "xl"),
                                   to = c("xs", "sm", "md", "lg", "xl")) {
  match.arg(from)
  match.arg(to)

  if (inherits(x, "shiny.tag.list") || inherits(x, "list")) {
    for (i in seq_along(x)) {
      if (!is.null(x[[i]])) {
        x[[i]] <- replace_bootstrap_cols(x[[i]], from, to)
      }
    }
  } else if (inherits(x, "shiny.tag")) {
    if (!is.null(x$attribs$class)) {
      x$attribs$class <- gsub(paste0("col\\-", from, "+\\-"),
                              paste0("col-", to, "-"),
                              x$attribs$class)
    }
    for (i in seq_along(x$children)) {
      if (!is.null(x$children[[i]])) {
        x$children[[i]] <- replace_bootstrap_cols(x$children[[i]], from, to)
      }
    }
  }
  x
}
