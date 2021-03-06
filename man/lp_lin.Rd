% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lp_lin.R
\name{lp_lin}
\alias{lp_lin}
\title{Compute linear impulse responses}
\usage{
lp_lin(endog_data, lags_endog_lin = NULL, lags_criterion = NULL,
  max_lags = NULL, trend = NULL, shock_type = NULL, confint = NULL,
  hor = NULL, exog_data = NULL, lags_exog = NULL,
  contemp_data = NULL, num_cores = NULL)
}
\arguments{
\item{endog_data}{A \link{data.frame}, containing the endogenous variables for the VAR. The Cholesky decomposition is based on the
column order.}

\item{lags_endog_lin}{NaN or integer. NaN if lag length criterion is used. Integer for number of lags for \emph{endog_data}.}

\item{lags_criterion}{NaN or character. NaN means that the number of lags
has to be given at \emph{lags_endog_lin}. The character specifies the lag length criterion ('AICc', 'AIC' or 'BIC').}

\item{max_lags}{NaN or integer. Maximum number of lags if \emph{lags_criterion} is given. NaN otherwise.}

\item{trend}{Integer. No trend =  0 , include trend = 1, include trend and quadratic trend = 2.}

\item{shock_type}{Integer. Standard deviation shock = 0, unit shock = 1.}

\item{confint}{Double. Width of confidence bands. 68\% = 1; 90\% = 1.65; 95\% = 1.96.}

\item{hor}{Integer. Number of horizons for impulse responses.}

\item{exog_data}{A \link{data.frame}, containing exogenous variables for the VAR. The row length has to be the same as \emph{endog_data}.
Lag lengths for exogenous variables have to be given and will no be determined via a lag length criterion.}

\item{lags_exog}{Integer. Number of lags for the exogenous variables.}

\item{contemp_data}{A \link{data.frame}, containing exogenous data with contemporaneous impact. The row length has to be the same as \emph{endog_data}.}

\item{num_cores}{NULL or Integer. The number of cores to use for the estimation. If NULL, the function will
use the maximum number of cores minus one.}
}
\value{
A list containing:


\item{irf_lin_mean}{A three 3D \link{array}, containing all impulse responses for all endogenous variables.
                   The last dimension denotes the shock variable. The row in each matrix
                   gives the responses of the \emph{ith} variable, ordered as in endog_data. The columns denote the horizons.
                   For example, if \emph{results_lin} contains the list with results, results_lin$irf_lin_mean[, , 1] returns a KXH matrix,
                   where K is the number of variables and H the number of horizons. '1' is the shock variable, corresponding to the
                  first variable in \emph{endog_data}.}

\item{irf_lin_low}{A three 3D \link{array} containing all lower confidence bands of the responses,
                   based on robust standard errors by Newey and West (1987). Properties are equal to irf_lin_mean.}

\item{irf_lin_up}{A three 3D \link{array} containing all upper confidence bands of the responses,
                   based on robust standard errors by Newey and West (1987). Properties are equal to \emph{irf_lin_mean}.}

\item{specs}{A list with properties of \emph{endog_data} for the plot function. It also contains
            lagged data (y_lin and x_lin) used for the irf estimations.}
}
\description{
Compute linear impulse responses with local projections by Jordà (2005).
}
\examples{
\donttest{

          ## Example without exogenous variables

# Load package
  library(lpirfs)

# Load (endogenous) data
  endog_data <- interest_rules_var_data

# Estimate linear model
  results_lin <- lp_lin(endog_data,
                             lags_endog_lin = 4,
                             exog_data      = NULL,
                             lags_exog      = NULL,
                             lags_criterion = NaN,
                             max_lags       = NaN,
                             trend          = 0,
                             shock_type     = 1,
                             confint        = 1.96,
                             hor            = 12,
                             contemp_data   = NULL,
                             num_cores      = NULL)

# Make plots
 linear_plots <- plot_lin(results_lin)

# Show single plots
 # * The first element of 'linear_plots' shows the response of the first
 #   variable (GDP_gap) to a shock in the first variable (GDP_gap).
 # * The second element of 'linear_plots' shows the response of the first
 #   variable (GDP_gap) to a shock in the second variable (inflation).
 # * ...

  linear_plots[[1]]
  linear_plots[[2]]

# Show all plots by using 'ggpubr' and 'gridExtra'
# lpirfs does not depend on those packages so they have to be installed
 library(ggpubr)
 library(gridExtra)

# Compare with Figure 5 in Jordà (2005)
 lin_plots_all <- sapply(linear_plots, ggplotGrob)
 marrangeGrob(lin_plots_all, nrow = ncol(endog_data), ncol = ncol(endog_data), top = NULL)


                      ## Example with exogenous variables ##

# Load (endogenous) data
 endog_data <- interest_rules_var_data

# Create exogenous data and data with contemporaneous impact (for illustration purposes only)
 exog_data    <- endog_data$GDP_gap*endog_data$Infl*endog_data$FF + rnorm(dim(endog_data)[1])
 contemp_data <- endog_data$GDP_gap*endog_data$Infl*endog_data$FF + rnorm(dim(endog_data)[1])

# Exogenous data has to be a data.frame
 exog_data    <- data.frame(xx = exog_data )
 contemp_data <- data.frame(cc =  contemp_data)

# Estimate linear model
  results_lin <- lp_lin(endog_data,
                               lags_endog_lin = 4,
                               lags_criterion = NaN,
                               max_lags       = NaN,
                               trend          = 0,
                               shock_type     = 1,
                               confint        = 1.96,
                               hor            = 12,
                               exog_data      = exog_data,
                               lags_exog      = 4,
                               contemp_data   = contemp_data,
                               num_cores      = NULL)

# Make plots
 linear_plots <- plot_lin(results_lin)

# Show all plots
 library(ggpubr)
 library(gridExtra)

 lin_plots_all <- sapply(linear_plots, ggplotGrob)
 marrangeGrob(lin_plots_all, nrow = ncol(endog_data), ncol = ncol(endog_data), top = NULL)


 }
}
\references{
Akaike, H. (1974). "A new look at the statistical model identification", \emph{IEEE Transactions on Automatic Control}, 19 (6): 716–723.

Hurvich, C. M., and Tsai, C.-L. (1989), "Regression and time series model selection in small samples",
\emph{Biometrika}, 76(2): 297–307

Jordà, Ò. (2005). "Estimation and Inference of Impulse Responses by Local Projections."
\emph{American Economic Review}, 95 (1): 161-182.

Newey, W.K., and West, K.D. (1987). “A Simple, Positive-Definite, Heteroskedasticity and
Autocorrelation Consistent Covariance Matrix.” \emph{Econometrica}, 55: 703–708.

Schwarz, Gideon E. (1978). "Estimating the dimension of a model", \emph{Annals of Statistics}, 6 (2): 461–464.
}
\seealso{
\url{https://adaemmerp.github.io/lpirfs/README_docs.html}
}
\author{
Philipp Adämmer
}
