#' @importFrom magrittr %>%
#' @import rlang
#' @import ggplot
#' @importFrom plotly ggplotly layout config
#' @importFrom dplyr filter group_by summarise across mutate rename
#' @importFrom tidyr pivot_longer
#' @importFrom lubridate ymd
combined_plot <- function(model_output, treatment, params) {
  df <- bind_rows(
    models %>%
      get_model_output() %>%
      filter(.data$treatment == {{treatment}},
             .data$type == "treatment") %>%
      group_by(.data$date) %>%
      summarise(across(.data$value, sum), .groups = "drop") %>%
      mutate(type = "surge"),

    params$demand[[treatment]] %>%
      pivot_longer(-.data$month, names_to = "type") %>%
      rename(date = month) %>%
      mutate(across(date, ymd))
  )

  df <- bind_rows(df,
                  df %>%
                    group_by(date) %>%
                    summarise(type = "total", value = sum(value)) %>%
                    filter(date %in% c(df %>% filter(type == "underlying") %>% pull(date)))
                  )

  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~date,
          y = ~value,
          color = ~type
  ) %>%
    layout(showlegend = TRUE,
           xaxis = list(title = "Month"),
           yaxis = list(title = "# Referrals"))
}

#' @importFrom magrittr %>%
#' @importFrom dplyr filter group_by summarise across
#' @import rlang
#' @importFrom plotly plot_ly layout config
referrals_plot <- function(model_output, treatment) {
  df <- model_output %>%
    filter(.data$type == "new-referral",
           .data$treatment == {{treatment}}) %>%
    group_by(.data$date) %>%
    summarise(across(.data$value, sum), .groups = "drop")

  if (nrow(df) < 1) return(NULL)

  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~date,
          y = ~value,
          hovertext = NULL,
          hovertemplate = paste("<b>Month</b>: %{x}",
                                "<b>Referrals</b>: %{y:.0f}",
                                "<extra></extra>",
                                sep = "<br>")) %>%
    layout(showlegend = FALSE,
           xaxis = list(title = "Month"),
           yaxis = list(title = "New Referrals")) %>%
    config(displayModeBar = FALSE)
}

#' @importFrom magrittr %>%
#' @importFrom dplyr filter group_by summarise across inner_join mutate
#' @import rlang
#' @importFrom plotly plot_ly layout config
demand_plot <- function(model_output, appointments, treatment) {
  df <- model_output %>%
    filter(.data$type == "treatment",
           .data$treatment == {{treatment}}) %>%
    group_by(.data$date, .data$treatment) %>%
    summarise(across(.data$value, sum), .groups = "drop") %>%
    inner_join(appointments, by = "treatment") %>%
    mutate(no_appointments = .data$value * .data$average_monthly_appointments)

  if (nrow(df) < 1) return(NULL)

  plot_ly(df,
          type = "scatter",
          mode = "lines",
          x = ~date,
          y = ~no_appointments,
          hovertemplate = paste("<b>Month</b>: %{x}",
                                "<b>Demand</b>: %{y:.0f}",
                                "<extra></extra>",
                                sep = "<br>")) %>%
    layout(showlegend = FALSE,
           xaxis = list(title = "Month"),
           yaxis = list(title = "Demand")) %>%
    config(displayModeBar = FALSE)
}

#' @importFrom magrittr %>%
#' @importFrom dplyr filter group_by summarise across inner_join mutate
#' @importFrom forcats fct_reorder
#' @importFrom stringr str_wrap
#' @import ggplot2
#' @import rlang
popgroups_plot <- function(model_output, treatment) {
  model_output %>%
    filter(.data$type == "new-referral",
           .data$treatment == {{treatment}},
           day(.data$date) == 1) %>%
    group_by(.data$group) %>%
    summarise(`# Referrals` = round(sum(.data$value), 0), .groups = "drop") %>%
    filter(.data$`# Referrals` != 0) %>%
    mutate(across(.data$group, fct_reorder, .data$`# Referrals`)) %>%
    ggplot(aes(.data$group, .data$`# Referrals`)) +
    theme_minimal() +
    geom_col(fill = "#00c0ef") +
    geom_text(aes(label = .data$`# Referrals`),
              hjust = -0.1) +
    coord_flip(clip = "off") +
    scale_x_discrete(labels = function(x) str_wrap(x, 13)) +
    scale_y_continuous(expand = expansion(mult = c(0, .15))) +
    theme(axis.title.y = element_blank(),
          axis.ticks.y = element_blank(),
          plot.margin = margin(t = 0, r = 25, b = 0, l = 0, unit = "pt")
    )
}

