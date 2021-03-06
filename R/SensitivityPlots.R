#' Plot sensitivities of a neural network model
#'
#' @description Function to plot the sensitivities created by \code{\link[NeuralSens]{SensAnalysisMLP}}.
#' @param sens \code{SensAnalysisMLP} object created by \code{\link[NeuralSens]{SensAnalysisMLP}} or \code{HessMLP} object
#' created by \code{\link[NeuralSens]{HessianMLP}}.
#' @param der \code{logical} indicating if density plots should be created. By default is \code{TRUE}
#' @param zoom \code{logical} indicating if the distributions should be zoomed when there is any of them which is too tiny to be appreciated in the third plot.
#' \code{\link[ggforce]{facet_zoom}} function from \code{ggforce} package is required.
#' @param quit.legend \code{logical} indicating if legend of the third plot should be removed. By default is \code{FALSE}
#' @param output \code{numeric} or {character} specifying the output neuron or output name to be plotted.
#' By default is the first output (\code{output = 1}).
#' @return List with the following plot for each output: \itemize{ \item Plot 1: colorful plot with the
#'   classification of the classes in a 2D map \item Plot 2: b/w plot with
#'   probability of the chosen class in a 2D map \item Plot 3: plot with the
#'   stats::predictions of the data provided if param \code{der} is \code{FALSE}}
#' @examples
#' ## Load data -------------------------------------------------------------------
#' data("DAILY_DEMAND_TR")
#' fdata <- DAILY_DEMAND_TR
#'
#' ## Parameters of the NNET ------------------------------------------------------
#' hidden_neurons <- 5
#' iters <- 250
#' decay <- 0.1
#'
#' ################################################################################
#' #########################  REGRESSION NNET #####################################
#' ################################################################################
#' ## Regression dataframe --------------------------------------------------------
#' # Scale the data
#' fdata.Reg.tr <- fdata[,2:ncol(fdata)]
#' fdata.Reg.tr[,3] <- fdata.Reg.tr[,3]/10
#' fdata.Reg.tr[,1] <- fdata.Reg.tr[,1]/1000
#'
#' # Normalize the data for some models
#' preProc <- caret::preProcess(fdata.Reg.tr, method = c("center","scale"))
#' nntrData <- predict(preProc, fdata.Reg.tr)
#'
#' #' ## TRAIN nnet NNET --------------------------------------------------------
#' # Create a formula to train NNET
#' form <- paste(names(fdata.Reg.tr)[2:ncol(fdata.Reg.tr)], collapse = " + ")
#' form <- formula(paste(names(fdata.Reg.tr)[1], form, sep = " ~ "))
#'
#' set.seed(150)
#' nnetmod <- nnet::nnet(form,
#'                            data = nntrData,
#'                            linear.output = TRUE,
#'                            size = hidden_neurons,
#'                            decay = decay,
#'                            maxit = iters)
#' # Try SensAnalysisMLP
#' sens <- NeuralSens::SensAnalysisMLP(nnetmod, trData = nntrData, plot = FALSE)
#' NeuralSens::SensitivityPlots(sens)
#' @export SensitivityPlots
SensitivityPlots <- function(sens = NULL, der = TRUE,
                             zoom = TRUE, quit.legend = FALSE,
                             output = 1) {
  if (is.array(der)) stop("der argument is no more the raw sensitivities due to creation of SensMLP class. Check ?SensitivityPlots for more information")
  if (is.HessMLP(sens)) {
    sens <- HessToSensMLP(sens)
  }
  plotlist <- list()
  sens_orig <- sens
  pl <- list()
  for (out in 1:length(sens_orig$sens)) {
    sens <- sens_orig$sens[[out]]
    raw_sens <- sens_orig$raw_sens[[out]]
    # Order sensitivity measures by importance order
    sens <- sens[order(sens$meanSensSQ),]
    sens$varNames <- factor(rownames(sens), levels = rownames(sens)[order(sens$meanSensSQ)])

    plotlist[[1]] <- ggplot2::ggplot(sens) +
      ggplot2::geom_point(ggplot2::aes(x = 0, y = 0), size = 5, color = "blue") +
      ggplot2::geom_hline(ggplot2::aes(yintercept = 0), color = "blue") +
      ggplot2::geom_vline(ggplot2::aes(xintercept = 0), color = "blue") +
      ggplot2::geom_point(ggplot2::aes_string(x = "mean", y = "std")) +
      ggplot2::geom_label(ggplot2::aes_string(x = "mean", y = "std", label = "varNames"),
                          position = "nudge") +
      # coord_cartesian(xlim = c(min(sens$mean,0)-0.1*abs(min(sens$mean,0)), max(sens$mean)+0.1*abs(max(sens$mean))), ylim = c(0, max(sens$std)*1.1))+
      ggplot2::labs(x = "mean(Sens)", y = "std(Sens)")


    plotlist[[2]] <- ggplot2::ggplot(sens) +
      ggplot2::geom_col(ggplot2::aes_string(x = "varNames", y = "meanSensSQ", fill = "meanSensSQ")) +
      ggplot2::labs(x = "Input variables", y = "mean(Sens^2)") + ggplot2::guides(fill = "none")

    if (der) {
      # If the raw values of the derivatives has been passed to the function
      # the density plots of each of these derivatives can be extracted and plotted
      der2 <- as.data.frame(raw_sens)
      names(der2) <- dimnames(raw_sens)[[2]]
      # Remove any variable which is all zero -> pruned variable
      der2 <- der2[,!sapply(der2,function(x){all(x ==  0)})]
      dataplot <- reshape2::melt(der2, measure.vars = names(der2))

      # Check the right x limits for the density plots
      quant <- stats::quantile(abs(dataplot$value), c(0.8, 1))
      if (10*quant[1] < quant[2]) { # Distribution has too much dispersion
        xlim <- c(1,-1)*max(abs(stats::quantile(dataplot$value, c(0.2,0.8))))
      } else {
        xlim <- c(-1.1, 1.1)*max(abs(dataplot$value), na.rm = TRUE)
      }

      plotlist[[3]] <- ggplot2::ggplot(dataplot) +
        ggplot2::geom_density(ggplot2::aes_string(x = "value", fill = "variable"),
                              alpha = 0.4,
                              bw = "bcv") +
        ggplot2::labs(x = "Sens", y = "density(Sens)") +
        ggplot2::xlim(xlim)
      # ggplot2::xlim(-2 * max(sens$std, na.rm = TRUE), 2 * max(sens$std, na.rm = TRUE))
      # Check if ggforce package is installed in the device
      # if it's installed and there are any density distribution that is
      # too small compared with others, make a facet_zoom to show better all distributions
      if (zoom) {
        if (requireNamespace("ggforce")) {
          maxd <- c()
          for (i in 1:ncol(der2)) {
            maxd <- c(maxd, max(stats::density(der2[,i])$y))
          }
          if (max(maxd) > 10*min(maxd)){
            plotlist[[3]] <- plotlist[[3]] + ggforce::facet_zoom(zoom.size = 1, ylim = c(0,1.25*min(maxd)))
          }
        }
      }
      if (quit.legend) {
        plotlist[[3]] <- plotlist[[3]] +
          ggplot2::theme(legend.position = "none")
      }
    }
    pl[[out]] <- plotlist
  }
  # Plot the list of plots created before
  gridExtra::grid.arrange(grobs = pl[[ifelse(is.character(output), which(output == names(sens_orig$sens)), output)]],
                          nrow  = length(plotlist),
                          ncols = 1)
  # Return the plots created if the user want to edit them by hand
  return(invisible(plotlist))
}
