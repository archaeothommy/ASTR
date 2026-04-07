#' Geochemical normalisation of data
#'
#' Normalises selected elemental concentrations to a reference composition such
#' as chondrite or MORB.
#'
#' See [references_geochem] for supported geochemical reference compositions and
#' which elements are covered by which reference composition. The function
#' converts all elements in the dataframe for which a reference composition is
#' available. A warning informs if not all elements in the reference composition
#' are included in the data frame, and an error if none is included.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the normalisation. See Details for
#'   further information.
#'
#' @return The data frame with the selected elements normalised.
#'
#' @references Sun, S.-s. & McDonough, W.F. (1989). Chemical and isotopic
#'   systematics of oceanic basalts. Geological Society, London, Special
#'   Publications 42, 313-345. Table 1, page 318.
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
normalise_geochem <- function(df, reference = names(references_geochem)) {

  reference <- match.arg(reference)

  # Basic checks
  checkmate::assert_data_frame(df)

  elements <- intersect(colnames(df), names(references_geochem[[reference]]))

  if (length(elements) < length(references_geochem[[reference]])) {
    if (length(elements) == 0) {
      stop("Dataset does not include any element of the reference data.")
    } else {
      warning("Dataset does not include all elements of the reference data.")
    }
  }

  print(references_geochem[[reference]][elements])
  # Normalisation
  df[elements] <- t(t(df[elements]) / references_geochem[[reference]][elements])

  return(df)
}
