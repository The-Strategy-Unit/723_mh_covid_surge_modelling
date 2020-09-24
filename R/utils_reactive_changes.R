#' Reactive Changes
#'
#' Create a reactive that is only updated when the expression returns a different vector to what is currently stored
#'
#' @param expr an expression that gets the values to observe whether they are changing
#'
#' @import shiny
#' @import rlang
#'
#' @return a reactiveVal
reactive_changes <- function(expr) {
  env = parent.frame()
  expr <- enquo(expr)
  rv <- reactiveVal()
  observe({
    nv <- eval_tidy(expr, env)
    ov <- rv()
    if (!(length(nv) == length(rv) && all(nv == ov))) {
      rv(nv)
    }
  })
  invisible(rv)
}
