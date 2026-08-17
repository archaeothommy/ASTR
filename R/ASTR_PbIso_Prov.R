# Helper functions --------------------------------------------------------

# Isotopes relevant for the ASTR schema
.pb_iso_cols <- function() {
  c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
}

# Validate isotope columns
.validate_iso_cols <- function(x) {
  iso <- .pb_iso_cols()
  if (!all(iso %in% names(x))) {
    stop("Dataset is missing required lead isotope columns: ",
         paste(iso, collapse = ", "))
  }
}


# Ensures reference is of type ASTR_Pbiso_ref_data
.ensure_pbiso_ref <- function(ref, ref_group, ...) {
  if (!inherits(ref, "ASTR")) {
    stop("`ref` must be of class 'ASTR'.")
  }
  .validate_iso_cols(ref)
  if (!inherits(ref, "ASTR_Pbiso_ref_data")) {
    ref <- as_pbiso_ref_data(ref, group = ref_group, ...)
  }
  ref
}

# Retags new columns as context
.tag_astr_context <- function(df, cols) {
  for (col in cols) {
    if (col %in% names(df)) {
      attr(df[[col]], "ASTR_class") <- "ASTR_context"
    }
  }
  df
}

# Checks if required packages are installed and prompts for installation if needed
.check_required_packages <- function(pkgs) {
  missing_pkgs <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    if (!rlang::is_interactive()) {
      stop("Function requires package(s): ",
           paste(missing_pkgs, collapse = ", "))
    }
    ans <- readline(sprintf(
      "Package(s) '%s' required. Install now? [Y/n]: ",
      paste(missing_pkgs, collapse = ", ")
    ))
    if (tolower(ans) %in% c("yes", "y")) {
      utils::install.packages(missing_pkgs)
    } else {
      stop("Please install missing package(s) manually.")
    }
  }
}

# Formats distance results
.format_dist_results <- function(x,
                                 ref,
                                 dist_matrix,
                                 dist_col_name,
                                 prefix,
                                 .n) {
  results_list <- lapply(seq_len(nrow(dist_matrix)), function(i) {
    query_vals <- x[i, , drop = FALSE]
    row_dists <- dist_matrix[i, ]
    hit_indices <- order(row_dists)[seq_len(min(.n, length(row_dists)))]

    match_ref <- ref[hit_indices, , drop = FALSE]
    names(match_ref) <- paste0(prefix, "_ref_", names(match_ref))

    out <- cbind(query_vals[rep(1, length(hit_indices)), , drop = FALSE], dist_val = row_dists[hit_indices], match_ref)
    out
  })

  final_df <- do.call(rbind, results_list)
  names(final_df)[names(final_df) == "dist_val"] <- dist_col_name

  final_df <- .tag_astr_context(final_df, dist_col_name)
  dplyr::left_join(x, final_df)
}

# Reference data function --------------------------------------------------

#' Create reference data object for LIA endmember distance and probability
#' estimation functions. Data preprocessing and cleaning ensure the reliability
#' and accuracy of provenance analysis. This step results in the removal of all
#' NA values from the selected isotope tables and groups. The step should also
#' exclude groups with a low number samples (in the case of Shnyr et al. (2026),
#' this was 5).
#'
#' @param x ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope
#'   ratios.
#' @param group Name of the column containing isotope groups as character
#'   string.
#' @param min_groupsize Integer value for the minimum number of samples in a
#'   group, default value is `5`.
#' @param ... Additional parameters
#'
#' @returns `ASTR_Pbiso_ref_data` object with isotope groupings and isotope
#' columns of 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb.

#' @importFrom stats na.omit
#' @family Pb isotope functions
#' @export
#'
#' @examples
#' as_pbiso_ref_data(GlobaLID_ASTR,
#'                   names(GlobaLID_ASTR)[[2]],
#'                   min_groupsize = 5)
#'
as_pbiso_ref_data <- function(x, ...) {
  UseMethod("as_pbiso_ref_data")
}

#' @rdname as_pbiso_ref_data
#' @export
as_pbiso_ref_data.ASTR <- function(x, group, min_groupsize = 5, ...) {
  .validate_iso_cols(x)
  x <- na.omit(x[, c(group, .pb_iso_cols())])

  if (!is.null(min_groupsize)) {
    counts <- table(x[[group]])
    valid <- names(counts[counts >= min_groupsize])
    x <- x[x[[group]] %in% valid, ]
  }
  class(x) <- c("ASTR_Pbiso_ref_data", class(x))
  x
}

# Distance functions ------------------------------------------------------

