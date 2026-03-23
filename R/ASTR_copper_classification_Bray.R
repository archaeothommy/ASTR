#' Copper classification according to Bray et al. (2015)
#'
#' @description Classification of copper artefacts according to Bray et al.
#'   (2015) into one of 16 trace element compositional groups based on As, Sb,
#'   Ag, or Ni being below or above 0.1 wt%.
#'
#' @references Bray, P., Cuénod, A., Gosden, C., Hommel, P., Liu, P. and
#'   Pollard, A. M. (2015), Form and flow: the ‘karmic cycle’ of copper. Journal
#'   of Archaeological Science 56, pp. 202-209.
#'   <https://doi.org/10.1016/j.jas.2014.12.013>.
#'
#' @param df data frame with the data to be classified.
#' @param elements named character vector with the column names of the As, Sb,
#'   Ag, and Ni concentrations.
#' @param id_column name of the column in `df` with the identifiers of each row.
#'   Default to `ID`.
#' @param group_as_number logical. If `FALSE`, the default, copper groups are
#'   reported as their label. Otherwise, copper groups are reported by their
#'   number.
#' @param ... Additional arguments for unit conversion, see [atomic_conversion]
#'   and [oxide_conversion] for details.
#'
#' @return If `df` is an [ASTR object][ASTR], the output is an object of the
#'   same type including the ID column, the contextual columns, the elements
#'   used for classification and the alloy type. In all other cases, the data
#'   frame provided as input with the column for the alloy type.
#'
#' @examples
#' # create dataset
#' sample_df <- data.frame(
#'   ID = 1:3,
#'   As = c(0.2, 0.01, 0.15),
#'   Sb = c(0.00, 0.2, 0.11),
#'   Ag = c(0.00, 0.00, 0.12),
#'   Ni = c(0.00, 0.05, 0.20)
#' )
#' # classify copper groups
#' copper_group_bray(sample_df)
#'
#' # classification with group number as output
#' copper_group_bray(sample_df, group_as_number = TRUE)
#'
#' # For ASTR objects, units and oxides are automatically converted
#' sample_df2 <- as_ASTR(
#'   data.frame(
#'     ID = 1:3,
#'     As2O3_wtP = c(0.2, 0.01, 0.15),
#'     Sb2O3_wtP = c(0.00, 0.2, 0.11),
#'     Ag2O_wtP = c(0.00, 0.00, 0.12),
#'     NiO_wtP = c(0.00, 50, 0.20)
#'   )
#' )
#' copper_group_bray(sample_df2, elements = c(As = "As2O3", Sb = "Sb2O3", Ag = "Ag2O", Ni = "NiO"))
#'
#' @export
#'
copper_group_bray <- function(
    df,
    elements = c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni"),
    id_column = "ID",
    group_as_number = FALSE,
    ...) {

  if (inherits(df, "ASTR")) {
    df <- convert_concentration_units(df, elements, "wtP", ...)
    elements <- c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni") # rename in case input was in oxides
    threshold <- units::set_units(0.1, "wtP")
  } else {
    threshold <- 0.1 # wt%, set in Bray et al. (2015)
  }

  # Build temporary classification table (df stays unchanged)
  flags <- data.frame(
    ID_sample = df[[id_column]],
    As_flag = df[[elements["As"]]] > threshold,
    Sb_flag = df[[elements["Sb"]]] > threshold,
    Ag_flag = df[[elements["Ag"]]] > threshold,
    Ni_flag = df[[elements["Ni"]]] > threshold
  )

  # Convert flags into a pattern string
  flags$pattern <- apply(
    flags[, c("As_flag", "Sb_flag", "Ag_flag", "Ni_flag")],
    1,
    paste0,
    collapse = ""
  )

  # Lookup table (16 Bray groups)
  lookup <- data.frame(
    pattern = c(
      "FALSEFALSEFALSEFALSE",
      "TRUEFALSEFALSEFALSE",
      "FALSETRUEFALSEFALSE",
      "FALSEFALSETRUEFALSE",
      "FALSEFALSEFALSETRUE",
      "TRUETRUEFALSEFALSE",
      "TRUEFALSETRUEFALSE",
      "TRUEFALSEFALSETRUE",
      "FALSETRUETRUEFALSE",
      "FALSETRUEFALSETRUE",
      "FALSEFALSETRUETRUE",
      "TRUETRUETRUEFALSE",
      "TRUETRUEFALSETRUE",
      "TRUEFALSETRUETRUE",
      "FALSETRUETRUETRUE",
      "TRUETRUETRUETRUE"
    ),
    group_number = 1:16,
    group_name = c(
      "Cu",
      "As",
      "Sb",
      "Ag",
      "Ni",
      "As+Sb",
      "As+Ag",
      "As+Ni",
      "Sb+Ag",
      "Sb+Ni",
      "Ag+Ni",
      "As+Sb+Ag",
      "As+Sb+Ni",
      "As+Ag+Ni",
      "Sb+Ag+Ni",
      "As+Sb+Ag+Ni"
    ),
    stringsAsFactors = FALSE
  )

  # Join with lookup table, preserving row order
  out <- merge(flags[, c("ID_sample", "pattern")], lookup, by = "pattern", all.x = TRUE, sort = TRUE)

  # Add correct output column
  if (!group_as_number) {
    copper_group_bray <- out$group_name[match(df[[id_column]], out$ID_sample)]
  } else {
    copper_group_bray <- out$group_number[match(df[[id_column]], out$ID_sample)]
  }

  if (inherits(df, "ASTR")) {
    df_out <- df[c(colnames(get_contextual_columns(df)), elements)]
    df_out[["copper_group_bray"]] <- copper_group_bray
    df_out[["copper_group_bray"]] <- add_ASTR_class(df_out[["copper_group_bray"]], "ASTR_context")
  } else {
    df_out <- df
    df_out[["copper_group_bray"]] <- copper_group_bray
  }

  return(df_out)
}
