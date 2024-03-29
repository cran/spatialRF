% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/is_binary.R
\name{is_binary}
\alias{is_binary}
\title{Checks if dependent variable is binary with values 1 and 0}
\usage{
is_binary(data = NULL, dependent.variable.name = NULL)
}
\arguments{
\item{data}{Data frame with a response variable and a set of predictors. Default: \code{NULL}}

\item{dependent.variable.name}{Character string with the name of the response variable. Must be in the column names of \code{data}. Default: \code{NULL}}
}
\value{
Logical.
}
\description{
Returns \code{TRUE} if \code{dependent.variable.name} is a binary variable with the values 1 and 0.
}
\examples{
if(interactive()){

 #dummy data frame
 data <- data.frame(
   response = c(0, 0, 0, 1, 1)
 )

 #checking if response is binary
 is_binary(
   data = data,
   dependent.variable.name = "response"
 )

}
}
