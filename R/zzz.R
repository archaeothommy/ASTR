# defining global variables
# ugly solution to avoid magrittr NOTE
# see http://stackoverflow.com/questions/9439256/
# how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
globalVariables(".")

#' @importFrom magrittr "%>%"
#' @importFrom rlang .data :=
#'
NULL

# registers the dimensionless units at% (atom percent) and wt% (weight percent)
# when the package is loaded
.onLoad <- function(libname, pkgname) {
  try(
    units::install_unit(
      symbol = "atP", # at% is not allowed https://github.com/r-quantities/units/issues/289
      def = "percent",
      name = "atom percent"
    ),
    silent = TRUE
  )
  try(
    units::install_unit(
      symbol = "wtP",
      def = "percent",
      name = "weight percent"
    ),
    silent = TRUE
  )
}