#' @importFrom magrittr %>%
#' @importFrom dplyr mutate across rename
#' @importFrom tidyr pivot_longer
#' @importFrom forcats fct_rev
#' @importFrom glue glue
#' @import ggplot2
#' @importFrom plotly ggplotly layout config
surge_plot <- function(data) {
  p <- data %>%
    mutate(across(.data$`new-referral`, ~.x - .data$`new-treatment`)) %>%
    rename("Received treatment" = .data$`new-treatment`,
           "Referred, but not treated" = .data$`new-referral`) %>%
    pivot_longer(-.data$group) %>%
    mutate(across(.data$name, fct_rev),
           text = glue("<b>{name}</b><br>{value}")) %>%
    ggplot(aes(.data$value, .data$group, fill = .data$name, text = .data$text)) +
    geom_col() +
    scale_x_continuous(expand = expansion(c(0, 0.05))) +
    scale_fill_discrete(guide = guide_legend(reverse = TRUE)) +
    theme(panel.background = element_blank(),
          panel.grid = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line.x = element_line(),
          legend.title = element_blank(),
          legend.background = element_blank()) +
    labs(y = "",
         x = "Total Referrals / Treatments",
         caption = paste0("The total receiving services offered for each condition will never exceed the total",
                          "symptomatic over period referrals"))

  ggplotly(p, tooltip = "text") %>%
    layout(legend = list(xanchor = "right",
                         yanchor = "bottom",
                         x = 0.99,
                         y = 0.01)) %>%
    config(displayModeBar = FALSE)
}

#' @importFrom magrittr %>% %$%
#' @import rlang
#' @importFrom dplyr filter group_by summarise across bind_rows
#' @importFrom tidyr pivot_longer
#' @importFrom purrr set_names compose map array_tree
#' @importFrom lubridate day
#' @importFrom igraph graph_from_data_frame vertex.attributes
#'   vertex.attributes<- V get.edgelist layout.sugiyama
#' @importFrom plotly plot_ly layout config
create_graph <- function(model_output,
                         groups = unique(model_output$group),
                         conditions = unique(model_output$condition),
                         treatments = unique(model_output$treatment)) {
  df <- model_output %>%
    filter(.data$type == "treatment",
           .data$group %in% groups,
           .data$condition %in% conditions,
           .data$treatment %in% treatments,
           day(.data$date) == 1) %>%
    group_by(.data$group, .data$condition, .data$treatment) %>%
    summarise(across(.data$value, compose(round, sum)), .groups = "drop")

  if (nrow(df) < 1) return(NULL)

  # create a graph of groups to conditions and conditions to the treatment
  # note however, this graph is "reversed", e.g. treatment points to conditions
  # the layout didn't work otherwise.
  g <- bind_rows(
    df %>% group_by(from = .data$condition, to = .data$group),
    df %>% group_by(from = .data$treatment, to = .data$condition)
  ) %>%
    summarise(weight = sum(.data$value), .groups = "drop") %>%
    # remove any lines that after rounding sum to 0
    filter(.data$weight > 0) %>%
    graph_from_data_frame()

  # converts the graph to be a bipartite graph
  vertex.attributes(g)$type <- vertex.attributes(g)$name %in% unique(df$condition)

  # calculate the "weight" of each vertex
  vertex_weights <- df %>%
    pivot_longer(-.data$value, names_to = "type", values_to = "name") %>%
    group_by(.data$type, .data$name) %>%
    summarise(across(.data$value, sum), .groups = "drop")
  # convert to a named list: add in the current treatment as an option also
  vertex_weights <- set_names(vertex_weights$value, vertex_weights$name)

  # set the "weight" attribute of this vertex
  vertex.attributes(g)$weight <- vertex_weights[vertex.attributes(g)$name]

  # extract the vertices
  vs <- V(g)
  # and the edges
  es <- as.data.frame(get.edgelist(g))
  # create a layout for the graph ready to plot
  ly <- layout.sugiyama(g)$layout

  # extract the x- and y-coordinates from the layout
  xs <- ly[, 2]
  ys <- ly[, 1]

  p <- plot_ly(x = ~ xs,
               y = ~ ys,
               size = 1,
               mode = "markers",
               type = "scatter",
               text = paste0("<b>", vs$name, "</b>: ", round(vs$weight)),
               marker = list(
                 opacity = 1,
                 # set the size of each marker to be based on the amount of
                 # people in this group.
                 # take the weight of each vertex and divide by the total size,
                 # so this will convert into the range [0, 1]
                 # take the sqrt of this to make a non-linear increase in size
                 # - this makes smaller dots bigger than they should be
                 # multiply by 500 to make the dots visible (size in pixels?)
                 # ceiling it to turn into an integer
                 size = ceiling(sqrt(unname(vs$weight)) / sqrt(sum(df$value)) * 500)
               ),
               # NHS Blue
               color = I("#005EB8"),
               hoverinfo = "text")

  # iterate over all of the edges and build a shape for each edge: e.g. a line
  # connecting each pair of vertices
  edge_shapes <- map(array_tree(es), function(e) {
    # get the first and second vertex
    v0 <- which(vs$name == e$V1)
    v1 <- which(vs$name == e$V2)

    # create the points
    list(
      type = "line",
      line = list(color = "#030303", width = 1),
      # ensure th
      layer = "below",
      x0 = xs[v0],
      y0 = ys[v0],
      x1 = xs[v1],
      y1 = ys[v1]
    )
  })

  # render the plot, adding the edges
  layout(p,
         shapes = edge_shapes,
         xaxis = list(visible = FALSE),
         yaxis = list(visible = FALSE)) %>%
    config(displayModeBar = FALSE)
}

