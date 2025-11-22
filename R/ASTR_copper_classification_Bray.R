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
#' @export
copper_group_bray <- function(df, elements = c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni"), threshold = 0.1) {
  # Build a temporary classification table
  temp <- data.frame(
    ID = df$ID,
    copper_group_bray = dplyr::case_when(
      df$As <= threshold & df$Sb <= threshold & df$Ag <= threshold & df$Ni <= threshold ~ "None",
      df$As > threshold & df$Sb <= threshold & df$Ag <= threshold & df$Ni <= threshold ~ "As",
      df$As <= threshold & df$Sb > threshold & df$Ag <= threshold & df$Ni <= threshold ~ "Sb",
      df$As <= threshold & df$Sb <= threshold & df$Ag > threshold & df$Ni <= threshold ~ "Ag",
      df$As <= threshold & df$Sb <= threshold & df$Ag <= threshold & df$Ni > threshold ~ "Ni",
      df$As > threshold & df$Sb > threshold & df$Ag <= threshold & df$Ni <= threshold ~ "As+Sb",
      df$As > threshold & df$Sb <= threshold & df$Ag > threshold & df$Ni <= threshold ~ "As+Ag",
      df$As > threshold & df$Sb <= threshold & df$Ag <= threshold & df$Ni > threshold ~ "As+Ni",
      df$As <= threshold & df$Sb > threshold & df$Ag > threshold & df$Ni <= threshold ~ "Sb+Ag",
      df$As <= threshold & df$Sb > threshold & df$Ag <= threshold & df$Ni > threshold ~ "Sb+Ni",
      df$As <= threshold & df$Sb <= threshold & df$Ag > threshold & df$Ni > threshold ~ "Ag+Ni",
      df$As > threshold & df$Sb > threshold & df$Ag > threshold & df$Ni <= threshold ~ "As+Sb+Ag",
      df$As > threshold & df$Sb > threshold & df$Ag <= threshold & df$Ni > threshold ~ "As+Sb+Ni",
      df$As > threshold & df$Sb <= threshold & df$Ag > threshold & df$Ni > threshold ~ "As+Ag+Ni",
      df$As <= threshold & df$Sb > threshold & df$Ag > threshold & df$Ni > threshold ~ "Sb+Ag+Ni",
      df$As > threshold & df$Sb > threshold & df$Ag > threshold & df$Ni > threshold ~ "As+Sb+Ag+Ni",
      TRUE ~ NA_character_
    )
  )
  # Merge back into the original dataframe without altering it
  df <- dplyr::left_join(df, temp, by = "ID")

  return(df)
}
