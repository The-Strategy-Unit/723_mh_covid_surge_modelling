% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_referrals.R
\name{referrals_plot}
\alias{referrals_plot}
\alias{referrals_plot_data}
\title{Referrals Plot}
\usage{
referrals_plot(model_output, treatment)

referrals_plot_data(model_output, treatment)
}
\arguments{
\item{model_output}{output from \code{run_model()} and \code{get_model_output()}}

\item{treatment}{a name of a treatment to filter by}
}
\value{
\code{referrals_plot()}: a plotly chart

\code{referrals_plot_data()}: a summarised version of \code{model_output}
}
\description{
Generates a plot that shows the referrals generated by the model.
}
