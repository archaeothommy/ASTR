#' Normalise spidergram data
#'
#' Normalises selected elemental concentrations to a reference
#' composition such as chondrite or MORB.
#'
#' @param df A data frame in wide format.
#' @param elements Character vector of element names.
#' @param reference Character. One of "chondrite" or "MORB".
#'
#' @return A data frame with selected elements normalised.
#'
#' @references
#' Sun, S.-s. & McDonough, W.F. (1989). Chemical and isotopic systematics
#'   of oceanic basalts. Geological Society, London, Special Publications 42,
#'   313-345. Table 1, page 318.
#'
#' @details
#' MORB values correspond to N MORB. All reference values are in ppm.
#'
#' @examples
#' df <- data.frame(
#'   Sample = c("A","B"),
#'   La = c(10,5),
#'   Ce = c(20,8)
#' )
#'
#' normalise_spider(
#'   df,
#'   elements = c("La","Ce"),
#'   reference = "chondrite"
#' )
#'
#' @export
normalise_spider <- function(df,
                             elements,
                             reference = c("chondrite", "MORB")) {

  reference <- match.arg(reference)

  # Basic checks
  checkmate::assert_data_frame(df)
  checkmate::assert_character(elements,
    min.len = 1,
    any.missing = FALSE
  )

  checkmate::assert_subset(
    elements,
    choices = names(df)
  )

  ref_values <- spider_references[[reference]]

  checkmate::assert_subset(
    elements,
    choices = names(ref_values)
  )

  checkmate::assert_numeric(
    unlist(df[elements]),
    any.missing = TRUE
  )

  # Normalisation
  out <- df
  for (el in elements) {
    out[[el]] <- out[[el]] / ref_values[[el]]
  }

  return(out)
}
