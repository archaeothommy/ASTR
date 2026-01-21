#' Conversion between wt% and at%
#'
#' Convert chemical compositions between weight percent (wt%) and atomic percent
#' (at%). The column names of the elements to be converted must be equivalent to
#' their chemical symbols.
#'
#' @param df Data frame with compositional data.
#' @param elements character vector with the chemical symbols of the elements
#'   that should be converted.
#' @param normalise If `TRUE`, will normalise converted concentration to 100%.
#'   Default to `FALSE`.
#' @param drop If `FALSE` keeps columns with unconverted values. Default to
#'   `TRUE`.
#'
#' @return Data frame with the converted concentrations. If `drop = FALSE`, a
#'   suffix is added to the column names with the converted values:
#'   * `_at` for conversions to atomic percent
#'   * `_wt` for conversions to weight percent.
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
  if (!is.data.frame(df)) {
    stop("df must be a data frame")
  }

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # Check if all elements are valid chemical elements
  valid_elements <- unique(conversion_oxides$Element)
  invalid_elements <- setdiff(elements, valid_elements)
  if (length(invalid_elements) > 0) {
    stop("The following are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  moles <- list()

  aw <- conversion_oxides$AtomicWeight[
    match(elements, conversion_oxides$Element)
  ]

  for (i in seq_along(elements)) {
    el <- elements[i]
    moles[[el]] <- df[[el]] / aw[i]
  }

  moles <- as.data.frame(moles)

  total <- rowSums(moles, na.rm = TRUE)
  total[total == 0] <- NA_real_
  at_percent <- sweep(moles, 1, total, "/") * 100

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
  if (!is.data.frame(df)) {
    stop("df must be a data frame")
  }

  # Check if all elements are valid chemical elements
  valid_elements <- unique(conversion_oxides$Element)
  invalid_elements <- setdiff(elements, valid_elements)
  if (length(invalid_elements) > 0) {
    stop("The following are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  at_cols <- paste0(elements, "_at")

  # Check if all atomic percent columns are in df
  missing_from_df <- setdiff(at_cols, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following atomic percent columns are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  weight <- list()

  aw <- conversion_oxides$AtomicWeight[
    match(elements, conversion_oxides$Element)
  ]

  for (i in seq_along(elements)) {
    el <- elements[i]
    at_col <- paste0(el, "_at")
    weight[[el]] <- df[[at_col]] * aw[i]
  }

  weight <- as.data.frame(weight)

  total <- rowSums(weight, na.rm = TRUE)
  total[total == 0] <- NA_real_
  wt_percent <- sweep(weight, 1, total, "/") * 100

  colnames(wt_percent) <- elements

  if (normalise) {
    wt_percent <- normalise_rows(wt_percent)
  }

  if (drop) {
    # Replace atomic percent columns with weight percent
    # First remove the _at columns
    df <- df[, !names(df) %in% at_cols, drop = FALSE]
    # Add weight percent columns
    df[elements] <- wt_percent
  } else {
    # Add new columns with weight percent
    df[elements] <- wt_percent
  }

  return(df)
}

# Helper function (should be defined elsewhere or here)
normalise_rows <- function(mat) {
  if (ncol(mat) == 0) return(mat)

  row_sums <- rowSums(mat, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  sweep(mat, 1, row_sums, "/") * 100
}
