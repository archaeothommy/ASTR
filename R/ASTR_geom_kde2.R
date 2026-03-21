#' Draw 2D Kernel Density Estimate Polygons by Quantiles
#'
#' @description
#' This geom creates polygons based on a 2D kernel density estimate, which is
#' calculated using the [ks::kde()] function. It serves as an
#' alternative to [ggplot2::geom_density_2d()], displaying the results
#' as filled polygons corresponding to specified quantiles.
#'
#' If the density estimation fails for a group (e.g., due to too few unique
#' points), the geom will gracefully fall back to plotting the raw data points
#' for that group, inheriting aesthetics from [ggplot2::geom_point()].
#'
#' @inheritParams ggplot2::layer
#' @param quantiles Integer. The number of quantiles to display. For example,
#'   `quantiles = 4` (the default) will draw quartiles.
#' @param min_prob A numeric value in `[0, 1]`. Sets the lowest probability
#'   quantile to be drawn. The default, `0.02`, helps avoid creating
#'   polygons around single outlier points.
#' @param fallback_to_points Logical. To prevent points from being drawn for
#'   groups that fail density estimation, set this to FALSE. For example, if you
#'   want more control over the point aesthetics, independent of the KDE regions,
#'   set this to FALSE and use geom_point to plot those points
#' @param ... Other arguments passed on to [ggplot2::layer()]. These are
#'   often aesthetics used to set a fixed value, such as `colour = "red"` or
#'   `alpha = 0.5`.
#'
#' @section Aesthetics:
#' `geom_kde2d()` understands the following aesthetics (required aesthetics are in bold):
#' * **`x`**
#' * **`y`**
#' * `group`
#' * `alpha`
#' * `colour` (controls the polygon outline)
#' * `fill` (controls the polygon fill)
#' * `linetype`
#' * `linewidth` (controls the outline thickness)
#' * `size` (controls the point size)
#' * `shape` (used for the fallback points)
#'
#' Learn more about setting these aesthetics in `vignette("ggplot2-specs")`.
#'
#' @return A ggplot2 layer object.
#'
#' @seealso
#' [ggplot2::geom_density_2d()], [ggplot2::geom_point()], [ks::kde()]
#'
#' @export
#' @importFrom ggplot2 layer ggproto GeomPolygon GeomPoint aes draw_key_polygon
#' @importFrom ks kde contourLevels
#' @importFrom grDevices contourLines
#'
#' @examples
#' library(ggplot2)
#'
#' # Basic usage with iris data
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d()
#'
#' # Adjusting quantiles to show deciles
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 10, alpha = 0.5)
#'
#' # Using min_prob to show only density regions above the median
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 10, min_prob = 0.5)
#'
#' # Creating an outline effect
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
#'   geom_kde2d(quantiles = 1, min_prob = 0, fill = NA)
#'
#' # Creating an outline effect, and using coord_cartesian to expand the
#' # plot area so the full KDE regions show without clipping
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
#'   geom_kde2d(quantiles = 1, min_prob = 0, fill = NA) +
#'   coord_cartesian(xlim = c(4, 8.2), ylim = c(2, 4.5), clip = "off")
#'
#' # Example of fallback behavior
#' # Create a dataset where one group has too few points for density estimation
#' set.seed(123)
#' df <- data.frame(
#'   x = c(rnorm(50), rnorm(50, 5), rnorm(2, 10)),
#'   y = c(rnorm(50), rnorm(50, 5), rnorm(2, 10)),
#'   group = rep(c("A", "B", "C"), c(50, 50, 2))
#' )
#'
#' # A message will indicate that group "C" is plotted as points
#' ggplot(df, aes(x, y, fill = group, colour = group)) +
#'   geom_kde2d(alpha = 0.4) +
#'   theme_minimal()

geom_kde2d <- function(mapping = NULL,
                       data = NULL,
                       inherit.aes = TRUE,
                       quantiles = 4,
                       min_prob = 0.02,
                       show.legend = NA,
                       fallback_to_points = TRUE,
                       ...) {
  ggplot2::layer(
    geom = GeomKDE2d,
    mapping = mapping,
    data = data,
    stat = "identity",
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      quantiles = quantiles,
      min_prob = min_prob,
      fallback_to_points = fallback_to_points,
      ...
    )
  )
}

