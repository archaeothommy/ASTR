#' Calculate lead isotope age models
#'
#' The functions calculate the age model and their respective mu and kappa
#' values according to the publications they are named after (see
#' *References*). [pb_iso_age_model()] provides a wrapper for them and allows
#' to calculate all age models simultaneously.
#'
#' The implemented age models are:
#' * Stacey & Kramers (1975): [stacey_kramers_1975()]
#' * Cumming & Richards (1975): [cumming_richards_1975()]
#' * Albarède & Juteau (1984): [albarede_juteau_1984()]
#'
#' The used model is indicated in the column names of the output by the initials
#' of the author's last names and the publication year (e. g.`SK75` for Stacey
#' & Kramers 1975).
#'
#' See the references for the respective publications of the age models. The
#' function for the age model of Albarède & Juteau (1984) is based on the
#' MATLAB-script of F. Albarède (version 2020-11-06). The age model published
#' in Albarède et al. (2012) should not be used according to F. Albarède and is
#' therefore not implemented. Instead, he recommends to use the age model
#' published in Albarède & Juteau (1984).
#'
#' The ratio of 208Pb/204Pb is not necessary for [cumming_richards_1975].
#' The function takes it as argument only to be consistent with the input of the
#' other age model functions. If provided, it will be ignored.
#'
#' @param df The data frame from which the age model should be calculated.
#' @param ratio_206_204 Name of the column with the 206Pb/204Pb ratio as
#' character string. Default is `206Pb/204Pb`.
#' @param ratio_207_204 Name of the column with the 207Pb/204Pb ratio as
#' character string. Default is `207Pb/204Pb`.
#' @param ratio_208_204 Name of the column with the 208Pb/204Pb ratio as
#' character string. Default is `208Pb/204Pb`.
#' @param model Character string with the abbreviation of the model to
#'   calculate:
#'   * `SK75` for Stacey & Kramers (1975)
#'   * `CR75` for Cumming & Richards (1975)
#'   * `AJ84` for Albarède & Juteau (1984)
#'   * `all` for all models at once
#'
#' @return The data frame provided as input with columns added for the model
#' age, mu, and kappa value(s) of the respective age models. The used model is
#' indicated in the column names of the output by the abbreviations given above.
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
#' @aliases stacey_kramers_1975
#' @aliases cumming_richards_1975
#' @aliases albarede_juteau_1984
#'
#' @examples
#' # creating example data
#' df <- tibble::tibble(
#'   `206Pb/204Pb` = runif(5, min = 18, max = 18.5),
#'   `207Pb/204Pb` = runif(5, min = 15, max = 15.5),
#'   `208Pb/204Pb` = runif(5, min = 2, max = 2.2)
#' )
#'
#' # calculate values for all age models
#' pb_iso_age_model(df, model = "all")
#'
#' # calculate values for a specific age model
#' pb_iso_age_model(df, model = "SK75")
#' stacey_kramers_1975(df)
#'

pb_iso_age_model <- function(df,
                             ratio_206_204 = "206Pb/204Pb",
                             ratio_207_204 = "207Pb/204Pb",
                             ratio_208_204 = "208Pb/204Pb",
                             model = c("SK75", "CR75", "AJ84", "all")) {

  checkmate::assert_character(model)

  switch(model,
    SK75 = stacey_kramers_1975(df, ratio_206_204, ratio_207_204, ratio_208_204),
    CR75 = cumming_richards_1975(df, ratio_206_204, ratio_207_204),
    AJ84 = albarede_juteau_1984(df, ratio_206_204, ratio_207_204, ratio_208_204),
    all = cbind(
      df,
      stacey_kramers_1975(
        df,
        ratio_206_204,
        ratio_207_204,
        ratio_208_204
      )[c("model_age_SK75", "mu_SK75", "kappa_SK75")],
      cumming_richards_1975(
        df,
        ratio_206_204,
        ratio_207_204
      )[c("model_age_CR75", "mu_CR75", "kappa_CR75")],
      albarede_juteau_1984(
        df,
        ratio_206_204,
        ratio_207_204,
        ratio_208_204
      )[c("model_age_AJ84", "mu_AJ84", "kappa_AJ84")]
    ),
    stop("This model is not supported.")
  )
}


#' @rdname age_models
#' @export

stacey_kramers_1975 <- function(df,
                                ratio_206_204 = "206Pb/204Pb",
                                ratio_207_204 = "207Pb/204Pb",
                                ratio_208_204 = "208Pb/204Pb") {
  # Defining constants

  t0 <- 3.7 * 10^9 # start of second stage in years
  a0 <- 11.152 # 206Pb/204Pb at start of second stage
  b0 <- 12.998 # 207Pb/204Pb at start of second stage
  c0 <- 31.23 # 208Pb/204Pb at start of second stage
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9 # decay constant 235U
  l232 <- 0.049475 * 10^-9 # decay constant 232Th

  # Defining model age function

  model_age_func <- function(x, y) {
    stats::uniroot(
      function(s, a, b) {
        ((exp(l235 * t0) - exp(l235 * s)) / (137.88 * (exp(l238 * t0) - exp(l238 * s)))) - ((b0 - b) / (a0 - a))
      },
      a = x, b = y,
      interval = c(-10000 * 10^6, t0),
      extendInt = "yes", f.lower = -1 * 10^-2, f.upper = 1 * 10^-2, tol = 10^-12
    )$root
  }

  # Calculation and clean-up

  model_age <- mapply(model_age_func, df[[ratio_206_204]], df[[ratio_207_204]])
  model_age <- replace(model_age, model_age <= -10001 * 10^6 | model_age >= t0 - 1 * 10^6, NA)

  mu <- (df[[ratio_206_204]] - a0) / (exp(l238 * t0) - exp(l238 * model_age))
  kappa <- (df[[ratio_208_204]] - c0) / (mu * (exp(l232 * t0) - exp(l232 * model_age)))

  result <- data.frame("model_age_SK75" = model_age * 10^-6, "mu_SK75" = mu, "kappa_SK75" = kappa) |>
    round(3)

  result <- cbind(df, result)

  result
}


