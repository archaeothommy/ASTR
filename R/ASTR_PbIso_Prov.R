# Reference Data Function --------------------------------------------------

#' Create Reference data object for LIA endmember distance and probability estimate functions.
#'
#' Data preprocessing and cleaning ensure the reliability and accuracy of provenance analysis.
#' This step results in the removal of all NA values from the selected Isotope tables, and groups.
#' The step also should exclude the groups which have low sample data (in the case of (Shnyr et al., (2026) it was 5).
#'
#' @param x ASTR object containing
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope ratios.
#' @param group Name of the column containing isotope groups as character string.
#' @param min_groupsize Integer value for the minimum number samples in a group. (Default = 5)
#'
#' @returns
#' `ASTR_Pbiso_ref_data` object with Isotope groupings and Isotope columns of
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb.
#'
#' @family Pb isotope functions
#' @export
as_pbiso_ref_data <- function(x, ...){
  UseMethod("as_pbiso_ref_data")
}

#' @rdname as_pbiso_ref_data
#' @export
as_pbiso_ref_data.ASTR <- function(x, group, min_groupsize = 5) {

  iso <- c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
  if(!all(iso %in% names(x))) {
    stop("Reference data as incomplete Isotope names")
  }
  x <- na.omit(x[,c(group, iso)])
  x

  if (!is.null(min_groupsize)) {
    counts <- table(x[[group]])
    valid <- names(counts[counts >= min_groupsize])
    x <- x[x[[group]] %in% valid, ]
  }
  class(x) <- c("ASTR_Pbiso_ref_data", class(x))
  x
}


# Distance Functions ------------------------------------------------------

#' Euclidean Distance for Pb Isotope rations to ore Sources
#'
#' Calculate the euclidean distance of each isotope sample to a reference dataset,
#' and gives the closest regions to the groups.
#' Mass-fractionation follows the procedure outlined in Albarede et.al (2024)
#'
#' @param x ASTR object containing
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope ratios for analysis.
#' @param ref ASTR object containing
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope ratios as provenance refrence.
#' @param ref_group Name of the column containing isotope
#' groups as character string.
#' @param dist_type Distance type to use, simple euclidean ('ed') or
#' mass-fractionation corrected ('mfd')
#' @param .n Length of result output (Default = 1)
#' @param s Mass-fractionation factor (Default = 0.001)
#' @param ... Additional params
#'
#'
#' @references Albarede, F., Davis, G., Blichert-Toft, J., Gentelli, L., Gitler, H., Pinto, M., & Telouk, P. (2024).
#' A new algorithm for using Pb isotopes to determine the provenance of bullion in ancient Greek coinage.
#' Journal of Archaeological Science, 163, 105919. https://doi.org/10.1016/j.jas.2023.105919
#'
#' @returns List of data frame or character vector
#' @inherit pb_iso_endmembers examples
#'
#' @family Pb isotope functions
#' @export
pb_iso_prov_dist <- function(x, ...){
  UseMethod("pb_iso_prov_dist")
}

#' @rdname pb_iso_prov_dist
#' @export
pb_iso_prov_dist.ASTR <- function(x,
                                  ref,
                                  ref_group,
                                  dist_type = c("ed", "mf", "all"),
                                  .n = 1,
                                  s = 0.001,
                                  ...) {

  switch(
    dist_type,
    ed = euc_dist(x, ref, ref_group, .n),
    mf = mf_dist(x, ref, ref_group, .n, s),
    all = {
      euc <- euc_dist(x, ref, ref_group, .n)
      mfd <- mf_dist(x, ref, ref_group, .n, s)
      full_join(euc, mfd)
    }
  )

}

#' @rdname pb_iso_prov_dist
#' @export
euc_dist <- function(x, ...) {
  UseMethod("euc_dist")
}

