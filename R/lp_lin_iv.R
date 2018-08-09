#' @name lp_lin_iv
#' @title Compute linear impulse responses with identified shock (instrument variable approach)
#' @description Compute linear impulse responses with local projections by Jordà (2005) and identified shock, i.e.
#' instrument variable approach (see e.g. Ramey and Zubairy, 2018).
#' @param endog_data A \link{data.frame}, containing the dependent variables.
#' @param instr One column \link{data.frame} including the values of the instrument to shock with.
#' The row length has to be the same as \emph{endog_data}.
#' @param lags_endog_lin NaN or integer. NaN if lag length criterion is used. Integer for number of lags for \emph{endog_data}.
#' @param exog_data NULL or a \link{data.frame}, containing exogenous data. The row length has to be the same as \emph{endog_data}.
#' @param lags_exog NULL or Integer. Integer for the number of lags for the exogenous data.
#' @param contemp_data A \link{data.frame}, containing exogenous data with contemporaneous impact.
#'                      The row length has to be the same as \emph{endog_data}.
#' @param lags_criterion NaN or character. NaN means that the number of lags
#'         will be given at \emph{lags_endog_lin}. The character refers to the corresponding lag length criterion ('AICc', 'AIC' or 'BIC').
#' @param max_lags NaN or integer. Maximum number of lags if \emph{lags_criterion} is character with lag length criterion. NaN otherwise.
#' @param trend Integer. No trend =  0 , include trend = 1, include trend and quadratic trend = 2.
#' @param shock_type Integer. Standard deviation shock = 0, unit shock = 1.
#' @param confint Double. Width of confidence bands. 68\% = 1, 90\% = 1.65, 95\% = 1.96.
#' @param hor Integer. Number of horizons for impulse responses.
#' @param num_cores NULL or Integer. The number of cores to use for the estimation. If NULL, the function will
#'                  use the maximum number of cores less one.
#'
#' @seealso \url{https://adaemmerp.github.io/lpirfs/README_docs.html}
#'
#' @return A list:
#'
#'
#'
#'\item{irf_lin_mean}{A \link{matrix} containing the impulse responses.
#'                    The row in each matrix denotes the responses of the \emph{ith}
#'                    variable to the (instrument) shock. The columns are the horizons.}
#'
#'\item{irf_lin_low}{A \link{matrix} containing all lower confidence bands of
#'                    the impulse responses, based on robust standard errors by Newey and West (1987).
#'                    Properties are equal to \emph{irf_lin_mean}.}
#'
#'\item{irf_lin_up}{A \link{matrix} containing all upper confidence bands of
#'                    the impulse responses, based on robust standard errors by Newey and West (1987).
#'                    Properties are equal to \emph{irf_lin_mean}.}
#'
#'\item{specs}{A list with properties of \emph{endog_data} for the plot function. It also contains
#'             lagged data (y_lin and x_lin) used for the estimations.}
#'
#'
#'
#' @export
#' @references
#' Akaike, H. (1974). "A new look at the statistical model identification", \emph{IEEE Transactions on Automatic Control}, 19 (6): 716–723.
#'
#' Auerbach, A. J., and  Gorodnichenko Y. (2012). "Measuring the Output Responses to Fiscal Policy."
#' \emph{American Economic Journal: Economic Policy}, 4 (2): 1-27.
#'
#' Hurvich, C. M., and  Tsai, C.-L. (1989), "Regression and time series model selection in small samples",
#' \emph{Biometrika}, 76(2): 297–307
#'
#' Jordà, Ò. (2005). "Estimation and Inference of Impulse Responses by Local Projections."
#' \emph{American Economic Review}, 95 (1): 161-182.
#'
#' Newey W.K., and West K.D. (1987). “A Simple, Positive-Definite, Heteroskedasticity and
#' Autocorrelation Consistent Covariance Matrix.” \emph{Econometrica}, 55: 703–708.
#'
#' Ramey, V.A., Zubairy, S. (2018). "Government Spending Multipliers in Good Times
#' and in Bad: Evidence from US Historical Data." \emph{Journal of Political Economy},
#' 126(2): 850 - 901.
#'
#' Schwarz, Gideon E. (1978). "Estimating the dimension of a model", \emph{Annals of Statistics}, 6 (2): 461–464.
#'
#'@author Philipp Adämmer
#'@import foreach
#'@examples
#'\donttest{
#'
#'# This example replicates a result from the Supplementary Appendix
#'# by Ramey and Zubairy (2018) (RZ-18).
#'
#'# Load data
#'  ag_data           <- ag_data
#'  sample_start      <- 7
#'  sample_end        <- dim(ag_data)[1]
#'
#'# Endogenous data
#'  endog_data        <- ag_data[sample_start:sample_end,3:5]
#'
#'# Shock ('Instrument')
#'  shock <- ag_data[sample_start:sample_end, 3]
#'
#'# Estimate linear model
#'  results_lin_iv <- lp_lin_iv(endog_data,
#'                                lags_endog_lin = 4,
#'                                instr          = shock,
#'                                exog_data      = NULL,
#'                                lags_exog      = NULL,
#'                                contemp_data   = NULL,
#'                                lags_criterion = NaN,
#'                                max_lags       = NaN,
#'                                trend          = 0,
#'                                shock_type     = 1,
#'                                confint        = 1.96,
#'                                hor            = 20,
#'                                num_cores      = NULL)
#'
#'
#'# Make and save plots
#'  iv_lin_plots    <- plot_lin(results_lin_iv)
#'
#'# * The first element of 'iv_lin_plots' shows the response of the first
#'#   variable (Gov) to a shock in the chosen 'instrument' (Gov).
#'# * The second element of 'iv_lin_plots' shows the response of the second
#'#   variable (Tax) to a shock in the 'instrument' (Gov).
#'# * ...
#'
#'# This plot replicates the left plot in the mid-panel of Figure 12 in the
#'# Supplementary Appendix by RZ-18.
#'  iv_lin_plots[[1]]
#'
#'# Show all impulse responses by using 'ggpubr' and 'gridExtra'
#'# The package does not depend on those packages so they have to be installed
#'  library(ggpubr)
#'  library(gridExtra)
#'
#' lin_plots_all <- sapply(iv_lin_plots, ggplotGrob)
#' marrangeGrob(lin_plots_all, nrow = ncol(endog_data), ncol = 1, top = NULL)
#'
#' }


