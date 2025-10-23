#' Isocrong Plot in Base R
#' @description
#' Draws a isocron plot for P206/204~Pb207/204 plots on Base R plot using PBIso package
#'
#' @param Mu1 Mu of the Isocron and date line; Degault 10
#' @param t0 Start time of the isocrons; Default 0
#' @param tend End time of the isocrons; Degault 3700
#' @param interval Intervals between the isocrong; Default 200 in isocron 76 and 1000 in isocron 86
#' @param t_color Color of the date line; Default 'grey'
#' @param iso_color Color of the isocrongs; Default 'lightgrey'
#'
#' @return
#' lines and ablines for existing plot
#' @export
#'
#' @examples
#' pb64 <- rnorm(100, 18.5, 0.1)
#' pb74 <- rnorm(100, 15.65, 0.05)
#' pb84 <- rnorm(100, 38.6, 0.2)
#' par(mfrow = c(2,1))
#' plot(pb64, pb74,
#'      xlab = NA,
#'      ylab = "Pb207/204",
#'      xaxt = "n")
#' isocron76()
#' plot(pb64, pb84,
#'      xlab = "Pb206/204",
#'      ylab = "Pb208/204")
#' isocron86(interval = 1000)
#' rm(pb64, pb74, pb84)
isocron76 <- function(Mu1 = 10,
                      t0 = 0,
                      tend = 3700,
                      interval = 200,
                      t_color = 'grey30',
                      iso_color = 'grey70') {
        t <- seq(t0, tend)
        sk_model <- PbIso::modelcurve(t = t, Mu1 = Mu1)
        dimensions <- par("usr")
        q1 <- dimensions[1] + 0.25 *(dimensions[2]-dimensions[1])
        diffs <- abs(sk_model$x - q1)
        closest_index <- which.min(diffs)
        closest_row <- sk_model[closest_index, ]
        text(closest_row$x, closest_row$y, label = "Mu 10",
             col = t_color, cex = 0.8, pos = 3, srt = 20)
        lines(sk_model$x, sk_model$y, col = t_color)
        time_intervals <- seq(t0, tend, by = interval)
        q2 <- dimensions[3] + 0.80 *(dimensions[4]-dimensions[3])
        for (t in time_intervals) {
                intercept <- PbIso::isochron76yint(t, Mu1 = Mu1)
                slope <- PbIso::isochron76slope(t, Mu1 = Mu1)
                x1 <- (q2-intercept)/slope
                abline(
                        intercept,
                        slope,
                        col = iso_color
                )
                text(x1, q2, label = paste("T", t),
                     col = iso_color, cex = 0.8, pos = 2,
                     srt = atan(slope) * (180))

        }
        t0_64 <- 9.307
        t0_74 <- 10.294
        S <- 0.626208
        # y = mx + c
        intercpet <- t0_74 - S*t0_64
        abline(intercpet, S, col = t_color)
        g1 <- (q2-intercpet)/S
        text(g1,q2, label = "Geochron",
             col = t_color, cex = 0.8, pos = 2,
             srt = 75)
}


isocron86 <- function(t_color = 'grey30', iso_color = 'grey70', ...){
        source("R/2stagemodle.R")
        two_stage <- iso_output(...)
        ka <- unique(two_stage$kapa)
        for (k in ka) {
                df <- two_stage[two_stage$kapa == k,c(5, 7)]
                df <- df[order(df$X6.4),]
                model <- lm(formula = X8.4 ~ X6.4, data = df)
                slope <- coef(model)[2]
                intercept <- coef(model)[1]
                abline(intercept, slope, col = ifelse(k == 4, t_color, iso_color))
                if(k == 4){
                        dimensions <- par("usr")
                        x1 <- dimensions[1] + 0.25 *(dimensions[2]-dimensions[1])
                        y1 <- (slope * x1) + intercept
                        text(x1, y1, labels = "K 4", col = t_color,
                             cex = 0.8, pos = 3,
                             srt = 30,
                             adj = c(0.5, 0.5))
                }
        }
}

