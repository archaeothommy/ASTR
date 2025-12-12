#' Conversion between element wt% and oxide wt%.
#'
#' @description
#' Simple stoichiometric conversion between element and oxide compositions.
#' These functions perform direct multiplication using conversion factors
#' without applying normalization, thresholds, or interpretation.
#'
#'  @section Limitations:
#' \itemize{
#'   \item Does not support multiple oxides per element; the first match is used.
#'   \item Does not auto-detect columns; user must specify which to convert.
#'   \item Overwrites output if different elements map to the same oxide.
#'   \item No bulk conversion; each conversion must be explicitly requested.
#' }
#'
#' @param df
#' A data frame containing the element or oxide concentration values.
#'
#' @param conversion_table
#' A data frame with columns: `Element`, `Oxide`, `element_to_oxide`,
#' `oxide_to_element`.
#'
#' @param elements
#' Character vector of element column names to convert.
#'
#' @param oxides
#' Character vector of oxide column names to convert.
#'
#' @return
#' A modified version of `df` with converted columns added.
#' Original columns are preserved.
#'
#' @examples
#' conv <- data.frame(
#'   Element = c("Si", "Fe"),
#'   Oxide = c("SiO2", "FeO"),
#'   element_to_oxide = c(2.139, 1.286),
#'   oxide_to_element = c(0.467, 0.777)
#' )
#'
#' df_el <- data.frame(Si = 46.75, Fe = 5.15)
#' element_to_oxide(df_el, conv, elements = c("Si", "Fe"))
#'
#' df_ox <- data.frame(SiO2 = 100, FeO = 6.62)
#' oxide_to_element(df_ox, conv, oxides = c("SiO2", "FeO"))
#'
#' @name oxide_conversion
NULL


#' @rdname oxide_conversion
#' @export
element_to_oxide <- function(df, conversion_table, elements) {
  out <- df

  for (el in elements) {
    row <- conversion_table[conversion_table$Element == el, ]
    if (nrow(row) == 0) {
      warning("No conversion found for element: ", el, call. = FALSE)
      next
    }


    oxide_name <- row$Oxide[1]
    factor <- row$element_to_oxide[1]

    out[[oxide_name]] <- df[[el]] * factor
  }

  out
}


#' @rdname oxide_conversion
#' @export
oxide_to_element <- function(df, conversion_table, oxides) {
  out <- df

  for (ox in oxides) {
    row <- conversion_table[conversion_table$Oxide == ox, ]
    if (nrow(row) == 0) {
      warning("No conversion found for oxide: ", ox, call. = FALSE)
      next
    }

    element_name <- row$Element[1]
    factor <- row$oxide_to_element[1]

    out[[element_name]] <- df[[ox]] * factor
  }

  out
}
