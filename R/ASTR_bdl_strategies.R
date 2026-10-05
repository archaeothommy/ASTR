#' @name bdl_strategies
#'
#' @title Strategies to replace "below detection limit" values in [as_ASTR()],
#' and [read_ASTR()] with the `bdl_strategy` argument
#'
#' @description The bdl strategies are functions that get used in the preparation of
#' `ASTR` objects: Each strategy function is applied to every column
#' of the input dataset. So they are functions that get used by other functions.
#' Consequently they need to have a very specific form, to match the expectations
#' of the functions that call them.
#'
#' The provided strategies `bdl_strategy_default` and `bdl_strategy_negative` cover
#' common usecases. The example code below shows how they are implemented, and how
#' to build custom strategies based on that.
#' When they are used with [as_ASTR()] or [read_ASTR()], multiple strategies can be
#' combined with [purrr::compose()].
#'
#' @param x a vector, derived from a data.frame column
#' @param colname name of the respective data.frame column
#' @param ... further arguments passed to or from other methods
#'
#' @rdname bdl_strategies
#'
NULL

#' @rdname bdl_strategies
#' @export
bdl_strategy_none <- function(x, colname, ...) {
  return(x)
}

#' @rdname bdl_strategies
#' @export
bdl_strategy_default <- function(x, colname, ...) {
  bdl_strings <- c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<")
  bdl_indices <- which(grepl(paste(bdl_strings, collapse = "|"), x, perl = FALSE))
  x[bdl_indices] <- NA_character_
  return(x)
}

#' @rdname bdl_strategies
#' @export
bdl_strategy_negative <- function(x, colname, ...) {
  y <- suppressWarnings(as.numeric(x))
  bdl_indices <- which(y < 0)
  x[bdl_indices] <- NA_character_
  return(x)
}

#' @rdname bdl_strategies
#' @examples
#' # no replacement of bdl values: the input value is just returned as is
#' bdl_strategy_none <- function(x, colname, ...) {
#'   return(x)
#' }
#'
#' # default strategy: a set of strings in x is replaced with NA
#' bdl_strategy_default <- function(x, colname, ...) {
#'   bdl_strings <- c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<")
#'   bdl_indices <- which(grepl(paste(bdl_strings, collapse = "|"), x, perl = FALSE))
#'   x[bdl_indices] <- NA_character_
#'   return(x)
#' }
#'
#' # replace negative values: if a value in x is below 0 then is replaced with NA
#' bdl_strategy_negative <- function(x, colname, ...) {
#'   y <- suppressWarnings(as.numeric(x))
#'   bdl_indices <- which(y < 0)
#'   x[bdl_indices] <- NA_character_
#'   return(x)
#' }
#'
#' # custom strategy: replace a specific string in x with NA,
#' # but only for the columns d65Cu and d65Cu_err2SD
#' your_bdl_strategy <- function(x, colname, ...) {
#'   if (colname %in% c("d65Cu", "d65Cu_err2SD")) {
#'     bdl_indices <- which(grepl("BDL", x, perl = FALSE))
#'     x[bdl_indices] <- NA_character_
#'     return(x)
#'   } else {
#'     return(x)
#'   }
#' }
#'
#' @name bdl_strategies
#'
NULL
