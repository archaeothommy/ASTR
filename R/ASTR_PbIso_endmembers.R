#' Find Endmembers from a list of LIA points
#'
#' @description
#' Finds endmembers from a set of
#' Lead Isotope Points using Principle Component
#' analysis and the Geochron slope according to the two-stage model by
#' Stacy-Kramers 1975, following the process outlined in (Shnyr et al., (2026)
#'
#' @param x ASTR object containing
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope ratios.
#' @param tolerance Vector of length two, with corresponding group 1 and group
#'  2 tolerance value for points considered to be intercepted.
#'      (Default c(0.01, 0.01))
#' @param clamp Limit filter for points away from the principle component end
#' based on Euclidean distance, (Default c(Inf, Inf))
#' @param ... Additional Parameters
#'
#' @references Shnyr, E., Kuflik, T., Desai, K., & Eshel, T. (2026).
#' Determining the origins of Phoenician silver: Exploring the potential of
#' machine learning for lead isotope analysis. Journal of Archaeological
#' Science, 188, 106–499. https://doi.org/10.1016/j.jas.2026.106499
#'
#' @returns
#' An [ASTR object][ASTR], with additional class attribute
#' `ASTR_Pbiso_endmembr`. The output is an object of the
#' same type including the ID column, the contextual columns, the lead isotope
#' ratios used for calculation of the age model parameters,
#' and the endmember groups. In all other cases, the data frame provided as input
#' with columns added for the calculated endmember groups.
#'
#' Endmember groups consist of group1, group2 and groupmix
#' groupmix represents the values along the mixing line.
#'
#' @family Pb isotope functions
#'
#' @export
pb_iso_endmembers <- function(x, ...) {
  UseMethod("pb_iso_endmembers")
}

#' @rdname pb_iso_endmembers
#' @export
#'
#' @examples
#' # example code
#' pb_iso_endmembers(tel_dor)
#'
#' # No clamping
#' no_clamp <- pb_iso_endmembers(tel_dor)
#' no_clamp[no_clamp$end_membr == "group2", ]
#' # Clamping reduces the group size by distance from the principle endmember
#' clamp <- pb_iso_endmembers(tel_dor, clamp = c(Inf, 0.1))
#' clamp[clamp$end_membr == "group2", ]
#' # Reducing tolerance values narrows the grouping around the Geocron
#' pb_iso_endmembers(tel_dor, tolerance = c(0.001, 0.001))
pb_iso_endmembers.ASTR <- function(x,
                                   tolerance = c(0.01, 0.01),
                                   clamp = c(Inf, Inf),
                                   ...) {
  # Main Analysis Function
  calc_pb_iso_endmembers <- function(x, iso_cols, tolerance, clamp, ...) {
    # Subset and convert matrix
    x_iso_mat <- as.matrix(x[, iso_cols])

    if (!is.numeric(x_iso_mat)) {
      stop("Non-numeric values in isotope columns")
    }

    rownames(x_iso_mat) <- seq_len(nrow(x_iso_mat))
    isotope_matrix <- x_iso_mat

    if (nrow(isotope_matrix) < 3) {
      stop("Too few samples. Suggest more than 3.")
    }

    # --- PCA Process ---
    pca_result <- stats::prcomp(isotope_matrix, scale = FALSE)
    pca_values <- pca_result$x
    rownames(pca_values) <- rownames(isotope_matrix)

    pca_summary <- summary(pca_result)
    pc1_var <- pca_summary$importance[["Cumulative Proportion", "PC1"]]

    if (pc1_var < 0.95) {
      message("PC1 represents less than 95% of the Variance. There may be more than two end members.")
      print(pca_summary)
    }

    # Normality tests
    norm_test_pc1 <- stats::shapiro.test(pca_values[, "PC1"])$p.value < 0.95
    norm_test_pc2 <- stats::shapiro.test(pca_values[, "PC2"])$p.value > 0.95
    norm_test_pc3 <- stats::shapiro.test(pca_values[, "PC3"])$p.value > 0.95

    if (!(norm_test_pc1 && norm_test_pc2 && norm_test_pc3)) {
      message(
        "PC2 or PC3 are not normally distributed. This may indicate variation is not random noise."
      )
    }

    # End member extraction
    pca_ends <- pca_values[pca_values[, "PC1"] %in% range(pca_values[, "PC1"]), ]
    isotope_ends <- isotope_matrix[as.numeric(rownames(pca_ends)), ]

    geo_slope <- 0.626208

    end_member_filter <- function(idx, tol, clmp) {
      col_7 <- grep("7", colnames(isotope_ends))
      col_6 <- grep("6", colnames(isotope_ends))

      geo_intercept <- isotope_ends[idx, col_7] - (isotope_ends[idx, col_6] * geo_slope)
      point_intercept <- (geo_slope * isotope_matrix[, col_6]) + geo_intercept
      prob_end <- abs(isotope_matrix[, col_7] - point_intercept) < tol
      geochron_end <- isotope_matrix[prob_end, , drop = FALSE]

      dists <- apply(geochron_end, 1, function(a) {
        end_pt <- isotope_ends[idx, ]
        sqrt(sum((end_pt - a)^2))
      })

      geochron_end[dists < clmp, , drop = FALSE]
    }

    end_group1 <- rownames(end_member_filter(1, tolerance[[1]], clamp[[1]]))
    end_group2 <- rownames(end_member_filter(2, tolerance[[2]], clamp[[2]]))

    if (length(end_group1) < 2 || length(end_group2) < 2) {
      message(
        "End Member group has less than two points. Likelihood of point being an endmember is low."
      )
    }

    if (any(end_group1 %in% end_group2)) {
      warning("Overlap in endmembers between groups. Suggest lower tolerance value.")
    }

    mixing_group <- setdiff(rownames(isotope_matrix), c(end_group1, end_group2))

    # Assign results
    x$end_membr <- NA_character_
    x[end_group1, "end_membr"] <- "group1"
    x[end_group2, "end_membr"] <- "group2"
    x[mixing_group, "end_membr"] <- "groupmix"

    return(x)
  }

  target_cols <- c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
  if (!all(target_cols %in% names(x))) {
    stop("Data set is missing required isotope ratio columns.")
  }

  res <- calc_pb_iso_endmembers(x,
                                iso_cols = target_cols,
                                tolerance = tolerance,
                                clamp = clamp,
                                ...)

  # Assign custom attribute for ASTR method
  attr(res$end_membr, "ASTR_class") <- "ASTR_context"
  class(res) <- c("ASTR_Pbiso_endmembr", class(res))
  return(res)

}
