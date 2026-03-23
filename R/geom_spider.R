#' Spidergram geom for ggplot2
#'
#' Descriptions goes here ###################
#' #### This will likely only work with ASTR objects or similarly wide data frame!?
#' #### Or is there a way to identify short vs. long form!?
#' #### e.g. single value to x and col content = character: long format, x = character vector length > 1 and column content of x = numeric: wide format
#' #### y = single value and numeric: long format, concentration, y is not provided: wide format
#' #### long format values do not need to be transformed (but normalised!?), wide format must be transformed to long format
#'
#' Normalisation is done with [normalise_geochem()]. If data are geochemically
#' normalised, only normalised elements are plotted. Otherwise, all elements
#' are plotted.
#'
#' @inheritParams ggplot2::layer
#' @param reference `NULL`, the default, if data should not be normalised or
#'   name of the geochemical reference composition to which data should be
#'   normalised. See [references_geochem] for a list of names.
#' @param na.rm Logical: remove NA values
#' @param ... Other arguments passed on to [ggplot2::layer()]. These are often
#'   aesthetics used to set a fixed value, such as `colour = "red"` or `alpha =
#'   0.5`.
#'
#' @export
#'
#' @examples
#' # include example with data[[standard_groups$REE]]
#'
#' library(ggplot2)
#'
#' test <- data.frame(
#'   Sample = c("A","B"),
#'   Yb = c(8,9),
#'   La = c(10,5),
#'   Ce = c(20,8)
#' )
#'
#' ggplot(test) + geom_spider(mapping = aes(x = standard_groups$REE, color = Sample))
#'
geom_spider <- function(mapping = NULL,
                        data = NULL,
                        inherit.aes = TRUE,
                        reference = NULL,
                        na.rm = FALSE,
                        show.legend = NA,
                        ...) {

  # Check required arguments
  ggplot2::layer(
    geom = GeomSpider,
    mapping = mapping,   # empty mapping keeps raw columns
    data = data,
    stat = "identity",
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      reference = reference,
      na.rm = na.rm,
      ...
    )
  )
}

GeomSpider <- ggplot2::ggproto(
  "GeomSpider",
  ggplot2::Geom,

  required_aes = character(0), # one grouping aes (group, colour, ...)

  default_aes = ggplot2::aes(
    colour = "black",
    linewidth = 0.6,
    linetype = 1,
    alpha = NA
  ),

  extra_params = c("na.rm", "reference"),

  draw_key = ggplot2::draw_key_path,

  setup_data = function(data, params) {

    # Normalisation
    if (!is.null(params$reference)) {
      data <- normalise_geochem(data, reference = params$reference)
    }


    # Pivot wide -> long
    data_long <- tidyr::pivot_longer(
      norm_data,
      cols = dplyr::all_of(elements),
      names_to = "element",
      values_to = "value"
    )

    # Maintain order of elements
    data_long$element <- factor(data_long$element, levels = elements)

    # Numeric x
    data_long$x <- as.numeric(data_long$element)
    data_long$y <- data_long$value

    # Grouping
    if (!is.null(params$sample_id) && params$sample_id %in% names(data_long)) {
      data_long$group <- data_long[[params$sample_id]]
    } else {
      data_long$group <- seq_len(nrow(norm_data))
    }

    data_long
  },

  draw_group = function(data, panel_params, coord) {
    # Handle missing values by breaking lines
    if (any(is.na(data$y))) {
      not_na <- !is.na(data$y)
      rle_not_na <- rle(not_na)
      ends <- cumsum(rle_not_na$lengths)
      starts <- c(1, ends[-length(ends)] + 1)
      grobs <- list()

      for (i in seq_along(rle_not_na$lengths)) {
        if (rle_not_na$values[i]) {
          idx <- starts[i]:ends[i]
          segment <- data[idx, , drop = FALSE]
          if (nrow(segment) >= 2) {
            coords <- coord$transform(segment, panel_params)
            grobs[[length(grobs) + 1]] <- grid::polylineGrob(
              coords$x, coords$y,
              gp = grid::gpar(
                col = coords$colour[1],
                lwd = coords$linewidth[1] * .pt,
                lty = coords$linetype[1],
                alpha = coords$alpha[1]
              )
            )
          }
        }
      }

      if (length(grobs) == 0) {
        return(grid::nullGrob())
      }
      return(do.call(grid::grobTree, grobs))
    }

    # No missing values
    if (nrow(data) < 2) {
      return(grid::nullGrob())
    }

    coords <- coord$transform(data, panel_params)
    grid::polylineGrob(
      coords$x, coords$y, id = coords$group,
      gp = grid::gpar(
        col = coords$colour,
        lwd = coords$linewidth * .pt,
        lty = coords$linetype,
        alpha = coords$alpha
      )
    )
  }
)
