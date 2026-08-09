#' Normalise data to 100%
#'
#' Rescales all numeric columns in a data frame so that the row sums equal 100.
#' This is commonly used in compositional data analysis to express
#' concentrations as relative proportions.
#'
#' @param df A data frame in wide format.
#'
#' @return The input data frame with numeric columns rescaled so that each
#'   row sums to 100.
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
#' normalise_to_100(df)
#'
normalise_to_100 <- function(df) {
  checkmate::assert_data_frame(df)
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  df[numeric_cols] <- normalise_rows(df[numeric_cols])
  df
}
