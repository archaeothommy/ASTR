#' Conversion between wt% and at%
#'
#' Convert chemical compositions between weight percent (wt%) and atomic percent
#' (at%).
#'
#' @param df Data frame with compositional data.
#' @param elements named character vector with the column names of the elements.
#' @param normalise If `TRUE`, will normalise converted concentration to 100%.
#'   Default to `FALSE`.
#' @param drop If `FALSE` keeps columns with unconverted values. Default to
#'   `TRUE`.
#'
#' @return Data frame with the converted concentrations. If `drop = FALSE`, a
#'   suffix is added to the column names with the converted values:
#'   * `_at%` for conversions to atomic percent
#'   * `_wt%` for conversions to weight percent.
#'
#' @export
#' @name atomic_conversion
#'
#' @examples
#' # example code
#'

wt_to_at <- function(df, elements, normalise = FALSE, drop = TRUE) {

  elements <- intersect(elements, unique(conversion_oxides$Element))

  if (!length(elements)) return(df)

  x <- as.matrix(df[elements])
  storage.mode(x) <- "double"

  aw <- conversion_oxides[conversion_oxides$Element %in% elements, "AtomicWeight"]

  moles <- sweep(x, 2, aw, "/")

  total <- rowSums(moles, na.rm = TRUE)
  total[total == 0] <- NA_real_
  at_percent <- sweep(moles, 1, total, "/") * 100

  if (normalise) {
    at_percent <- normalise_rows(at_percent)
  }

  if (drop) {
    at_percent <- as.data.frame(at_percent)
    df[elements] <- at_percent[elements]
  } else {
    colnames(at_percent) <- paste0(elements, "_at")
    df <- cbind(df, at_percent)
  }

  df
}

#' @rdname atomic_conversion
#' @export
at_to_wt <- function(df, elements, normalise = FALSE, drop = TRUE) {

  at_cols <- paste0(elements, "_at")
  missing <- setdiff(at_cols, names(df))
  if (length(missing) > 0) {
    stop("Missing atomic percent columns: ", paste(missing, collapse = ", "))
  }

  x <- as.matrix(df[at_cols])
  storage.mode(x) <- "double"

  aw <- conversion_oxides[elements, "AtomicWeight"]
  weight <- sweep(x, 2, aw, "*")

  total <- rowSums(weight, na.rm = TRUE)
  total[total == 0] <- NA_real_
  wt_percent <- sweep(weight, 1, total, "/") * 100

  colnames(wt_percent) <- elements

  if (normalise) {
    wt_percent <- normalise_rows(wt_percent)
  }

  out <- df
  for (nm in elements) {
    out[[nm]] <- wt_percent[, nm]
  }

  out
}
