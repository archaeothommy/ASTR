#' Copper alloy classification according to Pollard et al. (2015).
#'
#' @description Classification of copper alloy artefacts following the system
#'   proposed in Pollard et al. (2015) based Sn, Zn, and Pb concentrations in
#'   wt%.
#'
#' @references Pollard, A. M., Bray, P., Gosden, C., Wilson, A., and Hamerow, H.
#'   (2015). Characterising copper-based metals in Britain in the first
#'   millennium AD: a preliminary quantification of metal flow and recycling.
#'   Antiquity 89(345), pp. 697-713. <https://doi.org/10.15184/aqy.2015.20>
#'
#' @param df data frame with the data to be classified.
#' @param elements named character vector with column names of Sn, Zn, and Pb.
#' @param id_column name of the column in `df` with the identifiers of each row.
#'   Default to `ID`.
#' @param group_as_symbol logical. If `FALSE`, the default, copper groups are
#'   reported as their label. Otherwise, copper groups are reported by their
#'   symbol.
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
#'   ID = 1:8,
#'   Sn = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
#'   Zn = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
#'   Pb = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
#' )
#' copper_alloy_pollard(sample_df)
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
#' copper_alloy_pollard(sample_df, elements = c(Sn = "SnO", Zn = "ZnO", Pb = "PbO"))
#'
#' @export
#'
copper_alloy_pollard <- function(
    df,
    elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
    id_column = "ID",
    group_as_symbol = FALSE,
    ...) {

  # convert units to wt%

  if (inherits(df, "ASTR")) {
    df <- convert_concentration_units(df, elements, "wtP", ...)
    elements <- c(Sn = "Sn", Zn = "Zn", Pb = "Pb") # rename in case input was in oxides
    threshold <- units::set_units(1, "wtP")
  } else {
    threshold <- 1 # wt%, set in Pollard et al. (2015)
  }

  # Build temporary classification table
  flags <- data.frame(
    ID_sample = df[[id_column]],
    Sn_flag = df[[elements["Sn"]]] >= threshold,
    Zn_flag = df[[elements["Zn"]]] >= threshold,
    Pb_flag = df[[elements["Pb"]]] >= threshold
  )

  # Convert flags into a pattern string
  flags$pattern <- apply(
    flags[, c("Sn_flag", "Zn_flag", "Pb_flag")],
    1,
    paste0,
    collapse = ""
  )

  # Lookup table for Table 2 classifications
  lookup <- data.frame(
    pattern = c(
      "FALSEFALSEFALSE",
      "FALSEFALSETRUE",
      "TRUEFALSEFALSE",
      "TRUEFALSETRUE",
      "FALSETRUEFALSE",
      "FALSETRUETRUE",
      "TRUETRUEFALSE",
      "TRUETRUETRUE"
    ),
    alloy_name = c(
      "Copper",
      "Leaded copper",
      "Bronze",
      "Leaded bronze",
      "Brass",
      "Leaded brass",
      "Gunmetal",
      "Leaded gunmetal"
    ),
    alloy_symbol = c("C", "LC", "B", "LB", "BR", "LBR", "G", "LG"),
    stringsAsFactors = FALSE
  )

  # Join with lookup table, preserving row order
  out <- merge(flags[, c("ID_sample", "pattern")],
               lookup,
               by = "pattern",
               all.x = TRUE)

  # Ensure "Unclassified" for any missing matches
  out$alloy_name[is.na(out$alloy_name)] <- "Unclassified"
  out$alloy_symbol[is.na(out$alloy_symbol)] <- "Unclassified"

  # Add correct output column
  if (!group_as_symbol) {
    copper_alloy_pollard <- out$alloy_name[match(df[[id_column]], out$ID_sample)]
  } else {
    copper_alloy_pollard <- out$alloy_symbol[match(df[[id_column]], out$ID_sample)]
  }

  if (inherits(df, "ASTR")) {
    df_out <- df[c(colnames(get_contextual_columns(df)), elements)]
    df_out[["copper_alloy_pollard"]] <- copper_alloy_pollard
    df_out[["copper_alloy_pollard"]] <- add_ASTR_class(df_out[["copper_alloy_pollard"]], "ASTR_context")
  } else {
    df_out <- df
    df_out[["copper_alloy_pollard"]] <- copper_alloy_pollard
  }

  return(df_out)
}
