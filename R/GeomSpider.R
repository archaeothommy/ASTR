#' Spidergram geom for ggplot2
#'
#' @param mapping Aesthetic mappings (optional)
#' @param data Data frame in wide format containing element concentrations
#' @param elements Character vector of elements or a predefined group ("REE", "HFSE", "LILE")
#' @param reference Normalisation reference: "chondrite" or "MORB"
#' @param sample_id Column name for grouping samples (optional)
#' @param na.rm Logical: remove NA values
#' @param show.legend Logical: show legend
#' @param inherit.aes Logical: inherit aesthetics from ggplot call
#' @param ... Additional arguments passed to ggplot2::layer
#'
#' @export
geom_spider <- function(data,
                        elements,
                        reference = "chondrite",
                        sample_id = NULL,
                        na.rm = FALSE,
                        show.legend = NA,
                        inherit.aes = FALSE,
                        ...) {

  # Check required arguments
  if (missing(data) || is.null(data)) {
    cli::cli_abort("You must supply a data frame to geom_spider(data = ...).")
  }
  if (missing(elements) || is.null(elements)) {
    cli::cli_abort("You must supply `elements` to geom_spider().")
  }

  ggplot2::layer(
    geom = GeomSpider,
    mapping = ggplot2::aes(),   # empty mapping keeps raw columns
    data = data,
    stat = "identity",
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      elements = elements,
      reference = reference,
      sample_id = sample_id,
      na.rm = na.rm,
      ...
    )
  )
}
