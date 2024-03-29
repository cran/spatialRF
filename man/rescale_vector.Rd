% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rescale_vector.R
\name{rescale_vector}
\alias{rescale_vector}
\title{Rescales a numeric vector into a new range}
\usage{
rescale_vector(
  x = NULL,
  new.min = 0,
  new.max = 1,
  integer = FALSE
)
}
\arguments{
\item{x}{Numeric vector. Default: \code{NULL}}

\item{new.min}{New minimum value. Default: \code{0}}

\item{new.max}{New maximum value. Default: \code{1}}

\item{integer}{Logical, if \code{TRUE}, coerces the output to integer. Default: \code{FALSE}}
}
\value{
A numeric vector of the same length as x, but with its values rescaled between \code{new.min} and \code{new.max.}
}
\description{
Rescales a numeric vector to a new range.
}
\examples{
if(interactive()){

 out <- rescale_vector(
   x = rnorm(100),
   new.min = 0,
   new.max = 100,
   integer = TRUE
   )
   out

}
}
