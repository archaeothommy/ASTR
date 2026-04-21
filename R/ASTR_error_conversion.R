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
#' # rel_to_abs: absolute = (relative / 100) * value
#' # When SiO2 = 31.6 wt%, relative error = 4.3%
#' # absolute error = (4.3 / 100) * 31.6 = 1.36 wt%
#' arch_abs <- rel_to_abs(arch)
#'
#' # abs_to_rel: relative = (absolute / value) * 100
#' # When SiO2 = 31.6 wt%, absolute error = 1.36 wt%
#' # relative error = (1.36 / 31.6) * 100 = 4.3%
#' arch_rel <- abs_to_rel(arch)
#'
#' @name error_conversion
NULL

#' @rdname error_conversion
#' @export
rel_to_abs <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- get_error_columns(df)

  if (length(error_cols) == 0) {
    warning("No error columns found. Returning unchanged.")
    return(df)
  }

  # Process each error column
  for (err_col in names(error_cols)) {

    # Only process relative errors
    if (!is_err_percent(err_col)) {
      next
    }

    # Find matching concentration column
    base_name <- gsub("_err(2)?(SD|SE)(%)?$", "", err_col)

    if (!base_name %in% names(df)) {
      warning("No matching concentration column for: ", err_col, ". Skipping.")
      next
    }

    # Absolute = (relative / 100) * measured_value
    df[[err_col]] <- (df[[err_col]] / 100) * df[[base_name]]

    # Set units to match the concentration column
    units(df[[err_col]]) <- units(df[[base_name]])
  }

  return(df)
}

#' @rdname error_conversion
#' @export
abs_to_rel <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- get_error_columns(df)

  if (length(error_cols) == 0) {
    warning("No error columns found. Returning unchanged.")
    return(df)
  }

  # Process each error column
  for (err_col in names(error_cols)) {

    # Only process absolute errors
    if (!is_err_abs(err_col)) {
      next
    }

    # Find matching concentration column
    base_name <- gsub("_err(2)?(SD|SE)(%)?$", "", err_col)

    if (!base_name %in% names(df)) {
      warning("No matching concentration column for: ", err_col, ". Skipping.")
      next
    }

    # relative = (absolute / measured_value) * 100
    df[[err_col]] <- (df[[err_col]] / df[[base_name]]) * 100

    # Set units to percent
    units(df[[err_col]]) <- units::as_units("%")
  }

  return(df)
}
