
# Stats -------------------------------------------------------------------

#' @import ggplot2
#' @importFrom dplyr bind_rows filter mutate select
#' @importFrom rlang .data
StatStaceyKramers <- ggplot2::ggproto(
  "StatStaceyKramers",
  ggplot2::Stat,
  required_aes = c("x", "y"),

  compute_group = function(data,
                           scales,
                           Mu1 = 10,
                           Kappa = 4,
                           Ti = 3.70e9,
                           interval = 200e6,
                           system = "76",
                           show_geochron = TRUE,
                           show_isochrons = TRUE,
                           kappa_list = c(3.4, 3.6, 3.8, 4, 4.2, 4.4)) {
    # Constants
    ap <- 9.307
    bp <- 10.294
    cp <- 29.476
    a0 <- 11.152
    b0 <- 12.998
    c0 <- 31.230
    l238 <- 1.55125e-10
    l235 <- 9.8485e-10
    l232 <- 4.9475e-11
    u_ratio <- 137.88

    fA <- function(t) exp(l238 * Ti) - exp(l238 * t)
    fB <- function(t) exp(l235 * Ti) - exp(l235 * t)
    fC <- function(t) exp(l232 * Ti) - exp(l232 * t)

    # Y-Pin logic for steep lines
    y_lims <- scales$y$get_limits()
    y_target <- y_lims[1] + 0.85 * (y_lims[2] - y_lims[1])

    # --- 1. Growth Curve (Mu) ---
    growth <- data.frame()
    mu_label <- data.frame()

    if (system == "76") {
      t_seq <- seq(0, Ti, length.out = 100)
      gx <- a0 + (Mu1 * fA(t_seq))
      gy <- b0 + (Mu1 / u_ratio) * fB(t_seq)

      growth <- data.frame(
        x = gx, y = gy, label = NA, angle = 0,
        type = "growth", group = 1
      )
      mu_label <- data.frame(
        x = gx[1], y = gy[1], label = paste("Mu", Mu1),
        angle = 0, type = "label_mu", group = 2
      )
    }

    # --- 2. Isochrons (Time Lines) ---
    isochrons <- data.frame()
    if (show_isochrons) {
      time_intervals <- seq(0, Ti, by = interval)
      isochrons <- lapply(time_intervals, function(ti) {
        y_orig <- if (system == "76") b0 else c0
        slope <- if (system == "76") (1 / u_ratio) * (fB(ti) / fA(ti)) else Kappa * (fC(ti) / fA(ti))
        xl <- (y_target - y_orig) / slope + a0
        data.frame(
          x = c(a0, a0 + 50), y = c(y_orig, y_orig + slope * 50),
          label = c(NA, paste0("T", ti / 1e6)),
          x_lab = xl, y_lab = y_target,
          angle = atan(slope) * (180 / pi),
          type = "isochron", group = ti + 100
        )
      }) %>% dplyr::bind_rows()
    }

    # --- 3. Kappa Lines (86 System Only) ---
    kappa_data <- data.frame()
    if (system == "86") {
      x_lims <- scales$x$get_limits()
      x_mid <- mean(x_lims)
      kappa_data <- lapply(kappa_list, function(k) {
        slope_k <- k * (fC(0) / fA(0))
        intercept_k <- c0 - (slope_k * a0)
        y_mid <- (slope_k * x_mid) + intercept_k
        data.frame(
          x = c(x_lims[1] - 10, x_lims[2] + 10),
          y = c((slope_k * (x_lims[1] - 10)) + intercept_k, (slope_k * (x_lims[2] + 10)) + intercept_k),
          label = c(paste("K", k), NA),
          x_lab = x_mid, y_lab = y_mid,
          angle = atan(slope_k) * (180 / pi),
          type = "kappa_line", group = k * 1000
        )
      }) %>% dplyr::bind_rows()
    }

    # --- 4. Geochron ---
    geochron <- data.frame()
    if (show_geochron) {
      T_earth <- 4.57e9
      slope_geo <- if (system == "76") (1 / u_ratio) * (exp(l235 * T_earth) - 1) / (exp(l238 * T_earth) - 1)
      else Kappa * (exp(l232 * T_earth) - 1) / (exp(l238 * T_earth) - 1)
      yp <- if (system == "76") bp else cp
      xl_geo <- (y_target - yp) / slope_geo + ap
      geochron <- data.frame(
        x = c(ap, ap + 50), y = c(yp, yp + slope_geo * 50),
        label = c(NA, "Geochron"), x_lab = xl_geo, y_lab = y_target,
        angle = atan(slope_geo) * (180 / pi),
        type = "geochron", group = 999
      )
    }

    all_data <- dplyr::bind_rows(growth, mu_label, isochrons, geochron, kappa_data)

    # Use .data pronoun to avoid "no visible binding" notes
    label_rows <- all_data %>%
      dplyr::filter(!is.na(.data$label)) %>%
      dplyr::mutate(
        x = ifelse(!is.na(.data$x_lab), .data$x_lab, .data$x),
        y = ifelse(!is.na(.data$y_lab), .data$y_lab, .data$y)
      )

    line_rows <- all_data %>% dplyr::select(-.data$x_lab, -.data$y_lab)

    return(dplyr::bind_rows(line_rows, label_rows))
  }
)


# Geomes ------------------------------------------------------------------


#' Stacey-Kramers Lead Evolution Geom
#'
#'
#' @inheritParams ggplot2::geom_path
#' @param Mu1 Second-stage 238U/204Pb ratio (default 10).
#' @param Kappa Second-stage 232Th/238U ratio (default 4).
#' @param Ti Initial time of the second stage in years (default 3.7Ga).
#' @param interval Time interval for isochron labels in years (default 200Ma).
#' @param system Character "76" or "86" defining the isotope system.
#' @param show_geochron Logical; should the Geochron be plotted?
#' @param show_isochrons Logical; should time isochrons be plotted?
#' @param kappa_list Numeric vector of Kappa values to plot in "86" system.
#'
#' @export
geom_stacey_kramers <- function(mapping = NULL,
                                data = NULL,
                                system = "76",
                                Mu1 = 10,
                                Kappa = 4,
                                ...) {
  layer(
    stat = StatStaceyKramers,
    data = data,
    mapping = mapping,
    geom = "path",
    position = "identity",
    inherit.aes = TRUE, # Inherits x (206) and y (207 or 208)
    params = list(
      system = system,
      Mu1 = Mu1,
      Kappa = Kappa,
      ...
    )
  )
}

#' @rdname geom_stacey_kramers
#' @export
geom_sk_labels <- function(mapping = NULL,
                           data = NULL,
                           system = "76",
                           Mu1 = 10,
                           Kappa = 4,
                           ...) {
  layer(
    stat = StatStaceyKramers,
    data = data,
    # FIX: after_stat MUST be inside aes()
    mapping = ggplot2::aes(label = after_stat(label),
                           angle = after_stat(angle)),
    geom = "text",
    position = "identity",
    inherit.aes = TRUE, # FIX: Must be TRUE to find x/y coordinates
    params = list(
      system = system,
      Mu1 = Mu1,
      Kappa = Kappa,
      na.rm = TRUE,
      hjust = -0.2,
      vjust = -0.5,
      size = 3,
      ...
    )
  )
}
