# functions to define classes for columns in archchem (e.g. for columns newly defined in functions)

#' @rdname archchem
#' @export
as_contextual_column <- function(x, ...) {
  UseMethod("as_contextual_column")
}
#' @export
as_contextual_column.archchem <- function(x, ...) {
  sapply(x, structure, class = "archchem_context")
}
