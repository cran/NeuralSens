% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/diag3Darray.R
\name{diag3Darray}
\alias{diag3Darray}
\title{Define function to create a 'diagonal' array or get the diagonal of an array}
\usage{
diag3Darray(x = 1, dim = length(x), out = "vector")
}
\arguments{
\item{x}{\code{number} or \code{vector} defining the value of the diagonal of \code{3D array}}

\item{dim}{\code{integer} defining the length of the diagonal. Default is \code{length(x)}.
If \code{length(x) != 1}, \code{dim} must be equal to \code{length(x)}.}

\item{out}{\code{character} specifying which type of diagonal to return (\code{"vector"}
or \code{"matrix"}). See \code{Details}}
}
\value{
\code{array} with all elements zero except the diagonal, with dimensions c(dim,dim,dim)
}
\description{
Define function to create a 'diagonal' array or get the diagonal of an array
}
\details{
The diagonal of a 3D array has been defined as those elements in positions c(int,int,int),
i.e., the three digits are the same.

If the diagonal should be returned, \code{out} specifies if it should return a \code{"vector"} with
the elements of position c(int,int,int), or \code{"matrix"} with the elements of position c(int,dim,int),
i.e., \code{dim = 2} -> elements (1,1,1),(2,1,2),(3,1,3),(1,2,1),(2,2,2),(3,2,3),(3,1,3),(3,2,3),(3,3,3).
}
\examples{
x <- diag3Darray(c(1,4,6), dim = 3)
x
# , , 1
#
# [,1] [,2] [,3]
# [1,]    1    0    0
# [2,]    0    0    0
# [3,]    0    0    0
#
# , , 2
#
# [,1] [,2] [,3]
# [1,]    0    0    0
# [2,]    0    4    0
# [3,]    0    0    0
#
# , , 3
#
# [,1] [,2] [,3]
# [1,]    0    0    0
# [2,]    0    0    0
# [3,]    0    0    6
diag3Darray(x)
# 1, 4, 6
}
