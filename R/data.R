#' Elements
#'
#' List of elements, sorted according to alphabet
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name elements_data
"elements"

#' Oxides
#'
#' List of oxides, sorted according to alphabet.
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name oxides_data
"oxides"

#' Isotopes
#'
#' List of naturally occurring isotopes, retrieved from https://www.ciaaw.org/isotopic-abundances.htm,
#' sorted according to chemical element and isotope number
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name isotopes_data
"isotopes"

#' Conversion factors from oxides to elements
#'
#' @format A data frame with 106 rows and 7 variables:
#' \describe{
#'   \item{Element}{The symbol of a chemical element.}
#'   \item{AtomicWeight}{The atomic weight (= molar mass) of the respective element.}
#'   \item{Oxide}{The formula of the chemical element's oxide.}
#'   \item{M}{The number of oxygen atoms in the oxide = the number of moles oxygen per mole oxide.}
#'   \item{OxideWeight}{The molar mass of the oxide.}
#'   \item{element_to_oxide}{The factor used in the conversion from the chemical element to its oxide.}
#'   \item{oxide_to_element}{The factor used in the conversion from the oxide to its chemical element.}
#' }
#'
#' @family chemical_reference_data
#' @name conversion_oxides
"conversion_oxides"
