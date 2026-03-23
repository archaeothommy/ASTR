#' Elements
#'
#' List of elements, sorted according to alphabet
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name elements_data
"elements_data"

#' Oxides
#'
#' List of oxides, sorted according to alphabet.
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name oxides_data
"oxides_data"

#' Special oxide states
#'
#' List of values that are treated like oxides, but are no chemical oxides.
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name special_oxide_states
"special_oxide_states"

#' Isotopes
#'
#' List of naturally occurring isotopes, retrieved from https://www.ciaaw.org/isotopic-abundances.htm,
#' sorted according to chemical element and isotope number
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name isotopes_data
"isotopes_data"

#' Conversion factors from oxides to elements
#'
#' @format A data frame with 106 rows and 7 variables:
#' \describe{
#'   \item{Element}{The symbol of a chemical element.}
#'   \item{AtomicWeight}{The atomic weight (= molar mass) of the respective element.}
#'   \item{Oxide}{The formula of the chemical element's oxide.}
#'   \item{M}{The number of oxygen atoms in the oxide = the number of moles oxygen per mole oxide.}
#'   \item{OxideWeight}{The molar mass of the oxide.}
#'   \item{ElementToOxide}{The factor used in the conversion from the chemical element to its oxide.}
#'   \item{OxideToElement}{The factor used in the conversion from the oxide to its chemical element.}
#'   \item{OxidationState}{The oxidation state of the kation as numeric value.}
#' }
#'
#' @family chemical_reference_data
#' @name conversion_oxides
"conversion_oxides"

#' ArgentinaDatabase
#'
#' Lead isotope data from ore deposits in Argentina prepared for TerraLID database.
#'
#' @format ## `ArgentinaDatabase`
#'
#' A dataframe with 112 rows and 49 columns
#'
#' @source <https://globalid.dmt-lb.de/>
#' @name ArgentinaDatabase
"ArgentinaDatabase"

#' Geochemical reference compositions
#'
#' List with reference values for common geochemical normalisation such as
#' chondrite or MORB. All values in ppm. See the dataset for a list of available
#' reference compositions.
#'
#' @references Chondrite: Table 1 in Sun, S.-S. and McDonough, W. F. (1989)
#'   Chemical and isotopic systematics of oceanic basalts. Geological Society,
#'   London, Special Publications 42,
#'   313-345.<https://doi.org/10.1144/GSL.SP.1989.042.01.19> (
#'
#'   MORB: values for NMORB.
#'
"references_geochem"

#' Geochemical reference compositions
#'
#' Lists with chemical symbols of typical element and oxide sets used in
#' geochemistry and archaeometry, such as REE. They allow more convenient and
#' reproducible subsetting of datasets. See the dataset for a list of available
#' sets.
#'
"standard_groups"
