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
get_contextual_columns <- function(x, ...) {
  UseMethod("get_contextual_columns")
}
#' @export
get_contextual_columns.archchem <- function(x, ...) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_context"))
}

#' @rdname archchem
#' @export
get_analytical_columns <- function(x, ...) {
  UseMethod("get_analytical_columns")
}
#' @export
get_analytical_columns.archchem <- function(x, ...) {
  get_cols_without_ac_class(x, "archchem_context")
}

#' @rdname archchem
#' @export
get_isotope_columns <- function(x, ...) {
  UseMethod("get_isotope_columns")
}
#' @export
get_isotope_columns.archchem <- function(x, ...) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_isotope"))
}

#' @rdname archchem
#' @export
get_element_columns <- function(x, ...) {
  UseMethod("get_element_columns")
}
#' @export
get_element_columns.archchem <- function(x, ...) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_element"))
}

#' @rdname archchem
#' @export
get_ratio_columns <- function(x, ...) {
  UseMethod("get_ratio_columns")
}
#' @export
get_ratio_columns.archchem <- function(x, ...) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_ratio"))
}

#' @rdname archchem
#' @export
get_concentration_columns <- function(x, ...) {
  UseMethod("get_concentration_columns")
}
#' @export
get_concentration_columns.archchem <- function(x, ...) {
  get_cols_with_ac_class(x, c("archchem_id", "archchem_concentration"))
}
