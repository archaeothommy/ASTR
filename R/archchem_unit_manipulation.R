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
      tidyselect::where(function(x) {
        class(x) == "units"
      }),
      units::drop_units
    )
  )
}
