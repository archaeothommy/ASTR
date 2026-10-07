#' Chemical elements
#'
#' List of chemical elements as their symbols, sorted alphabetically.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name elements_data
"elements_data"

#' Oxides
#'
#' List of oxides, sorted alphabetically.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name oxides_data
"oxides_data"

#' Special oxide states
#'
#' List of values that are treated like oxides, but are not chemical oxides.
#'
#' @format a vector
#'
#' @family chemical reference data
#' @name special_oxide_states
"special_oxide_states"

#' Isotopes
#'
#' List of naturally occurring isotopes, retrieved from
#' https://www.ciaaw.org/isotopic-abundances.htm, sorted by chemical
#' element and isotope number.
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
#'   \item{OxidationState}{The oxidation state of the cation as a numeric value.}
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
#' A data frame with 112 rows and 49 columns
#'
#' @source <https://globalid.dmt-lb.de/>
#' @name ArgentinaDatabase
"ArgentinaDatabase"

#' GloabaLID lead isotope database
#'
#' ASTR object containing lead isotope data along with "Political province/regions"
#' as a grouping variable.
#'
#' @format ASTR object with 1 contextual and 3 Pb Isotope variables
#'  \describe{
#'   \item{Political province/regions}{Regional grouping of lead isotope data.}
#'   \item{206Pb/204Pb}{Lead isotope ratio of 206Pb/204Pb.}
#'   \item{207Pb/204Pb}{Lead isotope ratio of 207Pb/204Pb.}
#'   \item{208Pb/204Pb}{Lead isotope ratio of 208Pb/204Pb.}
#' }
#'
#' @source <https://globalid.dmt-lb.de/>
"GlobaLID_ASTR"

#' Machine learning model for lead isotope provenance.
#'
#' Lead isotope data model based on GlobaLID for machine learning provenance.
#'
#' @format A list of xgb models, with length equal to number of groups.
#'
#' @source <https://globalid.dmt-lb.de/>
"ml_model"

#' LIA points of silver hoard from Tell Dor (Israel)
#'
#' Lead isotope ratios of a Phoenician silver hoard from Tel Dor.
#' Reference data set of isotope ratios using [as_ASTR()]
#' @name tel_dor
#' @format ASTR object with 3 Pb isotope variables
#' \describe{
#'   \item{206Pb/204Pb}{Lead isotope ratio of 206Pb/204Pb.}
#'   \item{207Pb/204Pb}{Lead isotope ratio of 207Pb/204Pb.}
#'   \item{208Pb/204Pb}{Lead isotope ratio of 208Pb/204Pb.}
#' }
#'
#' @source Eshel, T., Erel, Y., Yahalom-Mack, N., Tirosh, O., and Gilboa, A.
#'   (2019). Lead isotopes in silver reveal earliest Phoenician quest for metals
#'   in the west Mediterranean. Proceedings of the National Academy of Sciences
#'   116(13), 6007–6012. <https://doi.org/10.1073/pnas.1817951116>
#'
#' @family Pb isotope functions
"tel_dor"
