# defining global variables
utils::globalVariables(
  c(
    # ugly solution to avoid magrittr NOTE
    # see http://stackoverflow.com/questions/9439256/
    # how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    ".",
    # register data objects to make lintr aware of them
    "isotopes_data",
    "elements_data",
    "oxides_data",
    "special_oxide_states",
    "conversion_oxides"
  )
)

#' @importFrom magrittr "%>%"
#' @importFrom rlang .data :=
#'
NULL

# registers the dimensionless units at% (atom percent) and wt% (weight percent)
# when the package is loaded
.onLoad <- function(libname, pkgname) {
  safe_install <- function(...) {
    tryCatch(
      units::install_unit(...),
      error = function(e) NULL
    )
  }
  # dummy base units (purely semantic)
  safe_install("atomic_basis")
  safe_install("mass_basis")
  # percent-like units
  safe_install(
    symbol = "atP",
    def    = "0.01 atomic_basis",
    name   = "atom percent"
  )
  safe_install(
    symbol = "wtP",
    def    = "0.01 mass_basis",
    name   = "weight percent"
  )
}
