#' @name bdl_strategies
#'
#' @title Strategies to replace "below detection limit" values
#'
#' @description ...
#'
#' @param x a vector, derived from a data.frame column
#' @param colname name of the respective data.frame column
#' @param marker values indicating "below detection limit"
#' @param value value to replace values identified as "below detection limit"
#' @param ... further arguments passed to or from other methods
#'
#' @rdname bdl_strategies
#'
#' @examples
#' plot(1,1)
#'
NULL

#' @rdname bdl_strategies
#' @export
bdl_strategy_default <- function(x, colname, marker = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"), ...) {
  bdl_indices <- which(grepl(paste(marker, collapse = "|"), x, perl = FALSE))
  x[bdl_indices] <- NA_character_
  return(x)
}

#' @rdname bdl_strategies
#' @export
bdl_strategy_none <- function(x, colname, ...) {
  return(x)
}

#' @rdname bdl_strategies
#' @export
bdl_strategy_negative <- function(x, colname, value = NA_character_, ...) {
  bdl_indices <- which(grepl("^-\\d*\\.?\\d*\\*?\\d*\\^?\\-?\\d*$", x))
  x[bdl_indices] <- value
  return(x)
}
