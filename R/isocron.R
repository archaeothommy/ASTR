#' @title Isocrong Plot in Base R
#' @description
#' Draws a isocron plot for 206Pb/204Pb~207Pb/204Pb and
#' 206Pb/204Pb~208Pb/204Pb plots on Base R plot using PBIso package
#'
#' @param mu1 Mu value of the model curve; Default 10
#' @param time Vecotr of start, end periods of isocrons, and intervals in million years; Default c(0, 3700, 200)
#' @param color Vector of line and lable colors for highlights and regular lines; Default c('grey30', 'grey70')
#' @return
#'
#' @importFrom PbIso modelcurve isochron76yint isochron76slope
#' @importFrom graphics lines par abline text
#' lines and ablines for existing plot
#' @export
plot_isocron76 <- function(mu1 = 10,
                           time = c(0, 3700, 200),
                           color = c("grey30", "grey70")) {
  t <- seq(time[1], time[2])
  sk_model <- PbIso::modelcurve(t = t, Mu1 = mu1)
  dimensions <- graphics::par("usr")
  q1 <- dimensions[1] + 0.25 * (dimensions[2] - dimensions[1])
  diffs <- abs(sk_model$x - q1)
  closest_index <- which.min(diffs)
  closest_row <- sk_model[closest_index, ]
  graphics::text(
    closest_row$x,
    closest_row$y,
    label = "Mu 10",
    col = color[1],
    cex = 0.8,
    pos = 3,
    srt = 20
  )
  graphics::lines(sk_model$x, sk_model$y, col = color[1])
  time_intervals <- seq(time[1], time[2], by = time[3])
  q2 <- dimensions[3] + 0.80 * (dimensions[4] - dimensions[3])
  for (t in time_intervals) {
    intercept <- PbIso::isochron76yint(t, Mu1 = mu1)
    slope <- PbIso::isochron76slope(t, Mu1 = mu1)
    x1 <- (q2 - intercept) / slope
    graphics::abline(intercept, slope, col = color[2])
    graphics::text(
      x1,
      q2,
      label = paste("T", t),
      col = color[2],
      cex = 0.8,
      pos = 2,
      srt = slope
    )

  }
  t0_64 <- 9.307
  t0_74 <- 10.294
  s <- 0.626208
  # y = mx + c
  intercpet <- t0_74 - s * t0_64
  graphics::abline(intercpet, s, col = color[1])
  g1 <- (q2 - intercpet) / s
  graphics::text(
    g1,
    q2,
    label = "Geochron",
    col = color[1],
    cex = 0.8,
    pos = 2,
    srt = 75
  )
}

#' @rdname plot_isocron76
#' @param kap Kapa Value; Default 4
#' @importFrom stats lm coef
#' @importFrom graphics lines par abline text
#' @export
plot_isocron86 <- function(mu1 = 10,
                           kap = 4,
                           color = c("grey30", "grey70")) {
  two_stage <- iso_output(mu1 = mu1)
  ka <- unique(two_stage$kapa)
  for (k in ka) {
    df <- two_stage[two_stage$kapa == k, c(5, 7)]
    df <- df[order(df$X6.4), ]
    model <- stats::lm(formula = X8.4 ~ X6.4, data = df)
    slope <- stats::coef(model)[2]
    intercept <- stats::coef(model)[1]
    graphics::abline(intercept, slope, col = ifelse(k == kap, color[1], color[2]))
    if (k == kap) {
      dimensions <- graphics::par("usr")
      x1 <- dimensions[1] + 0.25 * (dimensions[2] - dimensions[1])
      y1 <- (slope * x1) + intercept
      graphics::text(
        x1,
        y1,
        labels = paste("K", kap),
        col = color[1],
        cex = 0.8,
        pos = 3,
        srt = 30,
        adj = c(0.5, 0.5)
      )
    }
  }
}

# Helper Function
iso_output <- \(mu1 = 10) {
  mu_list <- c(6, 9, 10, 12)
  k_list <- seq(3, 5, by = 0.2)
  time <- c(seq(0, 3.00E+09, 1.00E+09),
            3.60E+09,
            seq(2.00E+08, 8.00E+08, 2.00E+08))

  # Function List
  ## Set 1 Vatiables
  ti <- 3.70e+09 # Starting time of Second Stage
  lambda1 <- 1.55125E-10 # 238U (to 206Pb) decay constant
  lambda2 <- 9.8485E-10 # 235U (to 207Pb) decay constant
  lambda3 <- 4.95E-11 # 232Th (to 208Pb) decay constant
  ## Set 1 Fucntions
  function_a <- \(t) {
    exp(lambda1 * ti) - exp(lambda1 * t)
  }
  function_b <- \(t) {
    exp(lambda2 * ti) - exp(lambda2 * t)
  }
  function_c <- \(t) {
    exp(lambda3 * ti) - exp(lambda3 * t)
  }
  ## Set 2 Function
  omega_func <- \(kap, mu) {
    kap * mu
  }
  ## Set 3 Variables
  a0 <- 11.152 # 206 pb/204pb initial
  b0 <- 12.998 # 207 pb/204pb initial
  c0 <- 31.23 # 208 pb/204pb initial
  ## Set 3 Functions
  growth_curv64 <- \(t, mu) {
    a0 + (mu * function_a(t))
  }
  growth_curv74 <- \(t, mu) {
    b0 + (mu / 137.88) * function_b(t)
  }
  growth_curv84 <- \(t, kap, mu) {
    c0 + omega_func(kap, mu) * function_c(t)
  }

  ##### Output Stage 2 #####

  iso_output <- data.frame(
    Time = numeric(),
    mu = numeric(),
    kapa = numeric(),
    omega = numeric(),
    `X6/4` = numeric(),
    `X7/4` = numeric(),
    `X8/4` = numeric()
  )

  for (t in range(time)) {
    for (m in mu_list) {
      for (k in k_list) {
        iso_output <- rbind(
          iso_output,
          data.frame(
            Time = t,
            mu = m,
            kapa = k,
            omega = omega_func(k, m),
            `X6/4` = growth_curv64(t, m),
            `X7/4` = growth_curv74(t, m),
            `X8/4` = growth_curv84(t, k, m)
          )
        )
      }
    }
  }

  output <- iso_output[iso_output$mu == mu1, ]
  return(output)
}
