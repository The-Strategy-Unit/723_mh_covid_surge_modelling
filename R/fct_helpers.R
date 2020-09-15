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
#' @importFrom shinydashboard box
primary_box <- function(...) {
  box(..., solidHeader = TRUE, status = "primary")
}
