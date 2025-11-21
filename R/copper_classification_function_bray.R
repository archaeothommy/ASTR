#' Classify copper samples into compositional groups (Bray et al., 2015)
#'
#' @description
#' Classifies copper artefacts into one of the 16 trace-element
#' compositional groups defined by Bray et al., 2015 (Fig. 1),
#' based on the presence/absence of As, Sb, Ag, and Ni.
#'
#' @param df A dataframe containing at least columns: ID, As, Sb, Ag, Ni.
#' @param threshold Numeric. Values > threshold are interpreted as "present".
#' Default is 0.1 (as suggested in Bray et al., 2015).
#'
#' @return The original dataframe with one new column:
#' \code{copper_group_bray}
#'
#' @export
classify_copper_group_bray <- function(df, threshold = 0.1) {
  # Build a temporary classification table
  temp <- data.frame(
    ID = df$ID,
    group = dplyr::case_when(
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
  # Clean column name to publication-specific name
  names(df)[names(df) == "group"] <- "copper_group_bray"
  return(df)
}
