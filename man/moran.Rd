% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/moran.R
\name{moran}
\alias{moran}
\title{Moran's I test}
\usage{
moran(
  x = NULL,
  distance.matrix = NULL,
  distance.threshold = NULL,
  verbose = TRUE
)
}
\arguments{
\item{x}{Numeric vector, generally model residuals, Default: \code{NULL}}

\item{distance.matrix}{Distance matrix among cases in \code{x}. The number of rows of this matrix must be equal to the length of \code{x}. Default: \code{NULL}}

\item{distance.threshold}{numeric value in the range of values available in \code{distance.matrix}. Distances below such threshold are set to 0. Default: \code{NULL} (which defaults to 0).}

\item{verbose}{Logical, if \code{TRUE}, prints a Moran's I plot. Default: \code{TRUE}}
}
\value{
A list with three named slots:
\itemize{
\item \code{test}: Data frame with observed and expected Moran's I values, p-value, and interpretation.
\item \code{plot}: Moran's plot of the vector x against the spatial lags of x.
\item \code{plot.df}: Data used in the Moran's plot.
}
}
\description{
Computes the spatial correlation coefficient (Moran's I) of a vector given a distance matrix, and a distance threshold used to define "neighborhood".
}
\details{
Inspired in the \code{Moran.I()} function of the \href{https://cran.r-project.org/package=ape}{ape} package.
}
\examples{
if(interactive()){

 #loading example data
 data(distance_matrix)
 data(plant_richness)

 #Moran's I of the response variable
 out <- moran(
   x = plant_richness$richness_species_vascular,
   distance.matrix = distance_matrix
   )
 out

}
}
\seealso{
\code{\link[=moran_multithreshold]{moran_multithreshold()}}
}
