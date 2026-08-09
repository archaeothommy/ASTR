#' Normalise data against a single element
#'
#' Normalises all numeric columns in a data frame by dividing by the values
#' of a reference element column.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the column name of the element to
#'   normalise against. Must be a numeric column in `df`.
#'
#' @return The input data frame with normalised values. The reference element
#'   column is not divided by itself.
#'
#' @family Data normalisation
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID = c("A", "B"),
#'   La = c(10, 5),
#'   Ce = c(20, 8),
#'   Nd = c(15, 6)
#' )
#' normalise_element(df, reference = "La")
#'
normalise_element <- function(df, reference) {
  checkmate::assert_data_frame(df)
  checkmate::assert_choice(reference, colnames(df))
  if (!is.numeric(df[[reference]])) {
    stop("Column '", reference, "' is not numeric and cannot be used for normalisation.")
  }
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  numeric_cols <- setdiff(numeric_cols, reference)
  divisor <- df[[reference]]
  df[numeric_cols] <- lapply(df[numeric_cols], function(x) x / divisor)
  df
}