#' Euclidean distance for Pb isotope ratios to ore sources
#'
#' Calculates the Euclidean distance of each isotope sample to a reference data
#' set and gives the closest regions to the groups. Mass fractionation follows
#' the procedure outlined in Albarede et al. (2024).
#'
#' @param x ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope
#'   ratios for analysis.
#' @param ref ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#'   isotope ratios as a provenance reference.
#' @param ref_group Name of the column containing isotope groups as a character
#'   string.
#' @param dist_type Distance type to use, simple Euclidean (`"ed"`) or
#'   mass-fractionation corrected (`"mfd"`).
#' @param .n Length of result output, default value is `1`.
#' @param s Mass fractionation factor, default value is `0.001`.
#' @param ... Additional parameters.
#'
#'
#' @references Albarede, F., Davis, G., Blichert-Toft, J., Gentelli, L., Gitler,
#'   H., Pinto, M., and Telouk, P. (2024) A new algorithm for using Pb isotopes
#'   to determine the provenance of bullion in ancient Greek coinage. Journal of
#'   Archaeological Science 163, 105919.
#'   <https://doi.org/10.1016/j.jas.2023.105919>
#'
#' @returns ASTR object of matched x, reference, and corresponding distance
#'   values.
#'
#' @inherit pb_iso_endmembers examples
#'
#' @importFrom dplyr full_join
#'
#' @family Pb isotope functions
#' @export
#'
#' @examples
#' GlobaLID_ASTR_ref <- as_pbiso_ref_data(GlobaLID_ASTR,
#'                                    names(GlobaLID_ASTR)[[2]],
#'                                    min_groupsize = 5)
#'
#' # Euclidean distance
#' euc_dist(tel_dor, GlobaLID_ASTR_ref, .n = 1)
#'
#' # Mass fractionation correction
#' mf_dist(tel_dor, GlobaLID_ASTR_ref, .n = 1, s = 0.001)
#'
#' # Wrapper function where the reference data is of class 'ASTR_Pb_iso_ref_data'
#' pb_iso_prov_dist(tel_dor,
#'                  GlobaLID_ASTR,
#'                  ref_group = names(GlobaLID_ASTR)[[2]],
#'                  dist_type = "all")
#'
#' # Wrapper function where reference data is not of class 'ASTR_Pb_iso_ref_data'
#' pb_iso_prov_dist(tel_dor,
#'                  GlobaLID_ASTR_ref,
#'                  dist_type = "all")
#'
pb_iso_prov_dist <- function(x, ...) {
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
  ref <- .ensure_pbiso_ref(ref, ref_group, ...)

  x_mat <- as.matrix(x[, .pb_iso_cols()])
  ref_mat <- as.matrix(ref[, -1])

  norm_x <- rowSums(x_mat^2)
  norm_ref <- rowSums(ref_mat^2)
  dot_product <- x_mat %*% t(ref_mat)

  dist_sq <- sweep(sweep(-2 * dot_product, 1, norm_x, "+"), 2, norm_ref, "+")
  dist_matrix <- sqrt(pmax(dist_sq, 0))

  .format_dist_results(
    x = x,
    ref = ref,
    dist_matrix = dist_matrix,
    dist_col_name = "ed_dist",
    prefix = "ed",
    .n = .n
  )
}

#' @rdname pb_iso_prov_dist
#' @export
mf_dist <- function(x, ...) {
  UseMethod("mf_dist")
}

#' @rdname pb_iso_prov_dist
#' @export
mf_dist.ASTR <- function(x,
                         ref,
                         ref_group,
                         .n = 1,
                         s = 0.001,
                         ...) {

  ref <- .ensure_pbiso_ref(ref, ref_group, ...)

  x_mat <- as.matrix(x[, .pb_iso_cols()])
  ox_mat <- as.matrix(ref[, -1])

  # Constant Correlation Matrix R for Pb isotopes
  R <- matrix(c(1, 0.96, 0.94, 0.96, 1, 0.96, 0.94, 0.96, 1),
              nrow = 3,
              byrow = TRUE)

  dist_matrix <- matrix(NA_real_, nrow = nrow(x_mat), ncol = nrow(ox_mat))

  for (j in seq_len(nrow(x_mat))) {
    x0 <- x_mat[j, ]
    v <- x0 * c(2, 3, 4)
    n <- v / sqrt(sum(v^2))

    sd_diag <- diag(c(2, 3, 4) * s * x0)
    W <- sd_diag %*% R %*% sd_diag

    basis1 <- if (abs(n[1]) < 0.9)
      c(1, 0, 0)
    else
      c(0, 1, 0)
    u1 <- basis1 - (sum(basis1 * n)) * n
    u1 <- u1 / sqrt(sum(u1^2))
    u2 <- c(n[2] * u1[3] - n[3] * u1[2], n[3] * u1[1] - n[1] * u1[3], n[1] * u1[2] - n[2] * u1[1])
    P <- cbind(u1, u2)

    W_p_inv <- solve(t(P) %*% W %*% P)
    delta_X <- sweep(ox_mat, 2, x0, "-")
    dx_p <- delta_X %*% P

    dist_matrix[j, ] <- rowSums((dx_p %*% W_p_inv) * dx_p)
  }

  .format_dist_results(
    x = x,
    ref = ref,
    dist_matrix = dist_matrix,
    dist_col_name = "mf_dist_sq",
    prefix = "mf",
    .n = .n
  )
}