lp_lin_iv <- function(endog_data,
                   instr          = NULL,
                   lags_endog_lin       = NULL,
                   exog_data      = NULL,
                   lags_exog      = NULL,
                   contemp_data   = NULL,
                   lags_criterion = NaN,
                   max_lags       = NaN,
                   trend          = NULL,
                   shock_type     = NULL,
                   confint        = NULL,
                   hor            = NULL,
                   num_cores      = NULL){


  # Check whether data is a data.frame
  if(!(is.data.frame(endog_data))){
    stop('The data has to be a data.frame().')
  }

  # Check whether data is a data.frame
  if(is.nan(lags_endog_lin) & !is.character(lags_criterion)){
    stop('"lags_endog_lin" can only be NaN if a lag length criterion is given.')
  }

  # Check whether instrument for shock is given
  if(is.null(instr)){
    stop('You have to provide an instrument to shock with.')
  }

  # Check whether instrument for shock is given
  if(!is.data.frame(instr)){
    stop('The instrument has to be given as a data.frame().')
  }

  # Check whether exogenous data is a data.frame
  if(!is.null(exog_data) & !is.data.frame(exog_data)){
    stop('Exogenous data has to be given as a data.frame.')
  }

  # Check whether lag length for exogenous data is given
  if(!is.null(exog_data) & is.null(lags_exog)){
    stop('Please provide a lag length for the exogenous data.')
  }


  # Give message when no linear model is provided
  if(is.null(exog_data)){
    message('You estimate the model without exogenous data.')
  }

  # Give message when no contemporaneous data is provided
  if(is.null(contemp_data)){
    message('You estimate the model without exogenous data with contemporaneous impact')
  }

  # Give message when no contemporaneous data is provided
  if(is.null(lags_criterion)){
    stop('"lags_criterion" has to be NaN or a character, specifying the lag length criterion.')
  }


  # Give error when no trend is given
  if(is.null(trend)){
    stop('Please specify whether and which type of trend to include.')
  }

  # Give error when no shock_type is given
  if(is.null(shock_type)){
    stop('Please specify which type of shock to use.')
  }


  # Check whether width for confidence intervals is given
  if(is.null(confint)){
    stop('Please specify a value for the width of the confidence bands.')
  }

  # Check whether number of horizons is given
  if(is.null(hor)){
    stop('Please specify the number of horizons.')
  }

  # Check whether wrong lag length criterion is given
  if(!(is.nan(lags_criterion)          | lags_criterion == 'AICc'|
       lags_criterion         == 'AIC' | lags_criterion == 'BIC')){
    stop('Possible lag length criteria are AICc, AIC or BIC. NaN if lag length is specified.')
  }

  # Check whether lags criterion and maximum number of lags are given
  if((is.character(lags_criterion)) &
     (!is.na(lags_endog_lin))){
    stop('You can not provide a lag criterion (AICc, AIC or BIC) and a fixed number of lags.
         Please set lags_endog_lin to NaN if you want to use a lag length criterion.')
  }

  # Check whether values for horizons are correct
  if(!(hor > 0) | is.nan(hor) | !(hor %% 1 == 0)){
    stop('The number of horizons has to be an integer and > 0.')
  }

  # Check whether trend is correctly specified
  if(!(trend %in% c(0,1,2))){
    stop('For trend please enter 0 = no trend, 1 = trend, 2 = trend and quadratic trend.')
  }

  # Check whether shock type is correctly specified
  if(!(shock_type %in% c(0,1))){
    stop('The shock_type has to be 0 = standard deviation shock or 1 = unit shock.')
  }

  # Check whether width of confidence bands is >=0
  if(!(confint >=0)){
    stop('The width of the confidence bands has to be >=0.')
  }



  # Create list to store inputs
  specs <- list()

  # Specify inputs
  specs$instr              <- instr
  specs$lags_endog_lin           <- lags_endog_lin
  specs$exog_data          <- exog_data
  specs$lags_exog          <- lags_exog
  specs$contemp_data       <- contemp_data
  specs$lags_criterion     <- lags_criterion
  specs$max_lags           <- max_lags
  specs$trend              <- trend
  specs$shock_type         <- shock_type
  specs$confint            <- confint
  specs$hor                <- hor
  specs$model_type         <- 1




# Function start

# Safe data frame specifications in 'specs for functions
  specs$starts         <- 1                       # Sample Start
  specs$ends           <- dim(endog_data)[1]      # Sample end
  specs$column_names   <- names(endog_data)       # Name endogenous variables
  specs$endog          <- ncol(endog_data)        # Set the number of endogenous variables

# Construct (lagged) endogenous data
  data_lin <- create_lin_data(specs, endog_data)

  y_lin    <- data_lin[[1]]
  x_lin    <- data_lin[[2]]

# Save endogenous and lagged exogenous data in specs
  specs$y_lin        <- y_lin
  specs$x_lin        <- x_lin



# Matrices to store OLS parameters
  b1        <- matrix(NaN, specs$endog, specs$endog)
  b1_low    <- matrix(NaN, specs$endog, specs$endog)
  b1_up     <- matrix(NaN, specs$endog, specs$endog)

# Matrices to store irfs for each horizon
  irf_mean  <-  matrix(NaN, specs$endog, specs$hor)
  irf_low   <-  irf_mean
  irf_up    <-  irf_mean

# 3D Arrays for all irfs
  irf_lin_mean  <-  matrix(NaN, nrow = specs$endog, ncol = specs$hor)
  irf_lin_low   <-  irf_lin_mean
  irf_lin_up    <-  irf_lin_mean

# Make cluster

# Make cluster
  if(is.null(num_cores)){
    num_cores     <- min(specs$endog, parallel::detectCores() - 1)
  }

  cl             <- parallel::makeCluster(num_cores)
  doParallel::registerDoParallel(cl)

# Decide whether lag lengths are given or have to be estimated
if(is.nan(specs$lags_criterion) == TRUE){

  # Loops to estimate local projections
  lin_irfs <- foreach(s         = 1:specs$endog,
                      .packages = 'lpirfs')  %dopar%{ # Accounts for the shocks

                        for (h in 1:(specs$hor)){   # Accounts for the horizons

                          # Create data
                          yy  <-   y_lin[h : dim(y_lin)[1], ]
                          xx  <-   x_lin[1 : (dim(x_lin)[1] - h + 1), ]

                          for (k in 1:specs$endog){ # Accounts for the reactions of the endogenous variables

                            # Estimate coefficients and newey west std.err
                            if(specs$endog == 1 ){
                              nw_results   <- lpirfs::newey_west(yy, xx, h)
                                         } else {
                              nw_results   <- lpirfs::newey_west(yy[, k], xx, h)
                            }

                            b              <- nw_results[[1]]
                            std_err        <- sqrt(diag(nw_results[[2]]))*specs$confint

                            irf_mean[k, h]  <-  b[2]
                            irf_low[k,  h]  <-  b[2] - std_err[2]
                            irf_up[k,   h]  <-  b[2] + std_err[2]

                          }
                        }

                        # Return irfs
                        return(list(irf_mean,  irf_low,  irf_up))
                      }

  # Fill arrays with irfs
  for(i in 1:specs$endog){

    # Fill irfs
    irf_lin_mean[ , ]   <- as.matrix(do.call(rbind, lin_irfs[[i]][1]))
    irf_lin_low[  , ]   <- as.matrix(do.call(rbind, lin_irfs[[i]][2]))
    irf_lin_up[   , ]   <- as.matrix(do.call(rbind, lin_irfs[[i]][3]))

  }


  ################################################################################
                                  } else {
  ################################################################################

  # Convert chosen lag criterion to number for loop
  lag_crit     <- switch(specs$lags_criterion,
                         'AICc'= 1,
                         'AIC' = 2,
                         'BIC' = 3)

  # Loops to estimate local projections.
  lin_irfs <- foreach(s          = 1:specs$endog,
                      .packages   = 'lpirfs')  %dopar% {

                        for (h in 1:specs$hor){     # Accounts for the horizon

                          for (k in 1:specs$endog){ # Accounts for endogenous reactions

                            # Find optimal lags
                            n_obs         <- nrow(endog_data) - h  # Number of maximum observations
                            val_criterion <- lpirfs::get_vals_lagcrit(y_lin, x_lin, lag_crit, h, k,
                                                                      specs$max_lags, n_obs)

                            # Set optimal lag length
                            lag_choice  <- which.min(val_criterion)

                            # Extract matrices based on optimal lag length
                            yy <- y_lin[[lag_choice]][, k]
                            yy <- yy[h: length(yy)]

                            xx <- x_lin[[lag_choice]]
                            xx <- xx[1:(dim(xx)[1] - h + 1),]

                            # Estimate coefficients and newey west std.err
                            nw_results     <- lpirfs::newey_west(yy, xx, h)
                            b              <- nw_results[[1]]
                            std_err        <- sqrt(diag(nw_results[[2]]))*specs$confint

                            irf_mean[k, h]  <-  b[2]
                            irf_low[k,  h]  <-  b[2] - std_err[2]
                            irf_up[k,   h]  <-  b[2] + std_err[2]

                          }
                        }

                        list(irf_mean,  irf_low,  irf_up)
                      }

  # Fill arrays with irfs
  for(i in 1:specs$endog){

    # Fill irfs
    irf_lin_mean[ ,]   <- as.matrix(do.call(rbind, lin_irfs[[i]][1]))
    irf_lin_low[  ,]   <- as.matrix(do.call(rbind, lin_irfs[[i]][2]))
    irf_lin_up[   ,]   <- as.matrix(do.call(rbind, lin_irfs[[i]][3]))

  }


  ###################################################################################################

}

# Close cluster
parallel::stopCluster(cl)

list(irf_lin_mean = irf_lin_mean, irf_lin_low = irf_lin_low,
     irf_lin_up   = irf_lin_up, specs = specs)
}