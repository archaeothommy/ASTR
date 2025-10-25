#' @rdname archchem
#' @export
remove_units <- function(x, ...) {
  UseMethod("remove_units")
}
#' @export
remove_units.archchem <- function(x, ...) {
  dplyr::mutate(
    x,
    dplyr::across(
      tidyselect::where(function(y) {
        class(y) == "units"
      }),
      units::drop_units
    )
  )
}

#' @rdname archchem
#' @param unit ...
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  UseMethod("unify_concentration_unit")
}
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  dplyr::mutate(
    x,
    dplyr::across(
      tidyselect::where(function(y) {
        class(y) == "units" &&
          is_archchem_class(y, "archchem_concentration")
      }),
      function(z) units::set_units(z, unit, mode = "standard")
    )
  )
}