#' @rdname pb_iso_prov_dist
#' @export
euc_dist.ASTR <- function(x, ref, ref_group, .n = 1, ...) {
  if (!inherits(ref, "ASTR")) {
    stop("ref must be of class ASTR")
  }
  ref <- as_pbiso_ref_data(ref, ref_group, ...)
  x_iso <- x[, c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")]
  x_mat <- as.matrix(x_iso)
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
    names(match_ref) <- paste0("ed_ref_", names(match_ref))

    out <- cbind(query_vals[rep(1, .n), drop = FALSE], dist = row_dists[hits_indices], match_ref)

    return(out)
  })
  final_df <- do.call(rbind, results_list) %>%
    select("ed_dist" = dist, everything())
  attr(final_df$ed_dist, "ASTR_class") <- "ASTR_context"
  # final_df <- final_df[order(final_df$dist), ]
  # rownames(final_df) <- NULL
  # return(final_df)
  left_join(x, final_df)
}

#' @rdname pb_iso_prov_dist
#' @export
mf_dist <- function(x, ...) {
  UseMethod("mf_dist")
}

#' @rdname pb_iso_prov_dist
#' @export
mf_dist.ASTR <- function(x, ref, ref_group, .n = 1, s = 0.001, ...) {

  if (!inherits(ref, "ASTR")) {
    stop("ref must be of class ASTR")
  }
  ref <- as_pbiso_ref_data(ref, ref_group, ...)

  x_iso <- x[, c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")]

  x_df <- as.data.frame(x_iso)
  x_mat <- as.matrix(x_iso)
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
    names(match_ref) <- paste0("mf_ref_", names(match_ref))

    # Combine: Query | Distance | Match Metadata & Values
    out <- cbind(
      query_vals[rep(1, .n), , drop = FALSE],
      mf_dist_sq = d_sq[hit_indices],
      match_ref)



    return(out)
  })

  # Finalize
  final_df <- do.call(rbind, results_list)
  attr(final_df$mf_dist_sq, "ASTR_class") <- "ASTR_context"
  # final_df <- final_df[order(final_df$dist), ]
  left_join(x, final_df)
}


# ML model Training function ----------------------------------------------

