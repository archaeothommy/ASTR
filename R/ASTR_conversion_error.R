#' Convert between relative and absolute analytical uncertainties
#'
#' Convert relative to absolute analytical uncertainties and vice versa in ASTR
#' objects. Work only for objects of class `ASTR`.
#'
#' @param df An ASTR object
#' @return An ASTR object with converted analytical precision columns. The
#'   unchanged input, if it does not contain columns of the respective
#'   analytical precision type
#'
#'
#' @name error_conversion
#' @export
#'
#' @examples
#' test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
#' arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#'
#' arch2 <- abs_to_rel(arch)
#'
#' arch3 <- rel_to_abs(arch2)
#'
#' # Conversion is lossless
#' all.equal(arch$`SiO2_errSD`, arch3$`SiO2_errSD`)
#'
rel_to_abs <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- colnames(df)[is_err_percent(colnames(df))]

  if (length(error_cols) == 0) {
    return(df)
  }

  df_old <- df

  # Process all error columns
  for (err_col in error_cols) {
    base_name <- remove_suffix(err_col)

    if (base_name %in% names(df)) {
      # absolute = relative * measured_value
      df[[err_col]] <- df[[err_col]] * df[[base_name]] / ifelse(inherits(df[[base_name]], "units"), 1, 100)

      # Set units to match the concentration column
      if (inherits(df[[base_name]], "units")) {
        units(df[[err_col]]) <- units(df[[base_name]])
      } else {
        units(df[[err_col]]) <- NULL
      }
    }
  }

  # assign ASTR class
  df <- preserve_ASTR_attrs(df, df_old)

  # rename column names
  colnames(df)[colnames(df) %in% error_cols] <- gsub("%", "", error_cols)

  return(df)
}

#' @rdname error_conversion
#' @export
abs_to_rel <- function(df) {

  # Basic checks
  checkmate::assert_class(df, "ASTR")

  # Find all error columns
  error_cols <- colnames(df)[is_err_abs(colnames(df))]

  if (length(error_cols) == 0) {
    return(df)
  }

  df_old <- df

  # Process all error columns
  for (err_col in error_cols) {
    base_name <- remove_suffix(err_col)

    # relative = (absolute / measured_value)
    df[[err_col]] <- df[[err_col]] / df[[base_name]] * ifelse(inherits(df[[base_name]], "units"), 1, 100)

    # Set units to percent
    units(df[[err_col]]) <- units::as_units("%")
  }

  # assign ASTR class
  df <- preserve_ASTR_attrs(df, df_old)

  # rename columns
  colnames(df)[colnames(df) %in% error_cols] <- paste0(error_cols, "%")

  return(df)
}
