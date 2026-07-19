#' Data normalisation
#'
#' Wrapper function for data normalisation. Dispatches to the appropriate
#' normalisation function based on the value of `reference`.
#'
#' The following normalisations are currently supported:
#'
#' * Geochemical reference compositions — normalises elemental
#'   concentrations against a reference composition such as chondrite or MORB.
#'   Dispatch is triggered when `reference` matches a name in
#'   [references_geochem]. See [normalise_geochem] for details and
#'   [references_geochem] for the list of available reference compositions.
#'
#' * Element normalisation — normalises all numeric columns against a
#'   single element in the data. Dispatch is triggered when `reference`
#'   matches a column name in `df`.
#'
#' * Sample normalisation — normalises all numeric columns against a
#'   single sample or data point in the dataset. Dispatch is triggered when
#'   `reference` matches a value in the ID column of `df`.
#'
#' * Normalisation to 100% — rescales all numeric columns so that their
#'   sum equals 100. Triggered when `reference = "100%"`.
#'
#' @param df A data frame in wide format.
#' @param reference Character string specifying the normalisation to apply.
#'   Must be one of the following:
#'   * A geochemical reference composition name — see [references_geochem]
#'     for available options (e.g. `"chondrite"`, `"MORB"`).
#'   * A column name in `df` — normalises all numeric columns against that
#'     element.
#'   * An ID value in `df` — normalises all numeric columns against that
#'     sample.
#'   * `"100%"` — rescales all numeric columns to sum to 100.
#' @param id_column String with the column name of the sample IDs in `df`.
#'   Only used when normalising against a sample. Default is `"ID"`.
#' @param ... Additional arguments passed to the underlying normalisation
#'   function.
#'
#' @return The normalised data frame. The exact output depends on the
#'   normalisation applied — see the respective function for details.
#'
#' @family Data normalisation
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID  = c("A", "B", "C"),
#'   La  = c(10,   5,   8),
#'   Ce  = c(20,   8,  15),
#'   Nd  = c(15,   6,  12)
#' )
#'
#' # Geochemical reference normalisation
#' normalise_data(df, reference = "chondrite")
#'
#' # Element normalisation — normalise against La
#' normalise_data(df, reference = "La")
#'
#' # Sample normalisation — normalise against sample "A"
#' normalise_data(df, reference = "A", id_column = "ID")
#'
#' # Normalisation to 100%
#' normalise_data(df, reference = "100%")
#'
normalise_data <- function(df, reference, id_column = "ID", ...) {

  checkmate::assert_data_frame(df)
  checkmate::assert_string(reference)

  # 1. Geochemical reference composition
  if (reference %in% names(references_geochem)) {
    return(normalise_geochem(df, reference = reference, ...))
  }

  # Identify numeric columns for element and sample normalisation
  numeric_cols <- names(df)[sapply(df, is.numeric)]

  # 2. Element normalisation — reference matches a column name in df
  if (reference %in% colnames(df)) {
    if (!reference %in% numeric_cols) {
      stop("Column '", reference, "' is not numeric and cannot be used for normalisation.")
    }
    divisor <- df[[reference]]
    df[numeric_cols] <- lapply(df[numeric_cols], function(x) x / divisor)
    return(df)
  }

  # 3. Sample normalisation — reference matches an ID value in df
  if (id_column %in% colnames(df) && reference %in% df[[id_column]]) {
    ref_row    <- df[df[[id_column]] == reference, numeric_cols, drop = FALSE]
    if (nrow(ref_row) > 1) {
      stop("More than one row matches ID '", reference, "'. IDs must be unique.")
    }
    divisor <- as.numeric(ref_row)
    df[numeric_cols] <- sweep(df[numeric_cols], 2, divisor, "/")
    return(df)
  }

  # 4. Normalisation to 100%
  if (reference == "100%") {
    row_sums <- rowSums(df[numeric_cols], na.rm = TRUE)
    df[numeric_cols] <- (df[numeric_cols] / row_sums) * 100
    return(df)
  }

  stop(
    "Unknown reference '", reference, "'. ",
    "`reference` must be one of: ",
    "a geochemical reference composition (see `references_geochem`), ",
    "a column name in `df`, ",
    "an ID value in `df`, ",
    "or '100%'."
  )
}
