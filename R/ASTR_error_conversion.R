#' Convert relative errors to absolute errors in ASTR object
#'
#' Converts all relative error columns to absolute errors using their
#' corresponding measured value columns.
#'
#' @param df An ASTR object
#' @return An ASTR object with errors converted to absolute
#' @export
#'
#' @examples
#'
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

    # Find matching concentration column
    base_name <- gsub("_err.*$", "", err_col)

    if (!base_name %in% names(df)) {
      warning("No matching concentration column for: ", err_col, ". Skipping.")
      next
    }

    # Check if error is relative (has % units)
    err_unit <- units::deparse_unit(df[[err_col]])

    if (!err_unit %in% c("%", "atP", "wtP")) {
      warning("Error column ", err_col, " has unit ", err_unit,
              " which is not recognized as relative. Skipping.")
      next
    }

    # absolute = (relative / 100) * measured_value
    df[[err_col]] <- (df[[err_col]] / 100) * df[[base_name]]

    # Set units to match the concentration column
    units(df[[err_col]]) <- units(df[[base_name]])

    # Update ASTR_class to mark as absolute error
    attr(df[[err_col]], "ASTR_class") <- "ASTR_error_absolute"
  }

  return(df)
}

#' Convert absolute errors to relative errors in ASTR object
#'
#' Converts all absolute error columns to relative errors (%).
#'
#' @param df An ASTR object
#' @return An ASTR object with errors converted to relative
#' @export
#'
#' @examples
#'
abs_to_rel <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns (both regular and absolute-marked)
  error_cols <- get_error_columns(df, "ASTR_error")
  abs_error_cols <- get_cols_with_ac_class(df, "ASTR_error_absolute")

  all_error_cols <- unique(c(names(error_cols), names(abs_error_cols)))

  if (length(all_error_cols) == 0) {
    warning("No error columns found. Returning unchanged.")
    return(df)
  }

  # Process each error column
  for (err_col in all_error_cols) {

    # Find matching concentration column
    base_name <- gsub("_err.*$", "", err_col)

    if (!base_name %in% names(df)) {
      warning("No matching concentration column for: ", err_col, ". Skipping.")
      next
    }

    # Check if error is absolute (same unit as concentration)
    err_unit <- units::deparse_unit(df[[err_col]])
    conc_unit <- units::deparse_unit(df[[base_name]])

    if (err_unit != conc_unit) {
      warning("Error column ", err_col, " does not share units with its concentration column.",
              "\n  Error unit: ", err_unit, " | Concentration unit: ", conc_unit,
              "\n  Skipping conversion.")
      next
    }

    # relative = (absolute / measured_value) * 100
    df[[err_col]] <- (df[[err_col]] / df[[base_name]]) * 100

    # Set units to percent
    units(df[[err_col]]) <- units::as_units("%")

    # Update ASTR_class
    attr(df[[err_col]], "ASTR_class") <- "ASTR_error"
  }

  return(df)
}
