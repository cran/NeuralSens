% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\name{simdata}
\alias{simdata}
\title{Simulated data to test the package functionalities}
\format{
A data frame with 2000 rows and 4 variables:
\describe{
  \item{X1}{Random input 1}
  \item{X2}{Random input 2}
  \item{X3}{Random input 3}
  \item{Y}{Output}
}
}
\description{
\code{data.frame} with 2000 rows of 4 columns with 3
input variables \code{X1, X2, X3} and one output variable \code{Y}.
The data is already scaled, and has been generated using the following code:

\code{set.seed(150)}


\code{simdata <- data.frame(}
\code{   "X1" = rnorm(2000, 0, 1),}
\code{   "X2" = rnorm(2000, 0, 1),}
\code{   "X3" = rnorm(2000, 0, 1)}
\code{ )}


\code{ simdata$Y <- simdata$X1^2 + 0.5*simdata$X2 + 0.1*rnorm(2000, 0, 1)}
}
\references{
Pizarroso J, Portela J, Muñoz A (2022). NeuralSens: Sensitivity Analysis of
Neural Networks. Journal of Statistical Software, 102(7), 1-36.
}
\author{
Jaime Pizarroso Gonzalo
}
\keyword{data}
