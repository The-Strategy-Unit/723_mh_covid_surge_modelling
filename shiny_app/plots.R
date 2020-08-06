
referrals_plot <- function(model_output, treatment) {
  df <- model_output %>%
    filter(type == "new-referral", treatment == {{treatment}}) %>%
    group_by(date) %>%
    summarise(across(value, sum), .groups = "drop")

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
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Month"),
                   yaxis = list(title = "New Referrals")) %>%
    plotly::config(displayModeBar = FALSE)
}

demand_plot <- function(model_output, appointments, treatment) {
  df <- model_output %>%
    filter(type == "treatment", treatment == {{treatment}}) %>%
    group_by(date, treatment) %>%
    summarise(across(value, sum), .groups = "drop") %>%
    inner_join(appointments, by = "treatment") %>%
    mutate(no_appointments = value * average_monthly_appointments)

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
    plotly::layout(showlegend = FALSE,
                   xaxis = list(title = "Month"),
                   yaxis = list(title = "Demand")) %>%
    plotly::config(displayModeBar = FALSE)
}

popgroups_plot <- function(model_output, treatment) {
  model_output %>%
    filter(type == "new-referral",
           treatment == {{treatment}},
           day(date) == 1) %>%
    group_by(group) %>%
    summarise(`# Referrals` = round(sum(value), 0), .groups = "drop") %>%
    filter(`# Referrals` != 0) %>%
    mutate_at("group", fct_reorder, quo(`# Referrals`)) %>%
    ggplot(aes(group, `# Referrals`)) +
    theme_minimal() +
    geom_col(fill = "#00c0ef") +
    geom_text(aes(label = `# Referrals`),
              hjust = -0.1) +
    coord_flip(clip = "off") +
    scale_x_discrete(labels = function(x) str_wrap(x, 13)) +
    scale_y_continuous(expand = expansion(mult = c(0, .15))) +
    theme(axis.title.y = element_blank(),
          axis.ticks.y = element_blank(),
          plot.margin = margin(t = 0, r = 25, b = 0, l = 0, unit = "pt")
    )
}

surge_plot <- function(data) {
  p <- data %>%
    mutate(across(`new-referral`, `-`, `new-treatment`)) %>%
    rename("Received treatment" = `new-treatment`,
           "Referred, but not treated" = `new-referral`) %>%
    pivot_longer(-group) %>%
    mutate(across(name, fct_rev),
           text = glue("<b>{name}</b><br>{value}")) %>%
    ggplot(aes(value, group, fill = name, text = text)) +
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
    plotly::layout(legend = list(xanchor = "right",
                                 yanchor = "bottom",
                                 x = 0.99,
                                 y = 0.01)) %>%
    plotly::config(displayModeBar = FALSE)
}

create_graph <- function(model_output,
                         groups = unique(model_output$group),
                         conditions = unique(model_output$condition),
                         treatments = unique(model_output$treatment)) {
  df <- model_output %>%
    filter(type == "treatment",
           group %in% groups,
           condition %in% conditions,
           treatment %in% treatments,
           day(date) == 1) %>%
    group_by(group, condition, treatment) %>%
    summarise(across(value, compose(round, sum)), .groups = "drop")

  if (nrow(df) < 1) return(NULL)

  # create a graph of groups to conditions and conditions to the treatment
  # note however, this graph is "reversed", e.g. treatment points to conditions
  # the layout didn't work otherwise.
  g <- bind_rows(
    df %>% group_by(from = condition, to = group),
    df %>% group_by(from = treatment, to = condition)
  ) %>%
    summarise(weight = sum(value), .groups = "drop") %>%
    # remove any lines that after rounding sum to 0
    filter(weight > 0) %>%
    graph_from_data_frame()

  # converts the graph to be a bipartite graph
  vertex.attributes(g)$type <- vertex.attributes(g)$name %in% unique(df$condition)

  # calculate the "weight" of each vertex
  vertex_weights <- df %>%
    pivot_longer(-value, names_to = "type", values_to = "name") %>%
    group_by(type, name) %>%
    summarise(across(value, sum), .groups = "drop") %$%
    # convert to a named list: add in the current treatment as an option also
    set_names(value, name)

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
  plotly::layout(p,
                 shapes = edge_shapes,
                 xaxis = list(visible = FALSE),
                 yaxis = list(visible = FALSE)) %>%
    plotly::config(displayModeBar = FALSE)
}
