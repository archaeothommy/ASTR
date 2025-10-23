#' Internal vctrs methods
#'
#' @import vctrs
#' @keywords internal
#' @name astr-vctrs
NULL

#' `percent` vector
#'
#' This creates a double vector that represents percentages.
#'
#' @param x ...
#' @return An S3 vector of class `astr_percent`.
#' @examples
#' percent(c(0.25, 0.5, 0.75))
#' @export
percent <- function(x = double()) {
  x <- vec_cast(x, double())
  new_percent(x)
}
new_percent <- function(x = double()) {
  if (!rlang::is_double(x)) { stop("x must be a double vector.") }
  new_vctr(x, class = "astr_percent")
}

#' @export
#' @rdname percent
is_percent <- function(x) { inherits(x, "astr_percent") }
#' @export
#' @rdname percent
as_percent <- function(x) { vec_cast(x, new_percent()) }

#' @export
format.astr_percent <- function(x, ...) {
  out <- formatC(signif(vec_data(x), 3))
  out[is.na(x)] <- NA
  out[!is.na(x)] <- paste0(out[!is.na(x)], "%")
  out
}
#' @export
vec_ptype_abbr.astr_percent <- function(x, ...) { "prcnt" }

#' @export
vec_ptype2.astr_percent.astr_percent <- function(x, y, ...) new_percent()
#' @export
vec_ptype2.astr_percent.double <- function(x, y, ...) double()
#' @export
vec_ptype2.double.astr_percent <- function(x, y, ...) double()

#' @export
vec_cast.astr_percent.astr_percent <- function(x, to, ...) x
#' @export
vec_cast.astr_percent.double <- function(x, to, ...) percent(x)
#' @export
vec_cast.double.astr_percent <- function(x, to, ...) vec_data(x)
