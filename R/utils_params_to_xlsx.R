#' Params To xlsx
#'
#' Take the `params` and creates an Excel file which can be downloaded and reuploaded at a later date
#'
#' @param params the current `params` object used to model the data
#' @param file the filename where to save the xlsx file
#'
#' @return invisibly returns where the file was saved
#'
#' @importFrom dplyr %>% bind_cols mutate row_number select bind_rows bind_cols everything
#' @importFrom purrr map_dfr modify_at map map_dbl map_depth
#' @importFrom writexl write_xlsx
params_to_xlsx <- function(params, file) {
  xl <- list()

  xl$curves <- params$curves %>%
    bind_cols() %>%
    mutate(month = row_number() - 1, .before = everything())

  xl$groups <- params$groups %>%
    map_dfr(modify_at, "conditions", ~NULL, .id = "group") %>%
    select(.data$group, .data$curve, .data$size, .data$pcnt)

  xl$g2c <- params$groups %>%
    map("conditions") %>%
    map(map_dbl, "pcnt") %>%
    map_dfr(~list(condition = names(.x), pcnt = unname(.x)), .id = "group")


  xl$c2t <- params$groups %>%
    map("conditions") %>%
    map_depth(2, "treatments") %>%
    map_depth(3, bind_cols) %>%
    map_depth(2, bind_rows, .id = "treatment") %>%
    map(bind_rows, .id = "condition") %>%
    bind_rows(.id = "group")

  xl$treatments <- params$treatments %>%
    map_dfr(bind_cols, .id = "treatment")

  xl$demand <- params$demand %>%
    bind_rows(.id = "service")

  write_xlsx(xl, file)
}
