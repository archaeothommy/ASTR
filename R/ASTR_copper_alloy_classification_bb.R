#' Copper alloy classification according to Bayley & Butcher (2004)
#'
#' @description Classification of copper alloy artefacts according to Bayley &
#'   Butcher (2004) based on Zn, Sn, and Pb concentrations in wt%.
#'   Classification uses specific thresholds and ratios to define alloy types.
#'
#' @references Bayley, J. and Butcher, S. (2004). Roman brooches in Britain: a
#'   technological and typological study based on the Richborough Collection.
#'   London: Society of Antiquaries of London.
#'   <https://doi.org/10.26530/20.500.12657/50365>
#'
#' @param df data frame with the data to be classified.
#' @param elements named character vector with column names of Zn, Sn, and Pb
#'   concentrations.
#' @param id_column  name of the column in `df` with the identifiers of each
#'   row. Default to `ID`.
#' @param ... Additional arguments for unit conversion, see [atomic_conversion]
#'   and [oxide_conversion] for details.
#'
#' @return If `df` is an [ASTR object][ASTR], the output is an object of the
#'   same type including the ID column, the contextual columns, the elements
#'   used for classification and the alloy type. In all other cases, the data
#'   frame provided as input with the column for the alloy type.
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
#' # For ASTR objects, units and oxides are automatically converted
#' sample_df <- as_ASTR(
#'   data.frame(
#'     ID = 1:8,
#'     SnO_wtP = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
#'     ZnO_wtP = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
#'     PbO_wtP = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
#'   )
#' )
#' copper_alloy_bb(sample_df, elements = c(Sn = "SnO", Zn = "ZnO", Pb = "PbO"))
#'
#' @family copper alloy classifications
#' @export
#'
copper_alloy_bb <- function(
    df,
    elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
    id_column = "ID",
    ...) {

  if (inherits(df, "ASTR")) {
    df <- convert_concentration_units(df, elements, "wtP")
    elements <- c(Sn = "Sn", Zn = "Zn", Pb = "Pb") # rename in case input was in oxides
    df_full <- df
    df <- remove_units(df)
  }

  # Create subset with just ID and classification column
  copper_alloy <- data.frame(
    ID_sample = df[[id_column]],
    Sn = df[[elements["Sn"]]],
    Zn = df[[elements["Zn"]]],
    Pb = df[[elements["Pb"]]],
    result = rep("Unclassified", nrow(df)),
    stringsAsFactors = FALSE
  )

  # Base alloy classes

  # Copper: Zn < 3 and Sn < 3
  copper_alloy$result[copper_alloy$Zn < 3 & copper_alloy$Sn < 3] <- "Copper"

  # Copper/brass: 3 ≤ Zn < 8 and Sn < 3
  copper_alloy$result[copper_alloy$Zn >= 3 &
                        copper_alloy$Zn < 8 &
                        copper_alloy$Sn < 3] <- "Copper/brass"

  # Bronze: Sn ≥ 3 and Zn < 3 * Sn
  copper_alloy$result[copper_alloy$Sn >= 3 &
                        copper_alloy$Zn < 3 * copper_alloy$Sn] <- "Bronze"

  # Bronze/gunmetal: Sn ≥ 3 and Zn between 0.33*Sn and 0.67*Sn
  copper_alloy$result[copper_alloy$Sn >= 3 &
                        copper_alloy$Zn > 0.33 * copper_alloy$Sn &
                        copper_alloy$Zn < 0.67 * copper_alloy$Sn] <- "Bronze/gunmetal"

  # Gunmetal: Zn > 0.67*Sn and Zn < 2.5*Sn and Sn ≥ 3
  copper_alloy$result[copper_alloy$Sn >= 3 &
                        copper_alloy$Zn > 0.67 * copper_alloy$Sn &
                        copper_alloy$Zn < 2.5 * copper_alloy$Sn] <- "Gunmetal"

  # Brass/gunmetal: Zn > 2.5*Sn and Zn <= 4*Sn AND (Zn ≥ 8 OR Sn ≥ 3)
  copper_alloy$result[(copper_alloy$Zn >= 8 | copper_alloy$Sn >= 3) &
                        copper_alloy$Zn > 2.5 * copper_alloy$Sn &
                        copper_alloy$Zn <= 4 * copper_alloy$Sn] <- "Brass/gunmetal"

  # Brass: Zn ≥ 8 and Zn > 4*Sn
  copper_alloy$result[copper_alloy$Zn >= 8 &
                        copper_alloy$Zn > 4 * copper_alloy$Sn] <- "Brass"

  # Apply lead modifiers
  ## (Leaded): Pb between 4 and 8
  copper_alloy$result[copper_alloy$Pb >= 4 &
                        copper_alloy$Pb <= 8] <- paste(
    "(Leaded)",
    copper_alloy$result[copper_alloy$Pb >= 4 & copper_alloy$Pb <= 8]
  )

  ## Leaded: Pb > 8
  copper_alloy$result[copper_alloy$Pb > 8] <- paste("Leaded", copper_alloy$result[copper_alloy$Pb > 8])

  # Merge results back to original dataframe by ID
  copper_alloy_bb <- copper_alloy$result[match(df[[id_column]], copper_alloy$ID_sample)]

  if (inherits(df, "ASTR")) {
    df_out <- df_full[c(colnames(get_contextual_columns(df_full)), elements)]
    df_out[["copper_alloy_bb"]] <- copper_alloy_bb
    df_out[["copper_alloy_bb"]] <- add_ASTR_class(df_out[["copper_alloy_bb"]], "ASTR_context")
  } else {
    df_out <- df
    df_out[["copper_alloy_bb"]] <- copper_alloy_bb
  }

  return(df_out)
}
