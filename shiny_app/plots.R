
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

create_graph <- function(df, treatment) {
  g <- bind_rows(
    df %>%
      select(from = condition, to = group, weight = value),
    df %>%
      group_by(from = treatment, to = condition) %>%
      summarise(weight = sum(value), .groups = "drop")
  ) %>%
    graph_from_data_frame()

  vertex.attributes(g)$type <- vertex.attributes(g)$name %in% unique(df$condition)

  vertex_weights <- bind_rows(
    select(df, type = group, value),
    select(df, type = condition, value)
  ) %>%
    group_by(type) %>%
    summarise(across(value, sum), .groups = "drop") %$%
    set_names(value, type) %>%
    c(IAPT = sum(df$value))

  vertex.attributes(g)$weight <- vertex_weights[vertex.attributes(g)$name]

  vs <- V(g)
  es <- as.data.frame(get.edgelist(g))

  Nv <- length(vs)
  Ne <- length(es[1]$V1)

  L <- layout.sugiyama(g)$layout

  Xn <- L[,2]
  Yn <- L[,1]

  p <- plot_ly(x = ~ Xn,
               y = ~ Yn,
               size = 1,
               mode = "markers",
               type = "scatter",
               text = paste0("<b>", vs$name, "</b>: ", round(vs$weight)),
               marker = list(
                 opacity = 1,
                 size = unname(vs$weight) / sum(df$value) * 500
               ),
               color = I("#005EB8"),
               hoverinfo = "text")

  edge_shapes <- map(array_tree(es), function(e) {
    v0 <- which(vs$name == e$V1)
    v1 <- which(vs$name == e$V2)

    list(
      type = "line",
      line = list(color = "#030303", width = 1),
      layer = "below",
      x0 = Xn[v0],
      y0 = Yn[v0],
      x1 = Xn[v1],
      y1 = Yn[v1]
    )
  })

  plotly::layout(p,
                 shapes = edge_shapes,
                 xaxis = list(visible = FALSE),
                 yaxis = list(visible = FALSE)) %>%
    plotly::config(displayModeBar = FALSE)
}


