#' AMALIA algorithm for matching of sample and reference lead isotope data
#'
#' @description Implements the AMALIA (A Matching Algorithm for Lead Isotope
#'   Analyses) algorithm as described in Rodríguez et al. (2023). For each
#'   sample, the algorithm identifies analytically identical reference data by
#'   comparing lead isotope ratios within their combined analytical
#'   uncertainties across three independent isotope ratio dimensions.
#'
#' @details For each sample-reference pair, AMALIA checks whether the absolute
#'   difference between their isotope ratios is smaller than or equal to the
#'   combined analytical uncertainty (sum of both 2SD errors) for all three
#'   ratios in the selected triplet simultaneously.
#'
#'   When `triplet = "both"`, only pairs that pass in both the 204Pb and 206Pb
#'   triplet spaces are returned, following the strict application recommended
#'   by Rodríguez et al. (2023).
#'
#' @param df Data frame with sample data including isotope ratios, their
#'   analytical errors and an ID column.
#' @param ref Data frame with reference data including isotope ratios, their
#'   analytical errors and an ID column. Must have the same column names as
#'   `df`.
#' @param ratios_204 Character vector of length 3 with column names of the
#'   204Pb-normalised isotope ratios. Must be identical in `df` and `ref`.
#'   Default to `c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")`.
#' @param ratios_206 Character vector of length 3 with column names of the
#'   206Pb-normalised isotope ratios. Must be identical in `df` and `ref`. Only
#'   used when `triplet = "206"` or `triplet = "both"`. Default to
#'   `c("206Pb/204Pb", "207Pb/206Pb", "208Pb/206Pb")`.
#' @param error_204 Character vector of length 3 with column names of the
#'   analytical uncertainty in 2SD for the 204Pb-normalised ratios. Must be
#'   identical in both `df` and `ref`. Default to `c("206Pb/204Pb_err2SD",
#'   "207Pb/204Pb_err2SD", "208Pb/204Pb_err2SD")`.
#' @param error_206 Character vector of length 3 with column names of the
#'   analytical uncertainty (2SD) for the 206Pb-normalised ratios. Must be
#'   identical in both `df` and `ref`. Only used when `triplet = "206"` or
#'   `triplet = "both"`. Default to `c("206Pb/204Pb_err2SD",
#'   "207Pb/206Pb_err2SD", "208Pb/206Pb_err2SD")`.
#' @param id_sample String with the column name of the sample IDs in `df`.
#'   Default is `"ID"`.
#' @param id_ref String with the column name of the reference groups in `ref`.
#'   Default is `"ID"`.
#' @param triplet Character string specifying which isotope ratio triplet to use
#'   for matching. One of `"204"` (206/204, 207/204, 208/204), `"206"` (206/204,
#'   207/206, 208/206), or `"both"` (a match must pass both triplets
#'   simultaneously, following Rodríguez et al. 2023). Default is `"204"`.
#'
#' @return A list of three elements:
#'
#' * `summary_matches`: Data frame with with the number of reference
#'   matches per sample.
#' * `matches`: Data frame with every sample-reference pair that passed the
#'   AMALIA matching criteria, with their absolute differences per ratio.
#' * `unmatched`: character vector. IDs of samples with no matches in the
#'   reference data.
#'
#' @references Rodríguez, J., Sinner, A.G., Martínez-Chico, D. and Santos
#'   Zalduegui, J.F. (2023). AMALIA, A Matching Algorithm for Lead Isotope
#'   Analyses: Formulation and proof of concept at the Roman foundry of Fuente
#'   Spitz (Jaén, Spain). Journal of Archaeological Science: Reports 51, 104192.
#'   <https://doi.org/10.1016/j.jasrep.2023.104192>
#'
#' @export
#'
#' @examples
#' df <- data.frame(
#'   ID = c("Art1", "Art2", "Art3"),
#'   `206Pb/204Pb` = c(18.244, 18.419, 18.050),
#'   `207Pb/204Pb` = c(15.634, 15.658, 15.620),
#'   `208Pb/204Pb` = c(38.407, 38.638, 38.157),
#'   `206Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
#'   `207Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
#'   `208Pb/204Pb_err2SD` = c(0.002, 0.002, 0.002),
#'   `204Pb/206Pb` = c(0.0537, 0.0539, 0.0554),
#'   `207Pb/206Pb` = c(0.857, 0.850, 0.865),
#'   `208Pb/206Pb` = c(2.105, 2.098, 2.114),
#'   `204Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
#'   `207Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
#'   `208Pb/206Pb_err2SD` = c(0.00004, 0.00004, 0.00004),
#'   check.names = FALSE
#' )
#'
#' ref <- data.frame(
#'   ID = c("Ore_A", "Ore_B", "Ore_C"),
#'   `206Pb/204Pb` = c(18.242, 18.500, 18.048),
#'   `207Pb/204Pb` = c(15.633, 15.700, 15.619),
#'   `208Pb/204Pb` = c(38.405, 38.800, 38.155),
#'   `206Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
#'   `207Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
#'   `208Pb/204Pb_err2SD` = c(0.002, 0.002, 0.002),
#'   `204Pb/206Pb` = c(0.0543, 0.0543, 0.0543),
#'   `207Pb/206Pb` = c(0.857, 0.850, 0.865),
#'   `208Pb/206Pb` = c(2.105, 2.098, 2.114),
#'   `204Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
#'   `207Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
#'   `208Pb/206Pb_err2SD` = c(0.00004, 0.00004, 0.00004),
#'   check.names = FALSE
#' )
#'
#' amalia(df, ref)
#'
amalia <- function(
  df,
  ref,
  ratios_204 = c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb"),
  ratios_206 = c("204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb"),
  error_204 = c("206Pb/204Pb_err2SD", "207Pb/204Pb_err2SD", "208Pb/204Pb_err2SD"),
  error_206 = c("204Pb/206Pb_err2SD", "207Pb/206Pb_err2SD", "208Pb/206Pb_err2SD"),
  id_sample = "ID",
  id_ref = "ID",
  triplet = c("204Pb", "206Pb", "both")
) {

  triplet <- match.arg(triplet)

  # Input validation
  checkmate::assert_data_frame(df)
  checkmate::assert_data_frame(ref)
  checkmate::assert_string(id_sample)
  checkmate::assert_string(id_ref)

  if (!(id_sample %in% names(df))) {
    stop("Sample ID column '", id_sample, "' not found in sample data.")
  }
  if (!(id_ref %in% names(ref))) {
    stop("Reference ID column '", id_ref, "' not found in reference data.")
  }

  # Validate only the columns required by the selected triplet
  if (triplet == "204Pb" || triplet == "both") {
    checkmate::assert_character(ratios_204, len = 3)
    checkmate::assert_character(error_204, len = 3)
    checkmate::assert_subset(ratios_204, names(df))
    checkmate::assert_subset(ratios_204, names(ref))
    checkmate::assert_subset(error_204, names(df))
    checkmate::assert_subset(error_204, names(ref))
  }

  if (triplet == "206Pb" || triplet == "both") {
    checkmate::assert_character(ratios_206, len = 3)
    checkmate::assert_character(error_206, len = 3)
    checkmate::assert_subset(ratios_206, names(df))
    checkmate::assert_subset(ratios_206, names(ref))
    checkmate::assert_subset(error_206, names(df))
    checkmate::assert_subset(error_206, names(ref))
  }

  # Select ratios and errors based on triplet
  if (triplet == "204Pb") {
    ratios <- ratios_204
    errors <- error_204
  } else if (triplet == "206Pb") {
    ratios <- ratios_206
    errors <- error_206
  } else { # "both"
    ratios <- c(ratios_204, ratios_206)
    errors <- c(error_204, error_206)
  }

  # Run matching
  matches <- amalia_match_pairs(
    df = df,
    ref = ref,
    ratios = ratios,
    errors = errors,
    id_sample = id_sample,
    id_ref = id_ref
  )

  # Summary: number of matches per sample
  all_ids <- df[[id_sample]]
  n_tab <- table(matches$sample_id)
  summary_matches <- data.frame(
    sample_id = all_ids,
    n_matches = ifelse(
      all_ids %in% names(n_tab),
      as.integer(n_tab[as.character(all_ids)]),
      0L
    )
  )

  # Unmatched samples
  unmatched <- as.character(
    summary_matches$sample_id[summary_matches$n_matches == 0]
  )

  if (length(unmatched) > 0) {
    message(
      length(unmatched), " sample(s) without matches: ",
      paste(unmatched, collapse = ", ")
    )
  }

  list(
    summary_matches = summary_matches,
    matches = matches,
    unmatched = unmatched
  )
}


