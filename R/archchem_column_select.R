# functions to select sets of columns for archchem tables

get_cols_with_ac_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(y) {
      any(attr(y, "archchem_class") %in% classes)
    }
  ))
}

get_cols_without_ac_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(y) {
      !any(attr(y, "archchem_class") %in% classes)
    }
  ))
}

#' @rdname archchem
#' @export
get_analytical_columns <- function(x, ...) {
  UseMethod("remove_units")
}
#' @rdname archchem
#' @export
get_analytical_columns.default <- function(x, ...) {
  stop("x is not an object of class archchem")
}
#' @export
get_analytical_columns <- function(x) {
  get_cols_without_ac_class(x, "archchem_context")
}

#' @rdname archchem
#' @export
get_contextual_columns <- function(x, ...) {
  UseMethod("remove_units")
}
#' @rdname archchem
#' @export
get_contextual_columns.default <- function(x, ...) {
  stop("x is not an object of class archchem")
}
#' @export
get_contextual_columns <- function(x) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_context"))
}

