% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/select_spatial_predictors_recursive.R
\name{select_spatial_predictors_recursive}
\alias{select_spatial_predictors_recursive}
\title{Finds optimal combinations of spatial predictors}
\usage{
select_spatial_predictors_recursive(
  data = NULL,
  dependent.variable.name = NULL,
  predictor.variable.names = NULL,
  distance.matrix = NULL,
  distance.thresholds = NULL,
  ranger.arguments = NULL,
  spatial.predictors.df = NULL,
  spatial.predictors.ranking = NULL,
  weight.r.squared = 0.25,
  weight.penalization.n.predictors = 0,
  n.cores = parallel::detectCores() - 1,
  cluster = NULL
)
}
\arguments{
\item{data}{Data frame with a response variable and a set of predictors. Default: \code{NULL}}

\item{dependent.variable.name}{Character string with the name of the response variable. Must be in the column names of \code{data}. Default: \code{NULL}}

\item{predictor.variable.names}{Character vector with the names of the predictive variables. Every element of this vector must be in the column names of \code{data}. Default: \code{NULL}}

\item{distance.matrix}{Squared matrix with the distances among the records in \code{data}. The number of rows of \code{distance.matrix} and \code{data} must be the same. If not provided, the computation of the Moran's I of the residuals is omitted. Default: \code{NULL}}

\item{distance.thresholds}{Numeric vector with neighborhood distances. All distances in the distance matrix below each value in \code{dustance.thresholds} are set to 0 for the computation of Moran's I. If \code{NULL}, it defaults to seq(0, max(distance.matrix), length.out = 4). Default: \code{NULL}}

\item{ranger.arguments}{Named list with \link[ranger]{ranger} arguments (other arguments of this function can also go here). All \link[ranger]{ranger} arguments are set to their default values except for 'importance', that is set to 'permutation' rather than 'none'. Please, consult the help file of \link[ranger]{ranger} if you are not familiar with the arguments of this function.}

\item{spatial.predictors.df}{Data frame of spatial predictors.}

\item{spatial.predictors.ranking}{Ranking of predictors returned by \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}}.}

\item{weight.r.squared}{Numeric between 0 and 1, weight of R-squared in the optimization index. Default: \code{0.25}}

\item{weight.penalization.n.predictors}{Numeric between 0 and 1, weight of the penalization for the number of spatial predictors added in the optimization index. Default: \code{0}}

\item{n.cores}{Integer, number of cores to use. Default: \code{parallel::detectCores() - 1}}

\item{cluster}{A cluster definition generated by \code{parallel::makeCluster()}. Default: \code{NULL}}
}
\value{
A list with two slots: \code{optimization}, a data frame with the index of the spatial predictor added on each iteration, the spatial correlation of the model residuals, and the R-squared of the model, and \code{best.spatial.predictors}, that is a character vector with the names of the spatial predictors that minimize the Moran's I of the residuals and maximize the R-squared of the model.
}
\description{
Selects spatial predictors following these steps:
\enumerate{
\item Gets the spatial predictors ranked by \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}} and fits a model of the form \code{y ~ predictors + best_spatial_predictor_1}. The Moran's I of the residuals of this model is used as reference value for the next step.
\item The remaining spatial predictors are introduced again into \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}}, and the spatial predictor with the highest ranking is introduced in a new model of the form \code{y ~  predictors + best_spatial_predictor_1 + best_spatial_predictor_2}.
\item Steps 1 and 2 are repeated until the Moran's I doesn't improve for a number of repetitions equal to the 20 percent of the total number of spatial predictors introduced in the function.
}
This method allows to select the smallest set of spatial predictors that have the largest joint effect in reducing the spatial correlation of the model residuals, while maintaining the model's R-squared as high as possible. As a consequence of running \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}} on each iteration, this method includes in the final model less spatial predictors than the sequential method implemented in \code{\link[=select_spatial_predictors_sequential]{select_spatial_predictors_sequential()}} would do, while minimizing spatial correlation and maximizing the R squared of the model as much as possible.
}
\details{
The algorithm works as follows. If the function \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}} returns 10 ranked spatial predictors (sp1 to sp10, being sp7 the best one), \code{\link[=select_spatial_predictors_recursive]{select_spatial_predictors_recursive()}} is going to first fit the model \code{y ~ predictors + sp7}. Then, the spatial predictors sp2 to sp9 are again ranked with \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}} using the model \code{y ~ predictors + sp7} as reference (at this stage, some of the spatial predictors might be dropped due to lack of effect). When the new ranking of spatial predictors is ready (let's say they are sp5, sp3, and sp4), the best one (sp5) is included in the model \code{y ~ predictors + sp7 + sp5}, and the remaining ones go again to \code{\link[=rank_spatial_predictors]{rank_spatial_predictors()}} to repeat the process until spatial predictors are depleted.
}
\examples{
if(interactive()){

#loading example data
data(distance_matrix)
data(plant_richness_df)

#response and preditor names
dependent.variable.name = "richness_species_vascular"
predictor.variable.names = colnames(plant_richness_df)[5:21]

#non-spatial model
model <- rf(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  distance.matrix = distance_matrix,
  distance.thresholds = 0,
  n.cores = 1
)

#preparing spatial predictors
spatial.predictors <- mem_multithreshold(
  distance.matrix = distance_matrix,
  distance.thresholds = 0
)

#ranking spatial predictors
spatial.predictors.ranking <- rank_spatial_predictors(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  spatial.predictors.df = spatial.predictors,
  ranking.method = "moran",
  reference.moran.i = model$spatial.correlation.residuals$max.moran,
  distance.matrix = distance_matrix,
  distance.thresholds = 0,
  n.cores = 1
)

#selecting the best subset of predictors
selection <- select_spatial_predictors_recursive(
  data = plant_richness_df,
  dependent.variable.name = dependent.variable.name,
  predictor.variable.names = predictor.variable.names,
  distance.matrix = distance_matrix,
  distance.thresholds = 0,
  spatial.predictors.df = spatial.predictors,
  spatial.predictors.ranking = spatial.predictors.ranking,
  n.cores = 1
)

selection$optimization
selection$best.spatial.predictors
plot_optimization(selection$optimization)

}
}
