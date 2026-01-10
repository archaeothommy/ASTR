#' Atomic conversion functions
#'
#' Convert between weight percent (wt%) and atomic percent (wt%) compositions using built-in atomic weights.
#'
#' @param df Data frame with compositional data.
#' @param elements Element column names to convert.
#' @param normalize Normalize converted values to 100%?
#'
#' @return Data frame with converted columns added (_at suffix for atomic percent).
#'
#' @keywords internal
#' @name atomic_conversion
NULL

#' @rdname atomic_conversion
#' @keywords internal
wt_to_at <- function(df, elements, normalize = FALSE) {

  conv <- atomic_conversion
  rownames(conv) <- conv$Element

  elements <- intersect(elements, rownames(conv))
  if (!length(elements)) return(df)

  x <- as.matrix(df[elements])
  storage.mode(x) <- "double"

  aw <- conv[elements, "AtomicWeight"]
  moles <- sweep(x, 2, aw, "/")

  total <- rowSums(moles, na.rm = TRUE)
  total[total == 0] <- NA_real_
  at_percent <- sweep(moles, 1, total, "/") * 100

  colnames(at_percent) <- paste0(elements, "_at")

  if (normalize) {
    at_percent <- .normalize_rows(at_percent)
  }

  out <- df
  for (nm in colnames(at_percent)) {
    out[[nm]] <- at_percent[, nm]
  }

  out
}

#' @rdname atomic_conversion
#' @keywords internal
at_to_wt <- function(df, elements, normalize = FALSE) {

  conv <- atomic_conversion
  rownames(conv) <- conv$Element

  at_cols <- paste0(elements, "_at")
  missing <- setdiff(at_cols, names(df))
  if (length(missing) > 0) {
    stop("Missing atomic percent columns: ", paste(missing, collapse = ", "))
  }

  x <- as.matrix(df[at_cols])
  storage.mode(x) <- "double"

  aw <- conv[elements, "AtomicWeight"]
  weight <- sweep(x, 2, aw, "*")

  total <- rowSums(weight, na.rm = TRUE)
  total[total == 0] <- NA_real_
  wt_percent <- sweep(weight, 1, total, "/") * 100

  colnames(wt_percent) <- elements

  if (normalize) {
    wt_percent <- .normalize_rows(wt_percent)
  }

  out <- df
  for (nm in elements) {
    out[[nm]] <- wt_percent[, nm]
  }

  out
}
