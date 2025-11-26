#' Copper classification according to Bray et al. (2015)
#'
#' @description Classification of copper artefacts according to Bray et al. (2015) into
#' one of 16 trace element compositional groups based on As, Sb, Ag, or
#' Ni being below or above 0.1 wt%.
#'
#' @references Bray, P., Cuénod, A., Gosden, C., Hommel, P., Liu, P. and
#'   Pollard, A. M. (2015), Form and flow: the ‘karmic cycle’ of copper. Journal
#'   of Archaeological Science 56, pp. 202-209.
#'   <https://doi.org/10.1016/j.jas.2014.12.013>.
#'
#' @param df data frame with the data to be classified.
#' @param elements Named character vector with the column names of the As, Sb, Ag, and Ni concentrations.
#' @param threshold Numeric. Values > threshold are interpreted as "present".
#'   Default is 0.1 (as suggested in Bray et al., 2015).
#'
#' @return The original data frame with the added column `copper_group_bray`.
#'
#' @examples
#' sample_df <- data.frame(
#'   ID = 1:3,
#'   As = c(0.2, 0.01, 0.15),
#'   Sb = c(0.00, 0.2, 0.11),
#'   Ag = c(0.00, 0.00, 0.12),
#'   Ni = c(0.00, 0.05, 0.20)
#' )
#'
#' copper_group_bray(sample_df)
#' copper_group_bray(sample_df, group_as_number = TRUE)
#'
#' @export
copper_group_bray <- function(
  df,
  elements = c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni"),
  id_sample = "ID",
  threshold = 0.1,
  group_as_number = FALSE
) {

  # Build temporary classification table (df stays unchanged)
  temp <- data.frame(
    ID_sample = df[[id_sample]],
    As_flag = df[[elements["As"]]] > threshold,
    Sb_flag = df[[elements["Sb"]]] > threshold,
    Ag_flag = df[[elements["Ag"]]] > threshold,
    Ni_flag = df[[elements["Ni"]]] > threshold
  )

  # Convert flags into a pattern string
  temp$pattern <- apply(
    temp[, c("As_flag", "Sb_flag", "Ag_flag", "Ni_flag")],
    1,
    paste,
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
  out <- merge(temp[, c("ID_sample", "pattern")], lookup, by = "pattern", all.x = TRUE, sort = FALSE)

  # Add correct output column
  if (group_as_number) {
    df$copper_group_bray <- out$group_number[
      match(df[[id_sample]], out$ID_sample)
    ]
  } else {
    df$copper_group_bray <- out$group_name[
      match(df[[id_sample]], out$ID_sample)
    ]
  }

  return(df)
}