#' @rdname age_models
#' @export

cumming_richards_1975 <- function(df,
                                  ratio_206_204 = "206Pb/204Pb",
                                  ratio_207_204 = "207Pb/204Pb",
                                  ratio_208_204 = NULL) {
  # ratio 208Pb/204Pb not needed, just for consistency with other functions

  # Defining constants

  a0 <- 9.307 # 206Pb/204Pb of the CDT
  b0 <- 10.294 # 207Pb/204Pb of the CDT
  t0 <- 4509 * 10^6 # age of the CDT
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9 # decay constant 235U
  vp <- 0.07797 # present day 235U/204Pb
  wp <- 41.25 # present day 232Th/204Pb
  e1 <- 0.05 * 10^-9 # epsilon parameter (growth rate mu)
  e2 <- 0.037 * 10^-9 # epsilon apostrophe parameter (growth rate kappa)

  # Defining model age function

  model_age_func <- function(x, y) {
    stats::optimize(
      function(s, a, b) {
        (a0 - a + 137.88 * vp *
           ((exp(l238 * t0) * (1 - e1 * (t0 - 1 / l238))) -
              (exp(l238 * s) * (1 - e1 * (s - 1 / l238)))))^2 +
          (b0 - b + vp * ((exp(l235 * t0) * (1 - e1 * (t0 - 1 / l235))) -
                            (exp(l235 * s) * (1 - e1 * (s - 1 / l235)))))^2
      },
      a = x, b = y,
      interval = c(-10000 * 10^6, t0),
      tol = 10^-12
    )$minimum
  }

  # Calculation and clean-up

  model_age <- mapply(model_age_func, df[[ratio_206_204]], df[[ratio_207_204]])

  model_age <- replace(model_age, model_age <= -10001 * 10^6 | model_age >= t0 - 1 * 10^6, NA)

  mu <- 137.88 * vp * (1 - e1 * model_age)
  kappa <- wp * (1 - e2 * model_age) / mu

  result <- data.frame("model_age_CR75" = model_age * 10^-6, "mu_CR75" = mu, "kappa_CR75" = kappa) |>
    round(3)

  result <- cbind(df, result)

  result
}

#' @rdname age_models
#' @export

albarede_juteau_1984 <- function(df,
                                 ratio_206_204 = "206Pb/204Pb",
                                 ratio_207_204 = "207Pb/204Pb",
                                 ratio_208_204 = "208Pb/204Pb") {
  # Defining constants

  xstar <- 18.750 # 206Pb/204Pb of modern common Pb
  ystar <- 15.63 # 207Pb/204Pb of modern common Pb
  zstar <- 38.86 # 208Pb/204Pb of modern common Pb
  t0 <- 3.8 * 10^9 # age of the Earth
  mustar <- 9.66 # mu of modern common Pb
  kappastar <- 3.90 # kappa of modern common Pb
  l238 <- 0.155125 * 10^-9 # decay constant 238U
  l235 <- 0.98485 * 10^-9 # decay constant 235U
  l232 <- 0.049475 * 10^-9 # decay constant 232Th
  u238235 <- 137.79

  xstar0 <- xstar - mustar * (exp(l238 * t0) - 1)
  ystar0 <- ystar - mustar / u238235 * (exp(l235 * t0) - 1)
  zstar0 <- zstar - mustar * kappastar * (exp(l232 * t0) - 1)

  # Defining model age function

  model_age_func <- function(x, y) {
    if (!is.na(x) && !is.na(y)) {
      rootSolve::multiroot(
        function(x, parms) {
          c(
            F1 = xstar0 + x[2] * (exp(l238 * t0) - exp(l238 * x[1])) - parms[1],
            F2 = ystar0 + x[2] * (exp(l235 * t0) - exp(l235 * x[1])) / u238235 - parms[2]
          )
        },
        start = c("Tmod" = 10 * 10^6, "mu" = 8),
        parms = c(x, y), ctol = 10^-12
      )$root
    } else {
      c(NA, NA)
    }
  }

  # Calculation and clean-up

  roots <- mapply(model_age_func, df[[ratio_206_204]], df[[ratio_207_204]])

  kappa <- (df[[ratio_208_204]] - zstar0) / (exp(l232 * t0) - exp(l232 * roots[1, ])) / roots[2, ]

  result <- data.frame("model_age_AJ84" = roots[1, ] * 10^-6, "mu_AJ84" = roots[2, ], "kappa_AJ84" = kappa) |>
    round(3)

  result <- cbind(df, result)

  result
}