#' @importFrom magrittr %>%
#' @importFrom purrr map_dbl
#' @importFrom tibble enframe tribble tibble
#' @importFrom dplyr left_join
#' @importFrom tidyr fill
#' @import rlang
#' @import ggplot2
#' @importFrom plotly ggplotly
#' @importFrom packcircles circleProgressiveLayout circleLayoutVertices
bubble_plot <- function(params) {
  circle_pack_plot <- params$groups %>%
    map_dbl("size") %>%
    enframe(name = "subpopn") %>%
    left_join(
      tribble(
        ~subpopn,                         ~level_2,
        "Children & young people",        "Children & young people",
        "Students FE & HE",               NA,
        "Elderly alone",                  "Elderly alone",
        "General population",             "General population",
        "Domestic abuse victims",         "Other Adults and Specific Groups",
        "Family of COVID deceased",       NA,
        "Family of ICU survivors",        NA,
        "Newly unemployed",               NA,
        "Pregnant & New Mothers",         NA,
        "Parents",                        NA,
        "Health and care workers",        "Directly affected individuals",
        "ICU survivors",                  NA,
        "Learning disabilities & autism", "Existing Conditions",
        "Pre existing CMH illness",       NA,
        "Pre existing LTC",               NA,
        "Pre existing SMI",               NA
      ) %>%
        fill(.data$level_2),
      by = "subpopn"
    )

  packing <- circleProgressiveLayout(circle_pack_plot$value, sizetype = "area")
  circle_pack_plot <- cbind(circle_pack_plot, packing)

  dat_gg <- circleLayoutVertices(packing, npoints = 50) %>%
    left_join(tibble(level_2 = circle_pack_plot$level_2, id = 1:16), by = "id")

  p <- ggplot() +
    geom_polygon(data = dat_gg,
                 aes(.data$x, .data$y, group = .data$id, fill = as.factor(.data$level_2)),
                 colour = "black",
                 alpha = 0.6) +
    geom_text(data = circle_pack_plot,
              aes(.data$x, .data$y, size = 20, label = .data$subpopn)) +
    scale_size_continuous(range = c(1, 4)) +
    theme_void() +
    theme(legend.position = "none") +
    scale_fill_brewer(palette = "Set1") +
    coord_equal()

  ggplotly(p)
}
