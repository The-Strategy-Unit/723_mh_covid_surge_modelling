#' Reduce Condition Percents
#'
#' For each group, the sum of the "pcnt" value for each condition must not exceed 100%. This function recursively
#' iterates reducing the percents equally of the other conditions.
#'
#' If at any point the amount that we need to reduce (equally) by exceeds the smallest value, then we reduce all by the
#' smallest group, then remove the smallest group and iterate.
#'
#' @param conditions the conditions (from params$groups[[.x]]$conditions)
#' @param current_conditions the names of conditions to reduce by, initially all except the condition that has been
#'                           changed
#'
#' @return the altered conditions
#'
#' @importFrom dplyr %>%
#' @importFrom purrr map_dbl walk
reduce_condition_pcnts <- function(conditions, current_conditions) {
  pcnts <- map_dbl(conditions, "pcnt")

  # check that we do not exceed 100% for conditions
  pcnt_sum <- sum(pcnts)
  # break out the loop
  if (pcnt_sum <= 1) return(conditions)

  # get the pcnt's for the "current" conditions
  current_pcnts <- pcnts[current_conditions]

  # find the smallest percentage currently
  min_pcnt <- min(current_pcnts)
  # what is(are) the smallest group(s)?
  j <- names(which(current_pcnts == min_pcnt))
  # find the target reduction (either the minimum percentage present, or an equal split of the amount of the
  # sum over 100%)
  tgt_pcnt <- min(min_pcnt, (pcnt_sum - 1) / length(current_conditions))

  # now, reduce the pcnts by the target
  walk(current_conditions, function(.x) {
    conditions[[.x]]$pcnt <<- conditions[[.x]]$pcnt - tgt_pcnt
  })

  # remove the smallest group(s) j and loop recursively
  reduce_condition_pcnts(conditions, current_conditions[!current_conditions %in% j])
}
