#' Copper alloy classification according to Bayley & Butcher (2004)
#'
#' @description Classification of copper alloy artefacts according to Bayley &
#'   Butcher (2004) based on Zn, Sn, and Pb concentrations in wt%. Concentrations
#'   must be given in wt%. Classification uses specific thresholds and ratios to
#'   define alloy types.
#'
#' @references Bayley, J., & Butcher, S. (2004). Roman brooches in Britain: a
#'   technological and typological study based on the Richborough Collection.
#'   London: Society of Antiquaries of London.
#'
#' @param df data frame with the data to be classified.
#' @param elements named character vector with column names of Zn, Sn, and Pb
#' concentrations.
#' @param id_sample  name of the column in `df` with the identifiers of each
#' row. Default to `ID`.
#'
#' @return Original data frame with added column `copper_alloy_bb`.
#'
#' @examples
#' sample_df <- data.frame(
#'   ID = 1:5,
#'   Sn = c(5, 1, 4, 0.5, 2),
#'   Zn = c(12, 20, 6, 2, 10),
#'   Pb = c(1, 0.5, 5, 9, 12)
#' )
#' copper_alloy_bb(sample_df)
#'
#' @export
#'
copper_alloy_bb <- function(
  df,
  elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
  id_sample = "ID") {

  # to do: check and convert concentrations to wt%

  Sn <- df[[elements["Sn"]]]
  Zn <- df[[elements["Zn"]]]
  Pb <- df[[elements["Pb"]]]

  result <- character(nrow(df))

  # Base alloy classes

  # Copper: Zn < 3 and Sn < 3
  result[Zn < 3 & Sn < 3] <- "Copper"

  # Copper/brass: 3 ≤ Zn < 8 and Sn < 3
  result[Zn >= 3 & Zn < 8 & Sn < 3] <- "Copper/brass"

  # Bronze: Sn ≥ 3 and Zn < 3*Sn
  result[Sn >= 3 & Zn < 3 * Sn] <- "Bronze"

  # Bronze/gunmetal: Sn ≥ 3 and Zn between 0.33*Sn and 0.67*Sn
  result[Sn >= 3 & Zn > 0.33 * Sn & Zn < 0.67 * Sn] <- "Bronze/gunmetal"

  # Gunmetal: Zn > 0.67*Sn and Zn < 2.5*Sn and Sn ≥ 3
  result[Sn >= 3 & Zn > 0.67 * Sn & Zn < 2.5 * Sn] <- "Gunmetal"

  # Brass/gunmetal: Zn > 2.5*Sn and Zn <= 4*Sn AND (Zn ≥ 8 OR Sn ≥ 3)
  result[(Zn >= 8 | Sn >= 3) & Zn > 2.5 * Sn & Zn <= 4 * Sn] <- "Brass/gunmetal"

  # Brass: Zn ≥ 8 and Zn > 4*Sn
  result[Zn >= 8 & Zn > 4 * Sn] <- "Brass"

  # Apply lead modifiers
  # (Leaded): Pb between 4 and 8
  prefix_leaded <- Pb >= 4 & Pb <= 8
  result[prefix_leaded] <- paste("(Leaded)", result[prefix_leaded])

  # Leaded: Pb > 8
  prefix_high_lead <- Pb > 8
  result[prefix_high_lead] <- paste("Leaded", result[prefix_high_lead])

  # Unclassified cells become NA
  result[result == ""] <- NA_character_

  df$copper_alloy_bb <- result
  return(df)
}
