#' Replace negative values with a uniform value
#'
#' This function generates a function for the argument `bdl_strategy` in [ASTR]
#' that replaces negative values in specified columns with a uniform value,
#' usually `NA` or `0`.
#'
#' @param cols The names of the columns to be checked according to the ASTR
#'   conventions.
#' @param value The replacement value. Default is to `NA_real_`.
#'
#' @returns A function
#' @export
#'
bdl_strategy_negative <- function(cols, value = NA_real_) {

  function(x = x, colname = cols) {
    x[, cols][x[, cols] < 0]  <- value
  }

}
