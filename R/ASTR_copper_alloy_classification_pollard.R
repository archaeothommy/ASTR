#' Copper alloy classification according to Pollard et al. (2015).
#'
#' @description Classification of copper alloy artefacts following the new system
#'   proposed in Pollard et al. (2015) based Sn, Zn, and Pb concentrations in wt%.
#'
#' @references Pollard, A. M., Bray, P., Gosden, C., Wilson, A., & Hamerow, H.
#'   (2015). Characterising copper-based metals in Britain in the first
#'   millennium AD: a preliminary quantification of metal flow and recycling.
#'   Antiquity, 89(345), 697-713.
#'
#' @param df data frame with the data to be classified.
#' @param elements named character vector with column names of Sn, Zn, and Pb.
#' @param id_sample name of the column in `df` with the identifiers of each row.
#'   Default to `ID`.
#' @param threshold numeric threshold for element presence. Default is 1%.
#'
#' @return The original data frame with the added column `copper_alloy_Pollard`.
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
#' @export
copper_alloy_pollard <- function(
    df,
    elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
    id_sample = "ID",
    threshold = 1) {

  # to do: check and convert concentrations to wt%

  # Build temporary classification table
  flags <- data.frame(
    ID_sample = df[[id_sample]],
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
    stringsAsFactors = FALSE
  )

  # Join with lookup table, preserving row order
  out <- merge(flags[, c("ID_sample", "pattern")],
               lookup,
               by = "pattern",
               all.x = TRUE)

  # Ensure "Unclassified" for any missing matches
  out$alloy_name[is.na(out$alloy_name)] <- "Unclassified"

  # Add correct output column
  df$copper_alloy_pollard <- out$alloy_name[match(df[[id_sample]], out$ID_sample)]

  return(df)
}
