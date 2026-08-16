#' Chemical elements
#'
#' List of chemical elements as their symbols, sorted according to alphabet.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name elements_data
"elements_data"

#' Oxides
#'
#' List of oxides, sorted according to alphabet.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name oxides_data
"oxides_data"

#' Special oxide states
#'
#' List of values that are treated like oxides, but are no chemical oxides.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name special_oxide_states
"special_oxide_states"

#' Isotopes
#'
#' List of naturally occurring isotopes, retrieved from
#' https://www.ciaaw.org/isotopic-abundances.htm, sorted according to chemical
#' element and isotope number
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name isotopes_data
"isotopes_data"

#' Conversion factors from oxides to elements
#'
#' @format A data frame with 151 rows and 8 variables:
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
#' @family chemical reference data
#' @name conversion_oxides
"conversion_oxides"

#' Lead isotope data from Argentina
#'
#' Lead isotope data from ore deposits in Argentina prepared for the TerraLID database.
#'
#' @format `ArgentinaDatabase`
#'
#' A dataframe with 112 rows and 49 columns
#'
#' @source <https://globalid.dmt-lb.de/>
#' @name ArgentinaDatabase
"ArgentinaDatabase"

#' Geochemical and other standard groups of elements, oxides, or isotopes
#' @format A list of sets of elements, oxides, or isotopes that represent
#'   geochemical groups or other commonly used groups. To retrieve the full list
#'   of e.g. the HFSE elements, run `standard_groups$HFSE`.
#' \describe{
#'   \item{REE}{Rare Earth Elements, taken from Periodic table of elements}
#'   \item{HFSE}{High field-strength elements as listed in Salters (1998)}
#'   \item{LILE}{Large-ion lithophile elements, as listed in Rudnick (1998)}
#' }
#'
#' @references Salters, V.J.M. (1998). Elements: High field strength. In:
#'   Geochemistry. Encyclopedia of Earth Science. Springer, Dordrecht.
#'   https://doi.org/10.1007/1-4020-4496-8_101
#'
#'   Rudnick, R.L. (1998). Elements: Large-ion lithophile. In: Geochemistry.
#'   Encyclopedia of Earth Science. Springer, Dordrecht.
#'   https://doi.org/10.1007/1-4020-4496-8_104
#'
#' @name standard_groups
"standard_groups"

#' Reference compositions
#'
#' @format A list including sets of chemical compositions often used as
#'   reference composition for e.g. normalisation. Values are stored as named
#'   vectors of their concentration with assigned units (using
#'   \link[units]{set_units}). To retrieve the list of elements and their
#'   concentrations for e.g. the PM, run `references_geochem$PM`.
#' \describe{
#'   \item{chondrite}{CI chondrite composition in ppm, as defined by Sun &
#'   McDonough (1989)}
#'   \item{PM}{Primitive mantle composition in ppm, as defined by Sun &
#'   McDonough (1989)}
#'   \item{NMORB}{Normal Mid-ocean ridge basalt composition in ppm, as defined
#'   by Sun & McDonough (1989)}
#'   \item{EMORB}{Enhanced Mid-Ocean Ridge Basalt composition in ppm, as
#'   defined by Sun & McDonough (1989)}
#'   \item{OIB}{Ocean Island Basalt composition in ppm, as defined by Sun &
#'   McDonough (1989)}
#' }
#'
#' @references Sun, S.-S. & McDonough, W.F. (1989). Chemical and isotopic
#'   systematics of oceanic basalts. Geological Society, London, Special
#'   Publications 42, pp.313-345. Table 1, page 318.
#'   <https://doi.org/10.1144/gsl.sp.1989.042.01.19>.
#'
#' @name references_geochem
"references_geochem"
