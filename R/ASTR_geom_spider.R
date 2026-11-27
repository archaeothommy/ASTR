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
#' pre-made sets. See [standard_groups] for a list of available sets.
#' The geom will throw an error if any of the supplied elements is not matched by
#' a column name in the supplied data.
#'
#' @inheritParams ggplot2::layer
#' @param reference Character string with what the data should be normalised to;
#'   see [normalise_data] fur further details. If `NULL`, the default, data will
#'   not be normalised.
#' @param na.rm Logical; whether to remove missing values (NAs) from `y` before
#'   drawing. If `FALSE` (the default), missing values are removed with a
#'   warning; if `TRUE`, they are silently removed.
#' @param ... Other arguments passed on to [ggplot2::layer()]. These are often
#'   aesthetics used to set a fixed value, such as `colour = "red"` or `alpha =
#'   0.5`.
#'
#' @section Aesthetics: `geom_spidergram()` understands the
#'   following aesthetic values (required aesthetics are in bold):
#' * **`elements`** (character vector with the list of elements to be plotted)
#' * `colour`
#' * `linewidth`
#' * `linetype`
#' * `alpha`
#'
#'   Learn more about setting these aesthetics in `vignette("ggplot2-specs")`.
#'
#' @export
#' @importFrom tidyr pivot_longer
#'
#' @examples
#' library(ggplot2)
#'
#' test <- data.frame(
#'   Sample = c("A", "B"),
#'   La = c(10, 5),
#'   Ce = c(20, 8),
#'   Nd = c(15, 6)
#' )
#'
#' # elements must be supplied in the geom, not in ggplot()
#' ggplot(test) +
#'   geom_spider(aes(elements = c("La", "Ce", "Nd"), colour = Sample))
#'
#' # with chondrite normalisation
#' ggplot(test) +
#'   geom_spider(aes(elements = c("La", "Ce", "Nd"), colour = Sample),
#'     reference = "chondrite"
#'   )
#'
geom_spider <- function(mapping = NULL, data = NULL, stat = "identity",
                        position = "identity", na.rm = FALSE, reference = NULL,
                        show.legend = NA, inherit.aes = TRUE,
                        ...) {

  # rename aesthetic x to elements
  if (!is.null(mapping$x)) {
    names(mapping)[names(mapping) == "x"] <- "elements"
  }

  # extract elements from aesthetic `elements`
  elements <- rlang::eval_tidy(mapping$elements)

  if (length(elements) <= 1) {
    stop("At least two elements must be provided to draw a spidergram.")
  }

  # Re-map the internal aesthetics to the long-format columns created below.
  # `x` is a factor again, so we also provide an explicit per-sample `group`
  # to prevent ggplot from inferring one group per element (which would leave
  # no consecutive points to connect)
  mapping[["x"]]     <- rlang::set_expr(mapping$elements, str2lang("x"))
  mapping[["y"]]     <- rlang::set_expr(mapping$elements, str2lang("y"))
  mapping[["group"]] <- rlang::set_expr(mapping$elements, str2lang("spider_group"))
  mapping$elements   <- NULL # remove unnecessary aesthetic

  prepare_data <- function(plot_data) {

    # use the data supplied to the geom, or the plot data
    data <- if (is.null(data)) plot_data else data
    if (is.null(data)) {
      stop("No data supplied to geom_spider().", call. = FALSE)
    }

    # Check all requested elements are present as columns before normalisation
    missing_elements <- setdiff(elements, colnames(data))
    if (length(missing_elements) > 0) {
      stop(
        "The following elements are not present as columns in the data: ",
        paste(missing_elements, collapse = ", ")
      )
    }

    # Normalise data if reference is provided
    # normalise_geochem renames columns to element_reference (e.g. La_chondrite)
    cols <- elements

    if (!is.null(reference)) {
      data <- normalise_data(data, type = "geochem", reference = reference)
      cols <- paste0(cols, "_", reference)

      # verify normalised columns exist
      missing_norm <- setdiff(cols, colnames(data))
      if (length(missing_norm) > 0) {
        stop(
          "Normalised columns not found after normalisation: ",
          paste(missing_norm, collapse = ", "),
          ". This may indicate that the selected elements are not part of ",
          "the reference composition '", reference, "'."
        )
      }
    }

    # One polyline per row of the input data -> explicit group identity
    data$spider_group <- seq_len(nrow(data))

    # Pivot wide -> long using element columns
    data_long <- tidyr::pivot_longer(
      data,
      cols = tidyselect::all_of(cols),
      names_to = "x",
      values_to = "y"
    )

    # Strip the reference suffix from x labels so axis shows element names
    # e.g. La_chondrite -> La
    if (!is.null(reference)) {
      data_long$x <- sub(
        paste0("_", reference, "$"),
        "",
        data_long$x
      )
    }

    # Preserve declared element order on x axis
    data_long$x <- factor(data_long$x, levels = elements)

    data_long
  }

  list(
    ggplot2::layer(
      geom = GeomSpider,
      data = prepare_data,
      mapping = mapping,
      stat = stat,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = list(
        na.rm = na.rm, ...
      )
    ),
    ggplot2::scale_x_discrete()
  )
}

#' @rdname geom_spider
#' @format NULL
#' @usage NULL
#' @export
GeomSpider <- ggplot2::ggproto(
  "GeomSpider",

  ggplot2::Geom,

  required_aes = character(0),

  # x and y are mapped internally by geom_spider(); declare them so layer()
  # does not flag them as unknown aesthetics. They are deliberately not
  # required_aes, so handle_na() leaves any NA handling to draw_group().
  aesthetics = function(self) {
    c(ggproto_parent(ggplot2::Geom, self)$aesthetics(), "x", "y")
  },

  default_aes = ggplot2::aes(
    colour = "black",
    linewidth = 0.5,
    linetype = 1,
    alpha = NA
  ),
  draw_key = ggplot2::draw_key_path,

  extra_params = c("na.rm"),

  draw_group = function(data, panel_params, coord) {
    if (nrow(data) < 2) {
      return(grid::nullGrob())
    }

    # Replace NA alpha with 1
    data$alpha[is.na(data$alpha)] <- 1

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
    not_na <- !is.na(data$y)
    run_ids <- cumsum(c(TRUE, diff(not_na) != 0))

    grobs <- lapply(unique(run_ids[not_na]), function(run) {
      segment <- data[not_na & run_ids == run, , drop = FALSE]
      if (nrow(segment) < 2) {
        return(NULL)
      }

      coords <- coord$transform(segment, panel_params)
      grid::polylineGrob(
        coords$x, coords$y,
        gp = grid::gpar(
          col = coords$colour[1],
          lwd = coords$linewidth[1] * ggplot2::.pt,
          lty = coords$linetype[1],
          alpha = coords$alpha[1]
        )
      )
    })

    grobs <- Filter(Negate(is.null), grobs)
    if (length(grobs) == 0) {
      return(grid::nullGrob())
    }
    do.call(grid::grobTree, grobs)
  }
)
