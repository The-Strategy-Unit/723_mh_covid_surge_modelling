
pop_plot <- function(model_data) {
  df <- model_data %>%
    filter(type == "at-risk")

  df %>%
    ggplot(aes(time,
               value,
               colour = group,
               group = group,
               text = paste0(
                 "Time: ",
                 scales::number(time, accuracy = 0.1),
                 "\n",
                 "# referrals: ",
                 round(value, 0),
                 "\n",
                 "Group: ",
                 group
               ))) +
    geom_line() +
    labs(x = "Simulation Month",
         y = "# at Risk",
         colour = "")
}

demand_plot <- function(model_data, appointments) {
  df <- model_data %>%
    filter(type == "treatment") %>%
      group_by(time, treatment) %>%
      summarise(across(value, sum), .groups = "drop") %>%
      inner_join(appointments, by = "treatment") %>%
      mutate(no_appointments = value * average_monthly_appointments)

  df %>%
      ggplot(aes(
        time,
        no_appointments,
        colour = treatment,
        group = treatment,
        text = paste0(
          "Time: ",
          scales::number(time, accuracy = 0.1),
          "\n",
          "# Appointments: ",
          round(no_appointments, 0),
          "\n",
          "Treatment: ",
          treatment
        )
      )) +
      geom_line() +
      labs(x = "Simulation Month",
           y = "# Appointments",
           colour = "")
}
