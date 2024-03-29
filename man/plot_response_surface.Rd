% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_response_surface.R
\name{plot_response_surface}
\alias{plot_response_surface}
\title{Plots the response surfaces of a random forest model}
\usage{
plot_response_surface(
  model = NULL,
  a = NULL,
  b = NULL,
  quantiles = 0.5,
  grid.resolution = 100,
  point.size.range = c(0.5, 2.5),
  point.alpha = 1,
  fill.color = viridis::viridis(100, option = "F", direction = -1, alpha = 0.9),
  point.color = "gray30",
  verbose = TRUE
)
}
\arguments{
\item{model}{A model fitted with \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, or \code{\link[=rf_spatial]{rf_spatial()}}. Default \code{NULL}}

\item{a}{Character string, name of a model predictor. If \code{NULL}, the most important variable in \code{model} is selected. Default: \code{NULL}}

\item{b}{Character string, name of a model predictor. If \code{NULL}, the second most important variable in \code{model} is selected. Default: \code{NULL}}

\item{quantiles}{Numeric vector between 0 and 1. Argument \code{probs} of the function \link[stats]{quantile}. Quantiles to set the other variables to. Default: \code{0.5}}

\item{grid.resolution}{Integer between 20 and 500. Resolution of the plotted surface Default: \code{100}}

\item{point.size.range}{Numeric vector of length 2 with the range of point sizes used by \link[ggplot2]{geom_point}. Using \code{c(-1, -1)} removes the points. Default: \code{c(0.5, 2.5)}}

\item{point.alpha}{Numeric between 0 and 1, transparency of the points. Setting it to \code{0} removes all points. Default: \code{1}.}

\item{fill.color}{Character vector with hexadecimal codes (e.g. "#440154FF" "#21908CFF" "#FDE725FF"), or function generating a palette (e.g. \code{viridis::viridis(100)}). Default: \code{viridis::viridis(100, option = "F", direction = -1, alpha = 0.9)}}

\item{point.color}{Character vector with a color name (e.g. "red4"). Default: \code{gray30}}

\item{verbose}{Logical, if TRUE the plot is printed. Default: \code{TRUE}}
}
\value{
A list with slots named after the selected \code{quantiles}, each one with a ggplot.
}
\description{
Plots response surfaces for any given pair of predictors in a \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, or \code{\link[=rf_spatial]{rf_spatial()}} model.
}
\details{
All variables that are not \code{a} or \code{b} in a response curve are set to the values of their respective quantiles to plot the response surfaces. The output list can be plotted all at once with \code{patchwork::wrap_plots(p)} or \code{cowplot::plot_grid(plotlist = p)}, or one by one by extracting each plot from the list.
}
\examples{
if(interactive()){

#load example data
data(plant_richness_df)

#fit random forest model
out <- rf(
 data = plant_richness_df,
 dependent.variable.name = "richness_species_vascular",
 predictor.variable.names = colnames(plant_richness_df)[5:21],
 n.cores = 1,
 verbose = FALSE
)

#plot interactions between most important predictors
plot_response_surfaces(x = out)


}
}
\seealso{
\code{\link[=plot_response_curves]{plot_response_curves()}}
}
