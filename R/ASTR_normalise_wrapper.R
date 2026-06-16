#' family

# Wrapper for data normalisation functions

# it should do:
# * dispatch to correct normalisation function based on input
#   - element name leads to normalisation against this element
#   - geochemical reference name dispatches to normalise_geochem
#   - normalisation against a data point/sample in the dataset. Sample is identified by ID value
#   - normalisation to 100% should be included as well.
# * return the output of the respective function

# For documentation:
# * Provide sufficient information about the available normalisations and how to retrieve the options.
# * Users should not need to look up the respective functions themselves for this.


#' Data normaliation
#'
#' @param df
#' @param ...
#'
#' @returns
#'
#' @family Data normalisation
#' @export
#'
#' @examples
#'
normalise_data <- function(df, ...) {

}
