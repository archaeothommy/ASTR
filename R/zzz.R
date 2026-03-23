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
    "conversion_oxides",
    "ArgentinaDatabase"
    "standard_groups",
    "references_geochem"
  )
)

#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
NULL