# ML model training function----------------------------------------------

#' Train XGBoost model
#'
#' Trains an XGBoost model for predictive isotope analysis using DBSCAN
#' clustering. SMOTE data imputation for the training data set and XGBoost,
#' following the method of Shnyr et al. (2026).
#'
#' @references Shnyr, E., Kuflik, T., Desai, K., and Eshel, T. (2026)
#'   Determining the origins of Phoenician silver: Exploring the potential of
#'   machine learning for lead isotope analysis. Journal of Archaeological
#'   Science 188, pp. 106–499. <https://doi.org/10.1016/j.jas.2026.106499>
#'
#' @param ref `ASTR` object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb or
#'   `ASTR_Pbiso_ref_data` object.
#' @param ref_group Character string with name of the column containing isotope
#'   groups.
#' @param min_groupsize Integer value for the minimum number of samples in a
#'   group, default value is `5`.
#' @param .minSize Minimum number of samples in group to be used for clustering,
#'   default value is `20`.
#' @param .minPts_fac Scaling factor for the minimum number of points needed
#'   from each group, ranging from 0 to 1, default value is `0.1`.
#' @param .eps Size (radius) of the epsilon neighbourhood, default value is
#'   `0.18`.
#' @param .eta Step size shrinkage used in update to prevent overfitting. After
#'   each boosting step, we can directly get the weights of new features, and
#'   eta shrinks the feature weights to make the boosting process more
#'   conservative. Default value is `0.1`.
#' @param .max_depth Maximum depth of a tree. Increasing this value will make
#'   the model more complex and more likely to overfit. Zero indicates no limit
#'   on depth. Beware that XGBoost aggressively consumes memory when training a
#'   deep tree. "exact" tree method requires non-zero value. Default value is
#'   `6`.
#' @param .nrounds Maximum number of boosting iterations, default value is
#'   `100`.
#' @param nthread Integer setting the number of threads for parallel processing.
#'   When choosing it, please keep thread contention and hyper threading in
#'   mind. Default value is `4L`.
#' @param ... Additional parameters.
#'
#' @inheritDotParams dbscan::dbscan weights borderPoints
#' @inheritDotParams XGBoost::xgb.train early_stopping_rounds maximize
#'
#' @returns List of XGBoost model objects.
#'
#' @details The Machine learning workflow described by Shnyr et al. (2026) for
#'   data preparation, clustering, class balancing, and classification is
#'   discussed here.
#'
#' @inherit as.ref_data description
#'
#' @section *DBSCAN clustering and outlier identification*: The Density-Based
#'   Spatial Clustering of Applications with Noise (DBSCAN) algorithm is used to
#'   identify outliers and subgroup patterns. This method facilitates outlier
#'   removal and cluster formation within lead isotopic data, effectively
#'   reducing inter-regional overlaps. Systematic evaluation of the neighborhood
#'   radius (eps) utilized the Silhouette Score and Davies–Bouldin Index. The
#'   optimal parameter, `eps = 0.18`, yielded a Silhouette Score of 0.691 and a
#'   Davies–Bouldin Index of 0.347. This result indicates the formation of
#'   well-separated, compact clusters. The minimum points parameter (minPts) was
#'   dynamically established at 10% of the total samples per region. This
#'   strategy adapts the density threshold to varying sample sizes, adhering to
#'   established proportional scaling practices. To ensure reliability, analysis
#'   was restricted to regions with ≥ 20 samples. This constraint successfully
#'   minimized noise-related bias. Finally, regions forming multiple clusters
#'   received systematic labels, while single-cluster regions remained
#'   unassigned.
#'
#' @section *SMOTE application*: The Synthetic Minority Over-sampling Technique
#'   (SMOTE) generates synthetic data points for the minority class through
#'   interpolation. This process balances class distribution and enhances
#'   learning by introducing variety while reducing overfitting risks. This
#'   study transformed the data set into a binary classification problem.
#'   Synthetic sample counts were dynamically adjusted based on minority cluster
#'   density to maintain appropriate balance. This step mitigated class
#'   imbalance, preventing predictive bias and improving classifier performance.
#'
#' @section *XGBoost model training*: XGBoost algorithm was used to train a
#'   binary classification model using three isotopic ratios as input features.
#'   The regional cluster names derived from DBSCAN served as target labels. The
#'   resampled data set was partitioned into training and testing sets, treating
#'   each cluster as an independent classification problem. This iterative
#'   process involved data encoding, SMOTE application, and individual XGBoost
#'   model training for every cluster. Final results demonstrate varying
#'   probabilities for potential clusters as the definitive source for the
#'   sample group.
#'
#' @inherit pb_iso_endmembers references examples
#'
#' @family Pb isotope functions
#' @export
#'
pb_iso_train_data <- function(ref, ...) {
  UseMethod("pb_iso_train_data")
}

