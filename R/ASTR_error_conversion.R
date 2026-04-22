#' Convert between relative and absolute errors
#'
#' Convert relative error columns (e.g., those ending with _errSD%) to absolute
#' errors, or vice versa. Relative errors are percentages. Absolute errors have
#' the same units as the measured values.
#'
#' @param df An ASTR object
#' @return An ASTR object with converted error columns.
#'
#' @examples
#' # For SiO2 = 31.6 wt% with relative error 4.3%:
#' # rel_to_abs: (4.3 / 100) * 31.6 = 1.36 wt%
#'
#' # For SiO2 = 31.6 wt% with absolute error 1.36 wt%:
#' # abs_to_rel: (1.36 / 31.6) * 100 = 4.3%
#'
#' @name error_conversion
NULL

#' @rdname error_conversion
#' @export
rel_to_abs <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- colnames(df)[sapply(colnames(df), is_err_percent)]

  if (length(error_cols) == 0) {
    warning("No error columns found. Returning unchanged.")
    return(df)
  }

  # Process all error columns
  for (err_col in error_cols) {
    base_name <- remove_suffix(err_col)

    if (base_name %in% names(df)) {
      # Absolute = relative * measured_value
      df[[err_col]] <- df[[err_col]] * df[[base_name]]

      # Set units to match the concentration column
      units(df[[err_col]]) <- units(df[[base_name]])
    }
  }
  return(df)
}

#' @rdname error_conversion
#' @export
abs_to_rel <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- colnames(df)[sapply(colnames(df), is_err_abs)]

  if (length(error_cols) == 0) {
    warning("No error columns found. Returning unchanged.")
    return(df)
  }

  # Process all error columns
  for (err_col in error_cols) {
    base_name <- remove_suffix(err_col)

    if (!base_name %in% names(df)) {
      next
    }
    # relative = (absolute / measured_value)
    df[[err_col]] <- df[[err_col]] / df[[base_name]]

    # Set units to percent
    units(df[[err_col]]) <- units::as_units("%")
  }

  return(df)
}
