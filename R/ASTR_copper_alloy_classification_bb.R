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

  # Create subset with just ID and classification column
  copper_alloy <- data.frame(
    ID_sample = df[[id_sample]],
    result = rep("Unclassified", nrow(df)),
    stringsAsFactors = FALSE
  )

  Sn <- df[[elements["Sn"]]]
  Zn <- df[[elements["Zn"]]]
  Pb <- df[[elements["Pb"]]]

  # Identify rows where any element is NA — these stay Unclassified
  na_mask <- is.na(Sn) | is.na(Zn) | is.na(Pb)

  # Base alloy classes
  copper_alloy$result[!na_mask & Zn < 3 & Sn < 3] <- "Copper"
  copper_alloy$result[!na_mask & Zn >= 3 & Zn < 8 & Sn < 3] <- "Copper/brass"
  copper_alloy$result[!na_mask & Sn >= 3 & Zn < 3 * Sn] <- "Bronze"
  copper_alloy$result[!na_mask & Sn >= 3 & Zn > 0.33 * Sn & Zn < 0.67 * Sn] <- "Bronze/gunmetal"
  copper_alloy$result[!na_mask & Sn >= 3 & Zn > 0.67 * Sn & Zn < 2.5 * Sn] <- "Gunmetal"
  copper_alloy$result[!na_mask & (Zn >= 8 | Sn >= 3) & Zn > 2.5 * Sn & Zn <= 4 * Sn] <- "Brass/gunmetal"
  copper_alloy$result[!na_mask & Zn >= 8 & Zn > 4 * Sn] <- "Brass"

  # Apply lead modifiers only to non-NA rows
  prefix_leaded     <- !na_mask & Pb >= 4 & Pb <= 8
  prefix_high_lead  <- !na_mask & Pb > 8

  copper_alloy$result[prefix_leaded]    <- paste("(Leaded)", copper_alloy$result[prefix_leaded])
  copper_alloy$result[prefix_high_lead] <- paste("Leaded",   copper_alloy$result[prefix_high_lead])

  # Merge results back to original dataframe by ID
  df$copper_alloy_bb <- copper_alloy$result[match(df[[id_sample]], copper_alloy$ID_sample)]

  return(df)
}
