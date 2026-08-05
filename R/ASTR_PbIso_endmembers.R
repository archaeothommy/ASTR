#' Find Endmembers from a list of LIA points
#'
#' @description
#' Finds endmembers from a set of
#' Lead Isotope Points using Principle Component
#' analysis and the Geochron slope according to the two-stage model.
#'
#' @param x data.frame or matrix object containing
#' Pb 206/204, 207/204, 208/204 isotope ratios.
#' @param col Isotope column names containing Pb
#' 206/204, 207/204, 208/204 isotope ratios.
#' Names must contains the significant numbers 6, 7 and 8.
#' @param tolerance Vector of length two, with corresponding group 1 and group
#'  2 tolerance value for points considered to be intercepted.
#'      (Default c(0.01, 0.01))
#' @param clamp Limit filter for points away from the principle component end
#' based on Euclidean distance, (Default c(Inf, Inf))
#' @param ... Additional Parameters
#'
#' @returns
#' If `x` is an [ASTR object][ASTR], the output is an object of the
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
test_pb_iso_endmembers <- function(x,
                                   col = NULL,
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

  # AS
  if (inherits(x, "ASTR")) {
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
    return(res)
  }

  if (!inherits(x, c("data.frame", "matrix"))) {
    stop(deparse(substitute(x)), " is not a dataframe or a matrix")
  }
  if (is.null(col)) {
    stop("Column names needed!")
  }
  if (length(grep("6|7|8", col)) != 3) {
    stop("Incorrect number or names of columns")
  }

  res <- calc_pb_iso_endmembers(x,
                                iso_cols = col,
                                tolerance = tolerance,
                                clamp = clamp,
                                ...)
  return(res)
}
