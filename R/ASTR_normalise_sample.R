#' Normalise data against a sample
#'
#' Normalises all numeric columns in a data frame by dividing by the values
#' of a reference sample identified by its ID.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the ID value of the sample to
#'   normalise against. Must match exactly one row in the ID column.
#' @param id_column String with the column name of the sample IDs in `df`.
#'   Default is `"ID"`.
#'
#' @return The input data frame with normalised values.
#'
#' @family Data normalisation
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID = c("A", "B", "C"),
#'   La = c(10, 5, 8),
#'   Ce = c(20, 8, 15),
#'   Nd = c(15, 6, 12)
#' )
#' normalise_sample(df, reference = "A", id_column = "ID")
#'
normalise_sample <- function(df, reference, id_column = "ID") {
  checkmate::assert_data_frame(df)
  checkmate::assert_string(reference)
  checkmate::assert_choice(id_column, colnames(df))
  if (!reference %in% df[[id_column]]) {
    stop("ID '", reference, "' not found in column '", id_column, "'.")
  }
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  ref_row <- df[df[[id_column]] == reference, numeric_cols, drop = FALSE]
  if (nrow(ref_row) > 1) {
    stop("More than one row matches ID '", reference, "'. IDs must be unique.")
  }
  df[numeric_cols] <- sweep(df[numeric_cols], 2, as.numeric(ref_row), "/")
  df
}
