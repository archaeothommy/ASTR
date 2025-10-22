#' Calculate lead isotope age models
#'
#' The functions calculate the age model and their respective mu and kappa
#' values according to the publications they are named after (see
#' *References*). [LI_model_age()] provides a wrapper for them and allows
#' to calculate all age models simultaneously.
#'
#' The implemented age models are:
#' * Stacey & Kramers (1975): [Stacey_Kramers_1975()]
#' * Cumming & Richards (1975): [Cumming_Richards_1975()]
#' * Albarède & Juteau (1984): [Albarede_Juteau_1984()]
#'
#' The used model is indicated in the column names of the output by the initials
#' of the author's last names and the publication year (e. g.`SK75` for Stacey
#' & Kramers 1975).
#'
#' See the references for the respective publications of the age models. The
#' function for the age model of Albarède & Juteau (1984) is based on the
#' MATLAB-script of F. Albarède (version 2020-11-06).
#'
#' The ratio of 208Pb/204Pb is not necessary for \link{Cumming_Richards_1975}.
#' The function takes it as argument only to be consistent with the input of the
#' other age model functions. If provided, it will be ignored.
#'
#' The age model published in Albarède et al. (2012) should not be used
#' according to F. Albarède and is therefore not implemented. Instead, use the
#' age model published in Albarède & Juteau (1984).
#'
#' @param data The data object from which the age model should be calculated.
#' @param ratio_206_204 Name of the column with the 206Pb/204Pb ratio as
#' character string. Default is `206Pb/204Pb`.
#' @param ratio_207_204 Name of the column with the 207Pb/204Pb ratio as
#' character string. Default is `207Pb/204Pb`.
#' @param ratio_208_204 Name of the column with the 208Pb/204Pb ratio as
#' character string. Default is `208Pb/204Pb`.
#' @param model Character string with the abbreviation of the model to
#'   calculate:
#'   * `SK75` for Stacey and Kramers 1975
#'   * `CR75` for Cumming and Richards 1975
#'   * `AJ84` for Albarède and Juteau 1984
#'   * `all` for all models at once
#'
#' @return A data frame with the model age, mu, and kappa value(s) for the
#' respective age models. The used model is indicated in the column names of
#' the output by the abbreviations given above.
#'
#' @export
#'
#' @references Albarède, F. and Juteau, M. (1984) Unscrambling the lead model
#' ages. Geochimica et Cosmochimica Acta 48(1), pp. 207–212.
#' <https://dx.doi.org/10.1016/0016-7037(84)90364-8>.
#'
#' Albarède, F., Desaulty, A.-M. and Blichert-Toft, J. (2012) A geological
#' perspective on the use of Pb isotopes in Archaeometry. Archaeometry 54, pp.
#' 853–867. <https://doi.org/10.1111/j.1475-4754.2011.00653.x>.
#'
#' Cumming, G.L. and Richards, J.R. (1975) Ore lead isotope ratios in a
#' continuously changing earth. Earth and Planetary Science Letters 28(2), pp.
#' 155–171. <https://dx.doi.org/10.1016/0012-821X(75)90223-X>.
#'
#' Stacey, J.S. and Kramers, J.D. (1975) Approximation of terrestrial lead
#' isotope evolution by a two-stage model. Earth and Planetary Science Letters
#' 26(2), pp. 207–221. <https://dx.doi.org/10.1016/0012-821X(75)90088-6<.
#'
#' @name age_models
#' @aliases Stacey_Kramers_1975
#' @aliases Cumming_Richards_1975
#' @aliases Albarede_et_al_2012
#'
#' @examples
#' # example code
#'

LI_model_age <- function(data, ratio_206_204 = "206Pb/204Pb", ratio_207_204 = "207Pb/204Pb", ratio_208_204 = "208Pb/204Pb", model = c("SK75", "CR75", "AJ84", "all"))
{
  switch (model,
          SK75 = Stacey_Kramers_1975(data, ratio_206_204, ratio_207_204, ratio_208_204),
          CR75 = Cumming_Richards_1975(data, ratio_206_204, ratio_207_204),
          AJ84 = Albarede_Juteau_1984(data, ratio_206_204, ratio_207_204, ratio_208_204),
          all = cbind(Stacey_Kramers_1975(data, ratio_206_204, ratio_207_204, ratio_208_204),
                      Cumming_Richards_1975(data, ratio_206_204, ratio_207_204),
                      Albarede_Juteau_1984(data, ratio_206_204, ratio_207_204, ratio_208_204)
                      ),
                      stop("This model is not supported.")
          )

}


#' @rdname age_models
#' @export