#' Match all sample-reference pairs against combined analytical uncertainty
#'
#' @description Internal function used by [amalia()] to generate all possible
#'   sample-reference combinations and check whether their isotope ratio
#'   differences fall within the combined analytical uncertainty for all
#'   supplied ratios simultaneously.
#'
#' @param df Data frame with sample data.
#' @param ref Data frame with reference data.
#' @param ratios Character vector of isotope ratio column names to check.
#' @param errors Character vector of analytical error column names corresponding
#'   to `ratios`.
#' @param id_sample String with the column name of the sample IDs in `df`.
#' @param id_ref String with the column name of the reference groups in `ref`.
#'
#' @return A data frame of matched sample-reference pairs. Returns an empty
#'   data frame if no matches are found.
#'
#' @keywords internal
#'
amalia_match_pairs <- function(df, ref, ratios, errors, id_sample, id_ref) {

  # Generate all possible sample-reference index combinations
  pairs <- expand.grid(
    i = seq_len(nrow(df)),
    j = seq_len(nrow(ref))
  )

  # Check all ratios for every pair simultaneously
  is_match <- mapply(
    function(i, j) {
      s_ratios <- as.numeric(df[i, ratios])
      s_errors <- as.numeric(df[i, errors])
      r_ratios <- as.numeric(ref[j, ratios])
      r_errors <- as.numeric(ref[j, errors])
      au <- s_errors + r_errors
      diff <- abs(s_ratios - r_ratios)
      all(diff <= au)
    },
    pairs$i,
    pairs$j
  )

  matched <- pairs[is_match, ]

  if (nrow(matched) == 0) return(data.frame())

  data.frame(
    sample_id = df[[id_sample]][matched$i],
    ref_id = ref[[id_ref]][matched$j],
    stringsAsFactors = FALSE
  )
}
