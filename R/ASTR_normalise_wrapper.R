#' Data normalisation
#'
#' Wrapper function for data normalisation. Dispatches to the appropriate
#' normalisation function based on the value of `type`.
#'
#' The following normalisations are currently supported:
#' * **Geochemical reference compositions** (`type = "geochem"`) — normalises
#' chemical concentrations against a reference composition such as chondrite or
#' MORB. See [normalise_geochem] for details.
#' * **Element normalisation** (`type = "element"`) — normalises all numeric
#' columns against a single element in the data. See [normalise_element] for
#' details.
#' * **Sample normalisation** (`type = "sample"`) — normalises all numeric
#' columns against a single sample or data point in the dataset. See
#' [normalise_sample] for details.
#' * **Normalisation to 100%** (`type = "hundred"`) — rescales all numeric
#' columns so that their row sums equal 100. See [normalise_100] for details.
#'
#' @param df A data frame in wide format.
#' @param type Character string specifying the type of normalisation. See
#'   details for available normalisations.
#' @param reference Character string specifying the reference used for
#'   normalisation. Must be one of the following:
#'   * `type = "geochem"`: A geochemical reference composition name; See
#'   [references_geochem] for available options.
#'   * `type = "element"`: A column name in `df` against which all other
#'   columns with numeric values should be normalised to.
#'   * `type = "sample"`: The ID of a sample/data point in `df` against which
#'   all other rows should be normalised to.
#' @param id_column String with the column name of the sample IDs in `df`. Only
#'   used when normalising against a sample. Default is `"ID"`.
#' @param ... Additional arguments passed to the underlying normalisation
#'   function.
#'
#' @return The normalised data frame.
#'
#' @family data normalisation functions
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID = c("A", "B", "C"),
#'   La = c(10, 5, 8),
#'   Ce = c(20, 8, 15),
#'   Nd = c(15, 6, 12)
#' )
#'
#' # Geochemical reference normalisation
#' normalise_data(df, reference = "chondrite")
#'
#' # Element normalisation
#' normalise_data(df, reference = "La")
#'
#' # Sample normalisation
#' normalise_data(df, reference = "A", id_column = "ID")
#'
#' # Normalisation to 100%
#' normalise_data(df, reference = "100%")
#'
normalise_data <- function(
  df,
  type = c("hundred", "geochem", "element", "sample"),
  reference = NULL,
  id_column = "ID",
  ...
) {

  type <- match.arg(type)

  checkmate::assert_data_frame(df)
  checkmate::assert_string(reference, null.ok = TRUE)

  switch(type,
    geochem = normalise_geochem(df, reference = reference),
    hundred = normalise_100(df),
    element = normalise_element(df, reference = reference),
    sample = normalise_sample(df, reference = reference, id_column = id_column),
    stop(
      "Unknown reference '", reference, "'. ",
      "`reference` must be one of: ",
      "a geochemical reference composition (see `references_geochem`), ",
      "a column name in `df`, ",
      "an ID value in `df`, ",
      "or '100%'."
    )
  )
}
