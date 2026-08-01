# Euc Dist ----------------------------------------------------------------

euc_dist <- function(x, ref, .n, ...) {
  if (!inherits(ref, "ref.data")) {
    stop("ref must be of class ref.data.")
  }

  x_mat <- as.matrix(x)
  ref_mat <- as.matrix(ref[, -1])

  norm_x <- rowSums(x_mat^2)
  norm_ref <- rowSums(ref_mat^2)
  dot_product <- x_mat %*% t(ref_mat)

  dist_sq <- sweep(sweep(-2 * dot_product, 1, norm_x, "+"), 2, norm_ref, "+")
  dist_matrix <- sqrt(pmax(dist_sq, 0))

  # Process each row of x
  results_list <- lapply(seq_len(nrow(dist_matrix)), function(i) {
    query_vals <- x[i, , drop = FALSE]
    row_dists <- dist_matrix[i, ]
    hits_indices <- order(row_dists)[1:.n] # Get indices of top .n

    match_ref <- ref[hits_indices, ]
    # Rename reference columns to distinguish from query
    names(match_ref) <- paste0("ref_", names(match_ref))

    out <- cbind(query_vals[rep(1, .n), , drop = FALSE], dist = row_dists[hits_indices], match_ref)

    return(out)
  })


  final_df <- do.call(rbind, results_list)
  final_df <- final_df[order(final_df$dist), ]
  # rownames(final_df) <- NULL
  return(final_df)
}


# Mass Frac ---------------------------------------------------------------

mf_dist <- function(x, ref, .n, s, ...) {
  if (!inherits(ref, "ref.data")) {
    stop("ref must be of class ref.data.")
  }

  x_df <- as.data.frame(x)
  x_mat <- as.matrix(x)
  ox_mat <- as.matrix(ref[-1])
  #ref_groups <- ref[[1]]

  # Constant Correlation Matrix R for Pb isotopes
  R <- matrix(c(1, 0.96, 0.94, 0.96, 1, 0.96, 0.94, 0.96, 1),
              nrow = 3,
              byrow = TRUE)

  results_list <- lapply(seq_len(nrow(x_mat)), function(j) {
    x0 <- x_mat[j, ]

    # Geometry Setup
    v <- x0 * c(2, 3, 4)
    n <- v / sqrt(sum(v^2))

    # Weighting Matrix W
    sd_diag <- diag(c(2, 3, 4) * s * x0)
    W <- sd_diag %*% R %*% sd_diag

    # Projection setup (Gram-Schmidt)
    basis1 <- if (abs(n[1]) < 0.9)
      c(1, 0, 0)
    else
      c(0, 1, 0)
    u1 <- basis1 - (sum(basis1 * n)) * n
    u1 <- u1 / sqrt(sum(u1^2))
    u2 <- c(n[2] * u1[3] - n[3] * u1[2], n[3] * u1[1] - n[1] * u1[3], n[1] * u1[2] - n[2] * u1[1])
    P <- cbind(u1, u2)

    # Project W into 2D and invert
    W_p_inv <- solve(t(P) %*% W %*% P)

    # Distance Calculation
    delta_X <- sweep(ox_mat, 2, x0, "-")
    dx_p <- delta_X %*% P
    d_sq <- rowSums((dx_p %*% W_p_inv) * dx_p)

    # Sorting and Data Merging
    # Get indices of the top .n matches for THIS artifact
    hit_indices <- order(d_sq)[1:.n]

    query_vals <- x_df[j, , drop = FALSE]
    match_ref <- ref[hit_indices, ]
    names(match_ref) <- paste0("ref_", names(match_ref))

    # Combine: Query | Distance | Match Metadata & Values
    out <- cbind(query_vals[rep(1, .n), , drop = FALSE], dist_sq = d_sq[hit_indices], match_ref)

    return(out)
  })

  # Finalize
  final_df <- do.call(rbind, results_list)
  final_df <- final_df[order(final_df$dist), ]
  return(final_df)
}

#' Euclidean Distance for Pb Isotope rations to ore Sources
#'
#' Calculate the euclidean distance of each isotope sample to a reference dataset,
#' and gives the closest regions to the groups.
#' Mass-fractionation follows the procedure outlined in Albarede et.al (2024)
#'
#' @param x Matrix, data frame of Pb Isotopes with columns in the order of
#' 206Pb/204Pb, 207Pb/204Pb,208Pb/204Pb or a `pbisoendmembers` object.
#' @param ref `ref.data` object used for Reference analysis.
#' @param .n Length of result output (Default = 1)
#' @param dist_type Distance type to use, simple euclidean ('ed') or
#' mass-fractionation corrected ('mfd')
#' @param s Mass-fractionation factor (Default = 0.001)
#' @param ... Additional params
#'
#' @importFrom utils head stack
#' @references Albarede, F., Davis, G., Blichert-Toft, J., Gentelli, L., Gitler, H., Pinto, M., & Telouk, P. (2024).
#' A new algorithm for using Pb isotopes to determine the provenance of bullion in ancient Greek coinage.
#' Journal of Archaeological Science, 163, 105919. https://doi.org/10.1016/j.jas.2023.105919
#'
#' @returns List of data frame or character vector
#' @inherit pb_iso_endmembers examples
#' @export
isoprov_dist <- function(x,
                         ref,
                         dist_type = stop("Distance type should be Defined 'ed' or 'mfd'"),
                         .n = 1,
                         s = 0.001,
                         ...) {
  dist_type <- match.arg(dist_type, c("ed", "mfd"))
  if (inherits(x, "pbisoendmembers")) {
    target_groups <- x[3:4]
    if (dist_type == "ed") {
      out <- lapply(target_groups, function(grp) {
        euc_dist(grp, ref = ref, .n = .n)
      })
    } else if (dist_type == "mfd") {
      # Specifically for mfd, ensure 's' is explicitly passed
      out <- lapply(target_groups, function(grp) {
        mf_dist(grp,
                ref = ref,
                s = s,
                .n = .n)
      })
    }

    return(out)
  }

  if (dist_type == "ed") {
    out <- euc_dist(x, ref = ref, .n = .n)
  } else if (dist_type == "mfd") {
    out <- mf_dist(x, ref = ref, s = s, .n = .n)
  }
  return(out)


}
