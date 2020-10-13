#' Reorder factor levels by sorting along another variable
#'
#' fct_reorder() is useful for 1d displays where the factor is mapped to position; fct_reorder2() for 2d displays where
#' the factor is mapped to a non-position aesthetic. last2() and first2() are helpers for fct_reorder2(); last2() finds
#' the last value of y when sorted by x; first2() finds the first value.
#'
#' Reimplements [forcats::fct_reorder()]
#'
#' @param .f A factor (or character vector).
#' @param .x The levels of f are reordered so that the values of .fun(.x) are in ascending order.
#' @param .fun summary function. It should take one vector
#' @param ... Other arguments passed on to .fun. A common argument is na.rm = TRUE.
#' @param .desc Order in descending order?
#'
#' @importFrom stats median
#' @md
fct_reorder <- function(.f, .x, .fun = median, ..., .desc = FALSE) {
  summary <- tapply(.x, .f, .fun, ...)
  if (is.list(summary)) {
    stop("`fun` must return a single value per group",
         call. = FALSE)
  }
  .l <- names(summary)[order(summary, decreasing = .desc)]
  factor(.f, .l)
}
