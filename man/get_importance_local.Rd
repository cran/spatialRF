% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_importance_local.R
\name{get_importance_local}
\alias{get_importance_local}
\title{Gets the local importance data frame from a model}
\usage{
get_importance_local(model)
}
\arguments{
\item{model}{A model fitted with \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, or \code{\link[=rf_spatial]{rf_spatial()}}. Default: NULL}
}
\value{
A data frame with variable names and local importance scores.
}
\description{
Gets local importance scores from \code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, and \code{\link[=rf_spatial]{rf_spatial()}} models.
}
\examples{
if(interactive()){

#loading example data
data(plant_richness_df)
data(distance_matrix)

#fittinga random forest model
rf.model <- rf(
  data = plant_richness_df,
  dependent.variable.name = "richness_species_vascular",
  predictor.variable.names = colnames(plant_richness_df)[5:21],
  distance.matrix = distance_matrix,
  distance.thresholds = 0,
  n.cores = 1,
  verbose = FALSE
)

#getting importance scores
x <- get_importance_local(rf.model)
x

}
}
\seealso{
\code{\link[=rf]{rf()}}, \code{\link[=rf_repeat]{rf_repeat()}}, \code{\link[=rf_spatial]{rf_spatial()}}, \code{\link[=plot_importance]{plot_importance()}}, \code{\link[=print_importance]{print_importance()}}.
}
