# functions to select sets of columns for ASTR tables

is_ASTR_class <- function(x, classes) {
  any(attr(x, "ASTR_class") %in% classes)
}

get_cols_with_ac_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(y) {
      is_ASTR_class(y, classes)
    }
  ))
}

get_cols_without_ac_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(y) {
      !is_ASTR_class(y, classes)
    }
  ))
}

#' @rdname ASTR
#' @export
get_contextual_columns <- function(x, ...) {
  UseMethod("get_contextual_columns")
}
#' @export
get_contextual_columns.ASTR <- function(x, ...) {
  get_cols_with_ac_class(x, c("ASTR_id", "ASTR_context"))
}

#' @rdname ASTR
#' @export
get_analytical_columns <- function(x, ...) {
  UseMethod("get_analytical_columns")
}
#' @export
get_analytical_columns.ASTR <- function(x, ...) {
  get_cols_without_ac_class(x, "ASTR_context")
}

#' @rdname ASTR
#' @export
get_isotope_columns <- function(x, ...) {
  UseMethod("get_isotope_columns")
}
#' @export
get_isotope_columns.ASTR <- function(x, ...) {
  get_cols_with_ac_class(x, c("ASTR_id", "ASTR_isotope"))
}

#' @rdname ASTR
#' @export
get_element_columns <- function(x, ...) {
  UseMethod("get_element_columns")
}
#' @export
get_element_columns.ASTR <- function(x, ...) {
  get_cols_with_ac_class(x, c("ASTR_id", "ASTR_element"))
}

#' @rdname ASTR
#' @export
get_ratio_columns <- function(x, ...) {
  UseMethod("get_ratio_columns")
}
#' @export
get_ratio_columns.ASTR <- function(x, ...) {
  get_cols_with_ac_class(x, c("ASTR_id", "ASTR_ratio"))
}

#' @rdname ASTR
#' @export
get_concentration_columns <- function(x, ...) {
  UseMethod("get_concentration_columns")
}
#' @export
get_concentration_columns.ASTR <- function(x, ...) {
  get_cols_with_ac_class(x, c("ASTR_id", "ASTR_concentration"))
}

get_cols_with_unit <- function(x, units) {

  units <- sapply(units, function(unit) transform_notation(unit))

  dplyr::select(x, tidyselect::where(
    function(y) {
      inherits(y, "units")
    }
  )) %>%
    dplyr::select(tidyselect::where(
      function(y) {
        units::deparse_unit(y) %in% units
      }
    ))
}

#' @rdname ASTR
#' @param units A character vector with units to be selected.
#' @export
get_unit_columns <- function(x, units, ...) {
  UseMethod("get_unit_columns")
}
#' @export
get_unit_columns.ASTR <- function(x, units, ...) {
  get_cols_with_unit(x, units)
}
