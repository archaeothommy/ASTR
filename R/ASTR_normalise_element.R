#' Normalise data against a single element
#'
#' Normalises values in all numeric columns in a data frame by dividing them by the values
#' of a reference element column.All numeric columns are divided by the values of the reference
#' element, expressing each element as a ratio relative to the reference.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the column name of the element to
#'   normalise against. Must be a numeric column in `df`.The ratio between
#'   each numeric column and this element is calculated.
#'
#' @return The input data frame with normalised values. The reference element
#'   column is not divided by itself.
#'
#' @family data normalisation functions
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
normalise_element <- function(df, reference = colnames(df)) {

  reference <- match.arg(reference)

  checkmate::assert_data_frame(df)

  if (!is.numeric(df[[reference]])) {
    stop("Column '", reference, "' is not numeric and cannot be used for normalisation.")
  }

  numeric_cols <- names(df)[sapply(df, is.numeric)]
  numeric_cols <- setdiff(numeric_cols, reference)
  df[numeric_cols] <- lapply(df[numeric_cols], function(x) x / df[[reference]])
  df
}
