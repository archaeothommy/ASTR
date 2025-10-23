#' Draw density plot based on quantiles
#'
#' @author Thomas Rose, \email{thomas.rose@daad-alumni.de}
#'
#' This geom offers an alternative geom to
#' \code{\link[ggplot2]{geom_density_2d}}. The 2D kernel density estimate is
#' calculated using \code{\link[ks]{kde}} and display the results as polygons of
#' the given quantiles.
#'
#' @inheritParams ggplot2::layer()
#' @param quantiles Number of quantiles to be displayed. The default are
#'   quartiles, i.e. \code{quantiles = 4}.
#' @param min_prob The smallest quantile to be displayed given in the range
#'   \code{[0,1]}. The default \code{min_prob = 0.02} is a good estimate for
#'   outlines without polygons around single points.
#' @param ... Other arguments passed on to \code{\link[ggplot2]{layer}}. These
#'   are often aesthetics, used to set an aesthetic to a fixed value.
#'
#' @section Aesthetics: \code{geom_kde2d()} understands the following aesthetics
#'   (required aesthetics are in bold): \itemize{ \item \strong{\code{x}} \item
#'   \strong{\code{y}} \item \strong\code{group}} \item \code{color} \item \code{fill}
#'   \item \code{alpha} \item \code{size} \item \code{linetype} }. Learn more
#'   about setting these aesthetics in \code{vignette("ggplot2-specs")}.
#'
#' @export
#'
#' @examples
#'
#' library(ggplot2)
#'
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, group = Species)) +
#' geom_kde2d()
#'
#' # Use quantiles to adjust the outlines of the density estimates:
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 2) # median
#'
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 10) # deciles
#'
#' # Use min_prob parameter to set the lowest quantile
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 10, min_prob = 0.5) # deciles above the median
#'
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
#'   geom_kde2d(quantiles = 5, min_prob = 0.3) # 30% quantile and quintiles 40% and above
#'
#' # To create a kind of outline
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
#'   geom_kde2d(quantiles = 1, min_prob = 0)
#'
#' # Density estimates are slightly different from geom_density_2d
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
#'   geom_kde2d(aes(fill = Species)) +
#'   geom_density_2d(aes(colour = Species)) +
#'   geom_point()


geom_kde2d <- function(mapping = NULL,
                       data = NULL,
                       inherit.aes = TRUE,
                       quantiles = 4,
                       min_prob = 0.02,
                       show.legend = NA,
                       ...) {
  ggplot2::layer(
    geom = GeomKDE2d,
    mapping = mapping,
    data = data,
    stat = "identity",
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(quantiles = quantiles, min_prob = min_prob, ...)
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
                        quantiles,
                        min_prob) {
    probs <- seq(0, 1, 1 / quantiles)
    probs <- probs[probs >= min_prob]
    probs <- probs[-length(probs)]
    if (min(probs) != min_prob) {
      probs[length(probs) + 1] <- min_prob
    }

    data_kde <- data[c("x", "y")]
    data_kde <- data_kde[complete.cases(data_kde), ]

    common <- subset(data, select = -c(x, y))[1, ]

    plot_data <- tryCatch({
      kde <- ks::kde(data_kde, compute.cont = FALSE)

      levels <- ks::contourLevels(kde, prob = probs)
      contours <- grDevices::contourLines(
        x = kde$eval.points[[1]],
        y = kde$eval.points[[2]],
        z = kde$estimate,
        levels = levels
      )

      plot_data <- lapply(seq_along(contours), function(i)
        data.frame(
          x = contours[[i]][["x"]],
          y = contours[[i]][["y"]],
          group = rep_len(i, length(contours[[i]][["x"]]))
        ))

      do.call("rbind", plot_data)
    }, error = function(e) {
      # --- KDE failed: fallback to points ---
      message("No density estimate possible for group '", data$group[1],
              "' — plotting points instead.")
      data.frame(x = data_kde$x,
                 y = data_kde$y,
                 group = 1,
                 type = "points")

    })

    # Detect fallback (points)
    if (!is.null(plot_data$type) && unique(plot_data$type) == "points") {

       # prefer user-specified constants, then mapped, then defaults
      col_val  <- colour  %||% common$colour %||% common$fill %||% "black"
      fill_val <- fill    %||% common$fill   %||% common$colour %||% col_val
      size_val <- (size   %||% common$size   %||% 1.5) * 2
      alpha_val<- alpha   %||% common$alpha  %||% 1
      shape_val<- shape   %||% common$shape  %||% 21

      point_data <- data.frame(
        x = plot_data$x,
        y = plot_data$y,
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
    } else {
      # Normal contour polygon

    suppressWarnings(
      data <- data.frame(
        x = plot_data$x,
        y = plot_data$y,
        group = plot_data$group,
        PANEL = common["PANEL"],
        colour = common["colour"],
        fill = common["fill"],
        size = common["size"],
        linetype = common["linetype"],
        alpha = common["alpha"]
      )
    )

    GeomPolygon$draw_panel(data = data,
                           panel_params = panel_params,
                           coord = coord)
    }
  },

  draw_key = ggplot2:::draw_key_polygon,

  required_aes = c("x", "y", "group"),

  default_aes = aes(
    colour = NA,
    fill = "grey25",
    size = 0.5,
    linetype = 1,
    alpha = 0.25
  )
)
