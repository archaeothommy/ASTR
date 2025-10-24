#' Elements
#'
#' List of elements, sorted according to alphabet
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name elements
"elements"

#' Oxides
#'
#' List of oxides, retrieved from https://www.wikidoc.org/index.php/Oxide,
#' sorted according to alphabet
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name oxides
"oxides"

#' Isotopes
#'
#' List of naturally occurring isotopes, retrieved from https://www.ciaaw.org/isotopic-abundances.htm,
#' sorted according to chemical element and isotope number
#'
#' @format a vector
#'
#' @family chemical_reference_data
#' @name isotopes
"isotopes"

#' archchem_example_input
#'
#' A dataset that contains fictitious data mimicking lead slags
#' including composition, isotopic, and contextual information.
#' The variable names conform to ASTR conventions (see "ASTR Schema" vignette).
#'
#' \itemize{
#'   \item Sample. Individual samples for which compositional and isotopic data, and contextual information is provided in this dataset.
#'   \item Lab.no, Site, latitude, longitude, Type, method_comp. Columns containing contextual information on the samples.
#'   \item 143Nd/144Nd, d65Cu, d65Cu_err2SD, 206Pb/204Pb, 206Pb/204Pb_err2SD, 207Pb/204Pb, 207Pb/204Pb_err2SD, 208Pb/204Pb, 208Pb/204Pb_err2SD,207Pb/206Pb, 207Pb/206Pb_err2SD,208Pb/206Pb, 208Pb/206Pb_err2SD. Columns containing isotopic data.
#'   \item Na2O_wt%, BaO_wt%, Pb_wt%, MgO_wt%, Al2O3_wt%, SiO2_wt%, SiO2_SD%, P2O5_wt%, S_at%, CaO_wt%,TiO2_wt%, MnO_wt%, FeOtot_wt%, FeOtot_err2SD, ZnO%, K2O_wt%, Cu_wt%, As_wt%, LOI_wt%, Ag_ppb, Sn_µg/ml, Sb_ppm, Te_ppm, Bi_ppm, U_ppm, V_ppm, Cr_ppm, Co_ppm, Ni_ppm, Sr_ppm, Se_ppm, FeOtot/SiO2, (Na2O+K2O)/SiO2. Columns containing compositional data.
#'   }
#'
#' @docType data
#' @keywords datasets
#' @name archchem_example_input
#' @usage data(archchem_example_input)
#' @format A data frame with 15 observations and 53 variables.
#'
"archchem_example_input"