Stacey_Kramers_1975 <- function(data, ratio_206_204 = "206Pb/204Pb", ratio_207_204 = "207Pb/204Pb", ratio_208_204 = "208Pb/204Pb")
{

  # Defining constants

  t0 <- 3.7 * 10^9 # start of second stage in years
  a0 <- 11.152 # 206Pb/204Pb at start of second stage
  b0 <- 12.998 # 207Pb/204Pb at start of second stage
  c0 <- 31.23 # 208Pb/204Pb at start of second stage
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9  # decay constant 235U
  l232 <- 0.049475 * 10^-9 # decay constant 232Th

  # Defining model age function

  Model_age_func <- function(x,y) {
    stats::uniroot(function(X, a, b) {
      ((exp(l235*t0)-exp(l235*X))/(137.88*(exp(l238*t0)-exp(l238*X))))-((b0-b)/(a0-a))
    },
    a = x, b = y,
    interval = c(-10000*10^6, t0),
    extendInt ="yes", f.lower=-1*10^-2, f.upper = 1*10^-2, tol=10^-12)$root
  }

  # Calculation and clean-up

  Model_Age <- mapply(Model_age_func, data[[ratio_206_204]], data[[ratio_207_204]])
  Model_Age <- replace(Model_Age, Model_Age <= -10000*10^6 + 1*10^6 | Model_Age >= t0- 1*10^6, NA)

  mu <- (data[[ratio_206_204]] - a0)/(exp(l238*t0)-exp(l238*Model_Age))
  kappa <- (data[[ratio_208_204]] - c0)/(mu*(exp(l232*t0)-exp(l232*Model_Age)))

  result <- data.frame("Model_Age_SK75" = Model_Age * 10^-6, "mu_SK75" = mu, "kappa_SK75" = kappa)
  result <- round(result, 3)

  result
}


#' @rdname age_models
#' @export
#'

Cumming_Richards_1975 <- function(data, ratio_206_204 = "206Pb/204Pb", ratio_207_204 = "207Pb/204Pb", ratio_208_204 = NULL)
  # ratio 208Pb/204Pb not needed, just for consistency with other functions
{

  # Defining constants

  a0 = 9.307 # 206Pb/204Pb of the CDT
  b0 = 10.294 # 207Pb/204Pb of the CDT
  c0 = 29.476 # 208Pb/204Pb of the CDT
  t0 = 4509 * 10^6 # age of the CDT
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9  # decay constant 235U
  l232 <- 0.049475 * 10^-9 # decay constant 232Th
  Vp <- 0.07797 # present day 235U/204Pb
  Wp <- 41.25 # present day 232Th/204Pb
  e1 <- 0.05 * 10^-9 # epsilon parameter (growth rate mu)
  e2 <- 0.037 * 10^-9 # epsilon apostrophe parameter (growth rate kappa)

  # Defining model age function

  Model_age_func <- function(x,y) {
    stats::optimize(function(X, a, b) {
      (a0 - a + 137.88*Vp*((exp(l238*t0)*(1 - e1*(t0 - 1/l238)))-(exp(l238*X)*(1 - e1*(X - 1/l238)))))^2 + (b0 - b + Vp*((exp(l235*t0)*(1 - e1*(t0 - 1/l235)))-(exp(l235*X)*(1 - e1*(X - 1/l235)))))^2
    },
    a = x, b = y,
    interval = c(-10000*10^6,t0),
    tol=10^-12)$minimum
  }

  # Calculation and clean-up

  Model_Age <- mapply(Model_age_func, data[[ratio_206_204]], data[[ratio_207_204]])

  Model_Age <- replace(Model_Age, Model_Age <= -10000*10^6 + 1*10^6 | Model_Age >= t0- 1*10^6, NA)

  mu <- 137.88*Vp*(1-e1*Model_Age)
  kappa <- Wp*(1-e2*Model_Age)/mu

  result <- data.frame("Model_Age_CR75" = Model_Age * 10^-6, "mu_CR75" = mu, "kappa_CR75" = kappa)
  result <- round(result, 3)

  result
}

#' @rdname age_models
#' @export
#'

Albarede_Juteau_1984 <- function(data, ratio_206_204 = "206Pb/204Pb", ratio_207_204 = "207Pb/204Pb", ratio_208_204 = "208Pb/204Pb")
{
  # Defining constants

  xstar <- 18.750 # 206Pb/204Pb of modern common Pb
  ystar <- 15.63 # 207Pb/204Pb of modern common Pb
  zstar <- 38.86 # 208Pb/204Pb of modern common Pb
  T0 <- 3.8 * 10^9 # age of the Earth
  mustar <- 9.66 # mu of modern common Pb
  kappastar <- 3.90 # kappa of modern common Pb
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9  # decay constant 235U
  l232 <- 0.049475 * 10^-9 # decay constant 232Th
  U238235 <- 137.79

  xstar0 <- xstar - mustar * (exp(l238 * T0) - 1)
  ystar0 <- ystar - mustar / U238235 * (exp(l235 * T0) - 1)
  zstar0 <- zstar - mustar * kappastar * (exp(l232 * T0) - 1)

  # Defining model age function

  Model_age_func <- function(x,y) {
    if (!is.na(x) && !is.na(y)) {
      rootSolve::multiroot(
        function(x, parms) {
          c(
            F1 = xstar0+x[2]*(exp(l238*T0)-exp(l238*x[1]))-parms[1],
            F2 = ystar0+x[2]*(exp(l235*T0)-exp(l235*x[1]))/U238235-parms[2]
          )
        },
        start = c("Tmod" = 10*10^6, "mu" = 8),
        parms = c(x, y), ctol = 10^-12)$root
    } else {
      c(NA, NA)
    }
  }

  # Calculation and clean-up

  roots <- mapply(Model_age_func, data[[ratio_206_204]], data[[ratio_207_204]])

  kappa <- (data[[ratio_208_204]] - zstar0)/(exp(l232*T0)-exp(l232*roots[1,]))/roots[2,]

  result <- data.frame("Model_Age_AJ84" = roots[1,] * 10^-6, "mu_AJ84" = roots[2,], "kappa_AJ84" = kappa)
  result <- round(result, 3)

  result

}
