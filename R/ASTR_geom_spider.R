#' Spidergram geom for ggplot2
#'
#' This geom creates spidergrams, line graphs of element concentrations. The
#' geom supports data normalisation, which is commonly done before plotting.
#'
#' This geom is special because no x and y coordinates are provided in the
#' input. Instead, the aesthetic `elements` must be provided in [ggplot2::aes()]
#' and it must be provided in the call to this geom, and not in
#' [ggplot2::ggplot()] (see Examples).
#'
#' The elements can be supplied either as user-defined character vector or
#' pre-made sets. See [standard_groups] for a list of available sets and the
#' examples below for how to include them. The examples below also show how to
#' avoid the default sorting into alphabetical order. The geom will throw an
#' error if any of the supplied elements is not matched by a column name in the
#' supplied data.
#'
#' @inheritParams ggplot2::layer
#' @param reference Character string with what the data should be normalised to;
#'   see [normalise_data] fur further details. If `NULL`, the default, data will
#'   not be normalised.
#' @param ... Other arguments passed on to [ggplot2::layer()]. These are often
#'   aesthetics used to set a fixed value, such as `colour = "red"` or `alpha =
#'   0.5`.
#'
#' @section Aesthetics: ### update as needed `geom_spidergram()` understands the
#'   following aesthetic values (required aesthetics are in bold):
#' * **`elements`** (character vector with the list of elements to be plotted)
#' * ...
#'
#'   Learn more about setting these aesthetics in `vignette("ggplot2-specs")`.
#'
#' @export
#'
#' @examples
#' # include example with data[[standard_groups$REE]]
#' # include example demonstrating that aes(elements = c()) must be called in the geom and not ggplot()
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
geom_spider <- function(mapping = NULL, data = NULL, stat = "identity",
                        position = "identity", na.rm = FALSE, reference = NULL,
                        show.legend = NA, inherit.aes = TRUE,
                        ...) {

  # extract elements from aesthetic `elements`
  elements <- as.character(rlang::get_expr(mapping$elements))[-1]

  if (length(elements) <= 1) {
    stop("At least two elements must be provided to draw a spidergram.")
  }

  # re-mapping elements to single columns
  for (i in elements) {
    mapping[[i]] <- rlang::set_expr(mapping$elements, str2lang(i))
  }

  mapping$elements <- NA # avoid error of not finding required aesthetic

  ggplot2::layer(
    geom = GeomSpider,
    data = data,
    mapping = mapping,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      reference = reference,
      elements = elements,
      na.rm = na.rm, ...
    )
  )
}

GeomSpider <- ggplot2::ggproto(
  "GeomSpider",
  ggplot2::Geom,

  required_aes = c("elements"),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = ggplot2::draw_key_path,

  extra_params = c("na.rm", "reference"),

  setup_data = function(data, params) {

    # data normalisation goes here #########################################

    data_long <- tidyr::pivot_longer(data, params$elements, names_to = "x", values_to = "y")

    data_long
  },

  draw_group = function(data, panel_params, coord) {

    coords <- coord$transform(data, panel_params)



    if (nrow(data) < 2) return(grid::nullGrob())

    data <- data[order(data$x), ]

    # Fast path — no NAs
    if (!any(is.na(data$y))) {
      coords <- coord$transform(data, panel_params)
      return(
        grid::polylineGrob(
          coords$x, coords$y,
          gp = grid::gpar(
            col   = coords$colour[1],
            lwd   = coords$linewidth[1] * ggplot2::.pt,
            lty   = coords$linetype[1],
            alpha = coords$alpha[1]
          )
        )
      )
    }

    # NA handling — breaks in line at missing elements
    not_na  <- !is.na(data$y)
    run_ids <- cumsum(c(TRUE, diff(not_na) != 0))

    grobs <- lapply(unique(run_ids[not_na]), function(run) {
      segment <- data[not_na & run_ids == run, , drop = FALSE]
      if (nrow(segment) < 2) return(NULL)

      coords <- coord$transform(segment, panel_params)
      grid::polylineGrob(
        coords$x, coords$y,
        gp = grid::gpar(
          col   = coords$colour[1],
          lwd   = coords$linewidth[1] * ggplot2::.pt,
          lty   = coords$linetype[1],
          alpha = coords$alpha[1]
        )
      )
    })

    grobs <- Filter(Negate(is.null), grobs)
    if (length(grobs) == 0) return(grid::nullGrob())
    do.call(grid::grobTree, grobs)
   }
)

# previous data treatment
# data = function(x) {
#   d <- if (!is.null(.data)) .data else x
#
#   if (!is.null(.reference)) {
#     d <- normalise_geochem(d, reference = .reference)
#   }
#
#   elements_present <- intersect(.elements, colnames(d))
#   if (length(elements_present) == 0) {
#     stop("None of the requested elements are present as columns in the data.")
#   }
#   if (length(elements_present) < length(.elements)) {
#     warning("Some requested elements are absent and will be skipped: ",
#             paste(setdiff(.elements, elements_present), collapse = ", "))
#   }
#
#   meta_cols <- setdiff(colnames(d), elements_present)
#
#   data_long <- do.call(rbind, lapply(elements_present, function(el) {
#     row          <- d[meta_cols]
#     row$elements <- el
#     row$y        <- d[[el]]
#     row
#   }))
#
#   data_long$elements <- factor(data_long$elements, levels = elements_present)
#   data_long$x        <- as.numeric(data_long$elements)
#
#   data_long
# }
