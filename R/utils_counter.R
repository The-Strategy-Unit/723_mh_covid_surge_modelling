#' Counter Class
#'
#' @field value the current value of the counter, should not be accessed directly
#' @import methods
Counter <- setRefClass( # nolint
  "Counter",
  fields = list("value" = "integer"),
  methods = list(
    "initialize" = function() {
      # called by CounterClass$new()
      .self$value <- 0L
    },
    "get" = function() {
      "increments the counter and return's the new value"
      (.self$value <- .self$value + 1L)
    }
  )
)