#' Train XGBOOST Model
#'
#' Trains XGBOOST model for predictive isotope analysis using DBSCAN clustering.
#' SMOTE data imputation for training data set, and XGBOOST, following the method
#' of Shnyr et.al (2026)
#'
#' @references Shnyr, E., Kuflik, T., Desai, K., & Eshel, T. (2026).
#' Determining the origins of Phonetician silver: Exploring the potential of machine learning for lead isotope analysis.
#' Journal of Archaeological Science, 188, 106–499. https://doi.org/10.1016/j.jas.2026.106499
#'
#' @param ref `ref.data` object created by ref_data.
#' @param .minSize Minimum number of samples in group to be used for clustering (Default = 20).
#' @param .minPts_fac scaling factor minimum needed points from each group,
#' ranging from 0:1. (Default = 0.1)
#' @param .eps size (radius) of the epsilon neighbourhood. (Default = 0.18)
#' @param .eta Step size shrinkage used in update to prevent over fitting.
#' After each boosting step, we can directly get the weights of new features,
#' and eta shrinks the feature weights to make the boosting process more conservative. (Default = 0.1)
#' @param .max_depth Maximum depth of a tree.
#' Increasing this value will make the model more complex and more likely to over fit.
#' 0 indicates no limit on depth. Beware that XGBoost aggressively consumes memory when training a deep tree.
#' "exact" tree method requires non-zero value. (Default = 6)
#' @param .nrounds Max number of boosting iterations. (Default = 100)
#' @param nthread Number of threads for parallel processing. When choosing it,
#' please keep thread contention and hyper threading in mind. (Default = 4)
#' @inheritDotParams dbscan::dbscan weights border Points
#' @inheritDotParams xgboost::xgb.train early_stopping_rounds maximize
#'
#' @returns
#' List of xgboot.model objects.
#'
#' @details
#'
#' The Machine learning workflow as descrived by (Shnyr et al., 2026)
#' for data prepraation, clustering, class balanceing, classifications are dissucussed here.
#'
#' @inherit as.ref_data description
#'
#' @section DBSCAN clustering and outlier identification:
#'Density-Based Spatial Clustering of Applications with Noise (DBSCAN)
#'algorithm to identify outliers and subgroup patterns. This method facilitated
#'outlier removal and cluster formation within lead isotopic data, effectively
#'reducing inter-regional overlaps. Systematic evaluation of the neighborhood
#'radius (eps) utilized the Silhouette Score and Davies–Bouldin Index. The
#'optimal parameter, eps = 0.18, yielded a Silhouette Score of 0.691 and a
#'Davies–Bouldin Index of 0.347. This result indicates the formation of
#'well-separated, compact clusters. The minimum points parameter (minPts) was
#'dynamically established at 10\% of the total samples per region. This
#'strategy adapts the density threshold to varying sample sizes, adhering to
#'established proportional scaling practices. To ensure reliability, analysis
#'was restricted to regions with >= 20 samples. This constraint successfully
#'minimized noise-related bias. Finally, regions forming multiple clusters
#'received systematic labels, while single-cluster regions remained unassigned.
#'
#' @section SMOTE application:
#'
#' The Synthetic Minority Over-sampling Technique (SMOTE) generates synthetic
#' data points for the minority class through interpolation. This process
#' balances class distribution and enhances learning by introducing variety
#' while reducing overfitting risks. This study transformed the dataset into a
#' binary classification problem. Synthetic sample counts were dynamically
#' adjusted based on minority cluster density to maintain appropriate balance.
#' This step mitigated class imbalance, preventing predictive bias and
#' improving classifier performance.
#'
#' @section XGBoost Model training:
#' XGBoost algorithm was used to train a binary classification model using
#' three isotopic ratios as input features. The regional cluster names derived
#' from DBSCAN served as target labels. The re sampled dataset was partitioned
#' into training and testing sets, treating each cluster as an independent
#' classification problem. This iterative process involved data encoding, SMOTE
#' application, and individual XGBoost model training for every cluster. Final
#' results demonstrate varying probabilities for potential clusters as the
#' definitive source for the sample group.
#'
#' @inherit pb_iso_endmembers references examples
#'
#' @family Pb isotope functions
#' @export
pb_iso_train_data <- function(ref, ...){
  UseMethod("pb_iso_train_data")
}

#' @rdname pb_iso_train_data
#' @export
pb_iso_train_data.ASTR_Pbiso_ref_data <- function(ref,
                                                  .minSize = 20,
                                                  .minPts_fac = 0.1,
                                                  .eps = 0.18,
                                                  .eta = 0.1,
                                                  .max_depth = 6,
                                                  .nrounds = 100,
                                                  nthread = 4L,
                                                  ...) {
  helper_train_function(
    ref = ref,
    .minSize = .minSize,
    .minPts_fac = .minPts_fac,
    .eps = .eps,
    .eta = .eta,
    .max_depth = .max_depth,
    .nrounds = .nrounds,
    nthread = nthread,
    ...
  )
}
#' @rdname pb_iso_train_data
#' @export
pb_iso_train_data.ASTR <- function(ref,
                                   ref_group,
                                   min_groupsize = 5,
                                   .minSize = 20,
                                   .minPts_fac = 0.1,
                                   .eps = 0.18,
                                   .eta = 0.1,
                                   .max_depth = 6,
                                   .nrounds = 100,
                                   nthread = 4L,
                                   ...) {

  # Format reference data using the helper
  ref <- as_pbiso_ref_data(ref, ref_group, min_groupsize = min_groupsize, ...)

  # Pass arguments explicitly by name to avoid positional shifting
  helper_train_function(
    ref = ref,
    .minSize = .minSize,
    .minPts_fac = .minPts_fac,
    .eps = .eps,
    .eta = .eta,
    .max_depth = .max_depth,
    .nrounds = .nrounds,
    nthread = nthread,
    ...
  )
}

