#' Convert between weight percent and atomic percent
#'
#' @description
#' Simple conversion between weight percent (wt%) and atomic percent (at%)
#' using atomic weights. They perform direct stoichiometric
#' transformations without normalization or thresholds.
#'
#' @section Limitations:
#' \itemize{
#'   \item Assumes all input values are in wt% or at%.
#'   \item Does not handle units or unit conversions.
#'   \item No automatic detection of composition columns.
#'   \item Conversion factors must be provided.
#' }
#'
#' @param df
#' A data frame containing composition values.
#'
#' @param conversion_table
#' A data frame with columns: `Element`, `AtomicWeight`.
#'
#' @param elements
#' Character vector of element names to convert. These must exist
#' as columns in `df` (for `wt_to_at`) or as `*_at` columns (for `at_to_wt`).
#'
#' @return
#' A modified version of `df` with converted columns added.
#' Atomic percent columns have "_at" suffix, weight percent columns
#' have no suffix.
#'
#' @examples
#' conv <- data.frame(
#'   Element = c("Si", "O"),
#'   AtomicWeight = c(28.085, 15.999)
#' )
#'
#' df_wt <- data.frame(Si = 46.75, O = 48.0)
#' wt_to_at(df_wt, conv, elements = c("Si", "O"))
#'
#' df_at <- data.frame(Si_at = 33.3, O_at = 66.7)
#' at_to_wt(df_at, conv, elements = c("Si", "O"))
#'
#' @name atomic_conversion
NULL


#' @rdname atomic_conversion
#' @export
wt_to_at <- function(df, conversion_table, elements) {
  out <- df

  # Validate inputs
  missing_elements <- setdiff(elements, names(df))
  if (length(missing_elements) > 0) {
    stop("Missing element columns in df: ",
         paste(missing_elements, collapse = ", "), call. = FALSE)
  }

  # Get atomic weights
  aw <- sapply(elements, function(el) {
    wt <- conversion_table$AtomicWeight[conversion_table$Element == el]
    if (length(wt) == 0) {
      stop("No atomic weight for element: ", el, call. = FALSE)
    }
    wt[1]
  })

  # Calculate moles = wt% / atomic weight
  moles <- matrix(NA_real_, nrow = nrow(df), ncol = length(elements))
  for (i in seq_along(elements)) {
    moles[, i] <- df[[elements[i]]] / aw[i]
  }

  # Calculate total moles (handle all-NA rows)
  total_moles <- rowSums(moles, na.rm = TRUE)
  total_moles[total_moles == 0] <- NA_real_

  # Calculate atomic percent = (moles / total moles) * 100
  for (i in seq_along(elements)) {
    out[[paste0(elements[i], "_at")]] <- (moles[, i] / total_moles) * 100
  }

  out
}


#' @rdname atomic_conversion
#' @export
at_to_wt <- function(df, conversion_table, elements) {
  out <- df

  # Find atomic percent columns
  at_cols <- paste0(elements, "_at")
  missing <- setdiff(at_cols, names(df))
  if (length(missing) > 0) {
    stop("Missing atomic percent columns: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }

  # Get atomic weights
  aw <- sapply(elements, function(el) {
    wt <- conversion_table$AtomicWeight[conversion_table$Element == el]
    if (length(wt) == 0) {
      stop("No atomic weight for element: ", el, call. = FALSE)
    }
    wt[1]
  })

  # Calculate weight = at% * atomic weight
  weight <- matrix(NA_real_, nrow = nrow(df), ncol = length(elements))
  for (i in seq_along(elements)) {
    weight[, i] <- df[[at_cols[i]]] * aw[i]
  }

  # Calculate total weight (handle all-NA rows)
  total_weight <- rowSums(weight, na.rm = TRUE)
  total_weight[total_weight == 0] <- NA_real_

  # Calculate weight percent = (weight / total weight) * 100
  for (i in seq_along(elements)) {
    out[[elements[i]]] <- (weight[, i] / total_weight) * 100
  }

  out
}