#' @rdname pb_iso_train_data
#' @export
#'
#' @importFrom stats setNames
#'
#' @examples
#' # Create an 'ASTR_Pbiso_ref_data' object
#' GlobaLID_ASTR_ref <- as_pbiso_ref_data(GlobaLID_ASTR,
#'                   names(GlobaLID_ASTR)[[2]],
#'                   min_groupsize = 5)
#'
#' # Train machine learning model
#' \dontrun{ml_model <- pb_iso_train_data(GlobaLID_ASTR_ref)}
#'
#' # Predict using a pre-trianed model
#' pb_iso_prov_predict(tel_dor, model_list = ml_model, .top = 1)
#'
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
                                  ...) {
  # Package check -----------------------------------------------------------

  .check_required_packages(c("dbscan", "smotefamily", "xgboost"))

  ox <- ref
  uni_groups <- unique(ox[[1]])

  # DBSCAN ------------------------------------------------------------------
  dbscan_groups <- function(g_name) {
    if (.minPts_fac <= 0 || .minPts_fac >= 1) {
      stop(".minPts_fac must be between 0 and 1.")
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

  # XGBOOST implementation --------------------------------------------------

  # Define a function to train a binary model for a specific group
  train_group_model <- function(target_group, data = smote_df_final) {

    # Create binary labels: 1 for target_group, 0 otherwise
    labels <- ifelse(data$group == target_group, 1, 0)

    # Check if both classes are represented
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
      # scale_pos_weight can help if the target group is much smaller than the rest
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

#' Predict isotope provenance
#'
#' Predicts Pb isotope provenance of a sample matrix using a XGBoost trained
#' list
#'
#' @param x Matrix of `pb_iso_endmembers` object of pb isotope samples.
#' @param model_list Model list generated by `train_data()`.
#' @param .top Number of highest probability values considered for final output,
#'   default value is `1`.
#' @param ... Additional parameters.
#'
#' @importFrom stats predict
#'
#' @returns Data frame object or list of data frames.
#' @seealso pb_iso_train_data
#'
#' @family Pb isotope functions
#' @export
pb_iso_prov_predict <- function(x, ...) {
  UseMethod("pb_iso_prov_predict")
}

#' @rdname pb_iso_prov_predict
#' @export
pb_iso_prov_predict.ASTR <- function(x,
                                     model_list = NULL,
                                     .top = 1,
                                     ...) {
  .validate_iso_cols(x)

  if (is.null(model_list) || length(model_list) == 0) {
    stop("`model_list` is NULL or empty.")
  }

  dtest <- xgboost::xgb.DMatrix(as.matrix(x[, .pb_iso_cols(), drop = FALSE]))

  prob_list <- lapply(names(model_list), function(m_name) {
    m <- model_list[[m_name]]
    if (is.null(m))
      return(NULL)
    predict(m, dtest)
  })

  valid_models <- names(model_list)[!sapply(prob_list, is.null)]
  prob_matrix <- do.call(cbind, prob_list[!sapply(prob_list, is.null)])
  colnames(prob_matrix) <- valid_models

  results <- lapply(seq_len(nrow(prob_matrix)), function(i) {
    row_probs <- prob_matrix[i, ]
    top_idx <- order(row_probs, decreasing = TRUE)[seq_len(min(.top, length(row_probs)))]

    data.frame(
      row_id = i,
      ml_group = names(row_probs)[top_idx],
      ml_prob = as.numeric(row_probs[top_idx]),
      stringsAsFactors = FALSE
    )
  })

  pred_df <- do.call(rbind, results)

  x_temp <- x
  x_temp$row_id <- seq_len(nrow(x_temp))

  res <- dplyr::left_join(x_temp, pred_df, by = dplyr::join_by("row_id"))
  res$row_id <- NULL

  .tag_astr_context(res, c("ml_group", "ml_prob"))
}