# Helper function
helper_train_function <- function(ref,
                                  .minSize = 20,
                                  .minPts_fac = 0.1,
                                  .eps = 0.18,
                                  .eta = 0.1,
                                  .max_depth = 6,
                                  .nrounds = 100,
                                  nthread = 4L,
                                  ...

) {
  # Package Check -----------------------------------------------------------

  if (!requireNamespace("dbscan")) {

    if (!rlang::is_interactive()) {
      stop("Function requires the package `dbscan`.")
    }

    answer <- readline("Package `dbscan` required to import Excel files.
                       Do you want to install it now? [Y/n]: ")

    if (tolower(answer) %in% c("yes", "y")) {
      utils::install.packages("dbscan")
    } else {
      stop("Please install 'dbscan' manually.")
    }
  }

  if (!requireNamespace("smotefamily")) {

    if (!rlang::is_interactive()) {
      stop("Function requires the package `smotefamily`.")
    }

    answer <- readline("Package `smotefamily` required.
                       Do you want to install it now? [Y/n]: ")

    if (tolower(answer) %in% c("yes", "y")) {
      utils::install.packages("smotefamily")
    } else {
      stop("Please install 'smotefamily' manually.")
    }
  }

  if (!requireNamespace("xgboost")) {

    if (!rlang::is_interactive()) {
      stop("Function requires the package `xgboost`.")
    }

    answer <- readline("Package `xgboost` required.
                       Do you want to install it now? [Y/n]: ")

    if (tolower(answer) %in% c("yes", "y")) {
      utils::install.packages("xgboost")
    } else {
      stop("Please install 'xgboost' manually.")
    }
  }

  ox <- ref
  uni_groups <- unique(ox[[1]])

  # DBSCAN ------------------------------------------------------------------
  dbscan_groups <- function(g_name) {
    if (!.minPts_fac > 0 && !.minPts_fac < 1) {
      stop(".minPts_fac should be bettwee 0 or 1")
    }
    group_df <- ox[ox[[1]] == g_name, ]

    if (nrow(group_df) < .minSize) {
      return(group_df)
    }
    minPts <- nrow(group_df) * .minPts_fac
    res <- dbscan::dbscan(group_df[, -1], minPts = minPts, eps = .eps, ...)
    cluster <- res$cluster
    group_df <- group_df[cluster > 0, ]
    cluster_s <- cluster[cluster > 0]
    if (sum(cluster_s) <= 0) {
      return(NULL)
    }
    if (length(unique(cluster_s)) > 1) {
      group_df[[1]] <- paste0(group_df[[1]], "_", cluster_s)
    }
    return(group_df)

  }
  dbscan_df <- do.call(rbind, lapply(uni_groups, dbscan_groups))
  # SMOTE (Multi-class handling) --------------------------------------------
  subgroups <- unique(dbscan_df[[1]])
  apply_smote <- function(target_subgroup) {
    temp_df <- dbscan_df
    temp_df$target <- ifelse(temp_df[[1]] == target_subgroup, "p", "n")

    p_count <- sum(temp_df$target == "p")

    # SMOTE requires at least K+1 samples in the minority class
    if (p_count < 3)
      return(NULL)

    k_val <- min(2, p_count - 1)

    smote_out <- smotefamily::SMOTE(temp_df[, 2:4], target = temp_df$target, K = k_val)

    final_df <- rbind(smote_out$orig_P, smote_out$syn_data)
    final_df$group <- target_subgroup
    final_df
  }
  smote_df_final <- do.call(rbind, lapply(subgroups, apply_smote))
  # XGBOOST Implementation --------------------------------------------------
  # Define a function to train a binary model for a specific group
  train_group_model <- function(target_group, data = smote_df_final) {
    # Create binary labels: 1 if target_group, 0 otherwise
    labels <- ifelse(data$group == target_group, 1, 0)

    # Check if we have both classes represented
    if (length(unique(labels)) < 2) {
      warning(paste(
        "Skipping group",
        target_group,
        "- no negative samples available."
      ))
      return(NULL)
    }

    X_train <- as.matrix(data[, 1:3])
    dtrain <- xgboost::xgb.DMatrix(data = X_train, label = labels)

    # Binary logistic parameters
    params <- list(
      objective = "binary:logistic",
      eta = .eta,
      max_depth = .max_depth,
      nthread = nthread,
      eval_metric = "logloss",
      # scale_pos_weight can help if your group is much smaller than the rest
      scale_pos_weight = sum(labels == 0) / sum(labels == 1)
    )

    model <- xgboost::xgb.train(params = params,
                                data = dtrain,
                                nrounds = .nrounds,
                                ...)

    return(model)
  }
  list <- setNames(lapply(subgroups, train_group_model), subgroups)
}


# XGBOOST Prediction ------------------------------------------------------

#' Predict Isotope Provenance
#'
#' Predicts Pb Isotope provenance of a sample matrix in reference to a xgboost trained list
#'
#' @param x Matrix of `pbisoendmembers` object of pbisotope samples
#' @param model_list Model list generated by `train_data()`
#' @param .probablity Probability between 0 and 1 of a Guess being correct. (Default = 0.95)
#'
#' @returns
#' data.frame object or list of data.frames
#' @seealso train_data
#' @export
pb_iso_prov_predict <- function(x, ...) {
UseMethod("pb_iso_prov_predict")
}

#' @rdname pb_iso_prov_predict
#' @export
pb_iso_prov_predict.ASTR <- function(x,
                                     model_list = NULL,
                                     .top = 1) {

  target_cols <- c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
  if (!all(target_cols %in% names(x))) {
    stop("Data set is missing required isotope ratio columns.")
  }

  if (is.null(model_list) || length(model_list) == 0) {
    stop("model_list is NULL or empty.")
  }

  # Extract feature matrix
  x_iso <- x[, target_cols, drop = FALSE]
  dtest <- xgboost::xgb.DMatrix(as.matrix(x_iso))

  # 1. Generate probability matrix (Rows = Samples, Cols = Models)
  prob_list <- lapply(names(model_list), function(m_name) {
    m <- model_list[[m_name]]
    if (is.null(m)) return(NULL)
    predict(m, dtest)
  })

  # Remove NULL models and bind into matrix
  valid_models <- names(model_list)[!sapply(prob_list, is.null)]
  prob_matrix <- do.call(cbind, prob_list[!sapply(prob_list, is.null)])
  colnames(prob_matrix) <- valid_models

  # 2. Extract Top K Groups Per Row
  results <- lapply(seq_len(nrow(prob_matrix)), function(i) {
    row_probs <- prob_matrix[i, ]

    # Get indices of top N probabilities for row i
    top_idx <- order(row_probs, decreasing = TRUE)[seq_len(min(.top, length(row_probs)))]

    data.frame(
      row_id = i,
      ml_group = names(row_probs)[top_idx],
      ml_prob = as.numeric(row_probs[top_idx]),
      stringsAsFactors = FALSE
    )
  })

  pred_df <- do.call(rbind, results)

  # Optional: Bind predictions back to the original dataset 'x'
  # return(cbind(x[pred_df$row_id, ], pred_df[, c("group", "prob")]))

  x_temp <- x
  x_temp$row_id <- seq_len(nrow(x_temp))

  res <- left_join(x_temp, pred_df, by = join_by("row_id")) %>%
    select(-row_id)

  attr(res$ml_group, "ASTR_class") <- "ASTR_context"
  attr(res$ml_prob, "ASTR_class") <- "ASTR_context"
  return(res)
}

