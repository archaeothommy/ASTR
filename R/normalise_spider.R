#' Normalise spidergram data
#'
#' Normalises selected elemental concentrations to a reference
#' composition such as chondrite or MORB.
#'
#' @param df A data frame in wide format.
#' @param elements Character vector of element names to normalise.
#' @param reference Character. One of "chondrite" or "MORB".
#'
#' @return A data frame with selected elements normalised.
#'
#' @details
#' Reference compositions are from Sun and McDonough 1989
#' (Geological Society, London, Special Publications 42, 313 to 345).
#' MORB values correspond to N MORB.
#' All reference values are in ppm.
#'
#'#' @examples
#' df <- data.frame(
#'   Sample = c("A", "B"),
#'   La = c(10, 5),
#'   Ce = c(20, 8)
#' )
#'
#' normalise_spider(
#'   df,
#'   elements = c("La", "Ce"),
#'   reference = "chondrite"
#' )
#'
#' @export
normalise_spider <- function(df,
                             elements,
                             reference = c("chondrite", "MORB")) {

  reference <- match.arg(reference)

  # Basic checks

  if (!is.data.frame(df)) {
    stop("`df` must be a data frame.")
  }

  if (missing(elements) || length(elements) == 0) {
    stop("`elements` must be provided.")
  }

  if (!is.character(elements)) {
    stop("`elements` must be a character vector.")
  }

  # Check elements exist in data

  missing_cols <- elements[!elements %in% names(df)]
  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "The following elements are not in `df`: ",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  # Get reference values

  ref_values <- spider_references[[reference]]

  if (is.null(ref_values)) {
    stop("Reference not found in internal spider_references.")
  }

  missing_ref <- elements[!elements %in% names(ref_values)]
  if (length(missing_ref) > 0) {
    stop(
      paste0(
        "Reference '", reference,
        "' does not contain values for: ",
        paste(missing_ref, collapse = ", ")
      )
    )
  }

  # Normalisation

  out <- df

  for (el in elements) {

    if (!is.numeric(out[[el]])) {
      stop(paste0("Column '", el, "' must be numeric."))
    }

    out[[el]] <- out[[el]] / ref_values[[el]]
  }

  return(out)
}
