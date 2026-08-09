#' Normalise data against a geochemical reference composition
#'
#' Normalises elemental concentrations in a data frame against a geochemical
#' reference composition such as chondrite or MORB. See [references_geochem]
#' for available reference compositions.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the name of the reference
#'   composition. See [references_geochem] for available options.
#' @param ... Additional arguments passed to [normalise_geochem].
#'
#' @return The input data frame with normalised values.
#'
#' @family Data normalisation
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID = c("A", "B"),
#'   La = c(10, 5),
#'   Ce = c(20, 8)
#' )
#' normalise_geochem_reference(df, reference = "chondrite")
#'
normalise_geochem_reference <- function(df, reference, ...) {
  checkmate::assert_data_frame(df)
  checkmate::assert_choice(reference, names(references_geochem))
  normalise_geochem(df, reference = reference, ...)
}
