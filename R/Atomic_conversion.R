#' Conversion between wt% and at%
#'
#' Convert chemical compositions between weight percent (wt%) and atomic percent
#' (at%). The column names of the elements to be converted must be equivalent to
#' their chemical symbols.
#'
#' @param df Data frame with compositional data.
#' @param elements character vector with the chemical symbols of the elements
#'   that should be converted.
#' @param normalise If `TRUE`, will normalise converted concentrations to 100%.
#'   Default to `FALSE`.
#' @param drop If `TRUE`, the default, columns with unconverted values are
#'   dropped. If false, columns with unconverted values are kept and a suffix
#'   added to the column names of the converted values.
#'   * `_at` for conversions to atomic percent
#'   * `_wt` for conversions to weight percent.
#'
#' @return Data frame with the converted concentrations.
#'
#' @export
#' @name atomic_conversion
#'
#' @examples
#' # Convert weight percent to atomic percent
#' df <- data.frame(Si = 46.74, O = 53.26)  # SiO2 composition
#' wt_to_at(df, elements = c("Si", "O"))
#'
wt_to_at <- function(df, elements, normalise = FALSE, drop = TRUE) {

  # Validate inputs
  checkmate::assert_data_frame(df)

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # Check if all elements are valid chemical elements
  invalid_elements <- setdiff(elements, elements_data)
  if (length(invalid_elements) > 0) {
    stop("The following are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  atomic_weight <- conversion_oxides$AtomicWeight[match(elements, conversion_oxides$Element)]

  moles <- t(t(df) / atomic_weight)

  total <- rowSums(moles, na.rm = TRUE)
  total[total == 0] <- NA_real_
  at_percent <- moles / total * 100

  if (normalise) {
    at_percent <- normalise_rows(at_percent)
  }

  if (drop) {
    # Replace original columns with atomic percent
    df[elements] <- at_percent
  } else {
    # Add new columns with suffix
    colnames(at_percent) <- paste0(elements, "_at")
    df <- cbind(df, at_percent)
  }

  return(df)
}

#' @rdname atomic_conversion
#' @export
at_to_wt <- function(df, elements, normalise = FALSE, drop = TRUE) {

  # Validate inputs
  checkmate::assert_data_frame(df)

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # Check if all elements are valid chemical elements
  invalid_elements <- setdiff(elements, elements_data)
  if (length(invalid_elements) > 0) {
    stop("The following are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  atomic_weight <- conversion_oxides$AtomicWeight[match(elements, conversion_oxides$Element)]

  weight <- t(t(df) * atomic_weight)

  total <- rowSums(weight, na.rm = TRUE)
  total[total == 0] <- NA_real_
  wt_percent <- weight / total * 100

  if (normalise) {
    wt_percent <- normalise_rows(wt_percent)
  }

  if (drop) {
    # Replace original columns with atomic percent
    df[elements] <- wt_percent
  } else {
    # Add new columns with suffix
    colnames(wt_percent) <- paste0(elements, "_wt")
    df <- cbind(df, wt_percent)
  }

  return(df)
}

# Helper function (should be defined elsewhere or here)
normalise_rows <- function(values) {
  if (ncol(values) == 0) return(values)

  row_sums <- rowSums(values, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  values / row_sums * 100
}