GeomKDE2d <- ggplot2::ggproto(
  "GeomKDE2d",
  ggplot2:::Geom,
  handle_na = function(self, data, params) {
    data
  },
  setup_data = function(self, data, params) {
    data <- ggproto_parent(Geom, self)$setup_data(data, params)
    data
  },
  draw_group = function(data,
                        panel_params,
                        coord,
                        quantiles = 10,
                        min_prob = 0.25,
                        na.rm = FALSE,
                        colour = NULL,
                        fill = NULL,
                        size = NULL,
                        linewidth = NULL,
                        alpha = NULL,
                        shape = NULL,
                        linetype = NULL,
                        fallback_to_points = TRUE) {
    probs <- seq(0, 1, 1 / quantiles)
    probs <- probs[probs >= min_prob]
    probs <- probs[-length(probs)]
    if (min(probs) != min_prob) {
      probs[length(probs) + 1] <- min_prob
    }

    data_kde <- data[c("x", "y")]
    data_kde <- data_kde[complete.cases(data_kde), ]

    common <- subset(data, select = -c(x, y))[1, ]

    plot_data <- tryCatch(
      {
        kde <- ks::kde(data_kde, compute.cont = FALSE)
        levels <- ks::contourLevels(kde, prob = probs)

        if (sum(levels) == 0) {
          stop("Levels values are zero",
            .call = FALSE
          )
        }

        contours <- grDevices::contourLines(
          x = kde$eval.points[[1]],
          y = kde$eval.points[[2]],
          z = kde$estimate,
          levels = levels
        )

        plot_data <- lapply(seq_along(contours), function(i) {
          data.frame(
            x = contours[[i]][["x"]],
            y = contours[[i]][["y"]],
            group = rep_len(i, length(contours[[i]][["x"]]))
          )
        })

        do.call("rbind", plot_data)
      },
      error = function(e) {
        # --- KDE failed and user has chosen not to plot points
        if (isFALSE(fallback_to_points)) {
          message(sprintf("Skipping group '%s': %s", data$group[1], conditionMessage(e)))
          return(data.frame()) # empty data = draw nothing for this group
        }

        # --- KDE failed: fallback to points ---
        message(
          "No density estimate possible for group '", data$group[1],
          "', plotting points instead: ", conditionMessage(e)
        )

        data$type <- "points" # Add a 'type' column to signal the fallback

        return(data)
      }
    )

    # Detect fallback (points)
    if (!is.null(plot_data$type) && unique(plot_data$type) == "points") {
      # prefer user-specified constants, then mapped, then defaults
      col_val <- colour %||% common$colour %||% common$fill %||% "black"
      fill_val <- fill %||% common$fill %||% common$colour %||% col_val
      size_val <- (size %||% common$size %||% 1.5) * 2
      alpha_val <- alpha %||% common$alpha %||% 1
      shape_val <- shape %||% common$shape %||% 21

      point_data <- data.frame(
        x = plot_data$x,
        y = plot_data$y,
        group = plot_data$group,
        PANEL = common$PANEL,
        colour = col_val,
        fill = fill_val,
        alpha = alpha_val,
        size = size_val,
        shape = shape_val,
        stroke = 0.5
      )

      GeomPoint$draw_panel(
        data = point_data,
        panel_params = panel_params,
        coord = coord
      )
    } else if (nrow(plot_data) > 0) { # Check if plot_data is not empty


      # Normal contour polygon

      suppressWarnings(
        data <- data.frame(
          x = plot_data$x,
          y = plot_data$y,
          group = plot_data$group,
          PANEL = common["PANEL"],
          colour = common["colour"],
          fill = common["fill"],
          linewidth = common["linewidth"],
          linetype = common["linetype"],
          alpha = common["alpha"]
        )
      )

      GeomPolygon$draw_panel(
        data = data,
        panel_params = panel_params,
        coord = coord
      )
    }
  },
  draw_key = ggplot2:::draw_key_polygon,
  required_aes = c("x", "y", "group"),
  default_aes = ggplot2::aes(
    colour = NA,
    fill = "grey25",
    size = 2,
    linetype = 1,
    linewidth = 1,
    alpha = 0.25
  ),
  extra_params = c(
    "na.rm", "quantiles", "min_prob", "fallback_to_points",
    "colour", "fill", "size", "alpha", "shape", "linetype", "linewidth"
  )
)
