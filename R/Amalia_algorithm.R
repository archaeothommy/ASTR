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
#'   `207Pb/206Pb` = c(0.857, 0.850, 0.865),
#'   `208Pb/206Pb` = c(2.105, 2.098, 2.114),
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
#'   `207Pb/206Pb` = c(0.857, 0.850, 0.865),
#'   `208Pb/206Pb` = c(2.105, 2.098, 2.114),
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
  ratios_206 = c("206Pb/204Pb", "207Pb/206Pb", "208Pb/206Pb"),
  error_204 = c("206Pb/204Pb_err2SD", "207Pb/204Pb_err2SD", "208Pb/204Pb_err2SD"),
  error_206 = c("206Pb/204Pb_err2SD", "207Pb/206Pb_err2SD", "208Pb/206Pb_err2SD"),
  id_sample = "ID",
  id_ref = "ID",
  triplet = c("204Pb", "206Pb", "both")
) {
  triplet <- match.arg(triplet)

  # Input validation
  checkmate::assert_data_frame(df)
  checkmate::assert_data_frame(ref)
  checkmate::assert_character(ratios_204, len = 3)
  checkmate::assert_character(ratios_206, len = 3)
  checkmate::assert_character(error_204, len = 3)
  checkmate::assert_character(error_206, len = 3)
  checkmate::assert_string(id_sample)
  checkmate::assert_string(id_ref)

  if (!(id_sample %in% names(df))) {
    stop("Sample ID column '", id_sample, "' not found in sample data.")
  }
  if (!(id_ref %in% names(ref))) {
    stop("Reference ID column '", id_ref, "' not found in reference data.")
  }

  run_amalia <- function(iso, err) {
    # Create every possible sample-reference combination
    pairs <- expand.grid(
      i = seq_len(nrow(df)),
      j = seq_len(nrow(ref))
    )

    # Check all three ratios for every pair simultaneously
    is_match <- mapply(
      function(i, j) {
        s_ratios <- as.numeric(df[i, iso])
        s_errors <- as.numeric(df[i, err])
        r_ratios <- as.numeric(ref[j, iso])
        r_errors <- as.numeric(ref[j, err])
        au <- s_errors + r_errors
        diff <- abs(s_ratios - r_ratios)
        all(diff <= au)
      },
      pairs$i,
      pairs$j
    )

    # Keep only matching pairs
    matched <- pairs[is_match, ]

    if (nrow(matched) == 0) {
      return(data.frame())
    }

    # Build results from matched pairs
    out <- data.frame(
      sample_id = df[[id_sample]][matched$i],
      ref_id = ref[[id_ref]][matched$j],
      diff_1 = abs(as.numeric(df[matched$i, iso[1]]) -
                     as.numeric(ref[matched$j, iso[1]])),
      diff_2 = abs(as.numeric(df[matched$i, iso[2]]) -
                     as.numeric(ref[matched$j, iso[2]])),
      diff_3 = abs(as.numeric(df[matched$i, iso[3]]) -
                     as.numeric(ref[matched$j, iso[3]])),
      stringsAsFactors = FALSE
    )
    names(out)[3:5] <- paste0("diff_", iso)
    out
  }

  # Run independently per triplet
  matches_204 <- data.frame()
  matches_206 <- data.frame()

  if (triplet == "204Pb" || triplet == "both") {
    matches_204 <- run_amalia(ratios_204, error_204)
  }

  if (triplet == "206Pb" || triplet == "both") {
    matches_206 <- run_amalia(ratios_206, error_206)
  }

  # Combine results
  if (triplet == "204Pb") {
    matches <- matches_204
  }

  if (triplet == "206Pb") {
    matches <- matches_206
  }

  if (triplet == "both") {
    if (nrow(matches_204) == 0 || nrow(matches_206) == 0) {
      matches <- data.frame()
    } else {
      pair_204 <- paste(matches_204$sample_id, matches_204$ref_id)
      pair_206 <- paste(matches_206$sample_id, matches_206$ref_id)
      # Strict intersection — must pass in both triplets
      keep_204 <- pair_204 %in% pair_206
      keep_206 <- pair_206 %in% pair_204
      # Combine diff columns from both triplets for matched pairs
      matches <- cbind(
        matches_204[keep_204, ],
        matches_206[keep_206, 3:5]
      )
    }
  }

  # Summary: number of matches per sample
  all_ids <- df[[id_sample]]

  if (nrow(matches) > 0) {
    n_matches <- as.data.frame(table(matches$sample_id))
    names(n_matches) <- c("sample_id", "n_matches")
    missing <- setdiff(all_ids, n_matches$sample_id)
    if (length(missing) > 0) {
      n_matches <- rbind(
        n_matches,
        data.frame(sample_id = missing, n_matches = 0L)
      )
    }
    n_matches <- n_matches[match(all_ids, n_matches$sample_id), ]
  } else {
    n_matches <- data.frame(
      sample_id = all_ids,
      n_matches = 0L
    )
  }

  # Unmatched samples
  unmatched <- as.character(
    n_matches$sample_id[n_matches$n_matches == 0]
  )

  if (length(unmatched) > 0) {
    message(
      length(unmatched), " sample(s) had no matches: ",
      paste(unmatched, collapse = ", ")
    )
  }

  list(
    summary_matches = n_matches,
    matches = matches,
    unmatched = unmatched
  )
}
