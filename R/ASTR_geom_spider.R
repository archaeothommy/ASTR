#' Spidergram geom for ggplot2
#'
#'Descriptions goes here ###################
#' #### This will likely only work with ASTR objects or similarly wide data frame!?
#' #### Or is there a way to identify short vs. long form!?
#' #### e.g. single value to x and col content = character: long format,
#' x = character vector length > 1 and column content of x = numeric: wide format
#' #### y = single value and numeric: long format, concentration, y is not provided: wide format
#' #### long format values do not need to be transformed (but normalised!?),
#' wide format must be transformed to long format
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
                        elements = NULL,
                        reference = NULL,
                        na.rm = FALSE,
                        show.legend = NA,
                        ...) {

  .data      <- data
  .elements  <- elements
  .reference <- reference

  mapping <- utils::modifyList(
    ggplot2::aes(x = .data$x, y = .data$y),
    if (!is.null(mapping)) mapping else ggplot2::aes()
  )

  list(
    suppressWarnings(
      ggplot2::layer(
        geom = GeomSpider,
        mapping = mapping,
        data = function(x) {
          d <- if (!is.null(.data)) .data else x

          if (!is.null(.reference)) {
            d <- normalise_geochem(d, reference = .reference)
          }

          elements_present <- intersect(.elements, colnames(d))
          if (length(elements_present) == 0) {
            stop("None of the requested elements are present as columns in the data.")
          }
          if (length(elements_present) < length(.elements)) {
            warning("Some requested elements are absent and will be skipped: ",
                    paste(setdiff(.elements, elements_present), collapse = ", "))
          }

          meta_cols <- setdiff(colnames(d), elements_present)

          data_long <- do.call(rbind, lapply(elements_present, function(el) {
            row          <- d[meta_cols]
            row$elements <- el
            row$y        <- d[[el]]
            row
          }))

          data_long$elements <- factor(data_long$elements, levels = elements_present)
          data_long$x        <- as.numeric(data_long$elements)

          data_long
        },
        stat = "identity",
        position = "identity",
        show.legend = show.legend,
        inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)
      )
    ),
    ggplot2::scale_x_continuous(
      breaks = seq_along(.elements),
      labels = .elements
    ),
    ggplot2::labs(x = NULL, y = "Concentration")
  )
}

GeomSpider <- ggplot2::ggproto(
  "GeomSpider",
  ggplot2::Geom,

  required_aes = character(0),

  default_aes = ggplot2::aes(
    colour    = "black",
    linewidth = 0.6,
    linetype  = 1,
    alpha     = NA
  ),

  extra_params = c("na.rm"),

  draw_key = ggplot2::draw_key_path,

  setup_data = function(data, params) {
    data
  },

  draw_group = function(data, panel_params, coord) {

    if (nrow(data) < 2) return(grid::nullGrob())

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
