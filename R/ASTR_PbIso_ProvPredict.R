# Reference Data Function --------------------------------------------------

#' Create Reference data object for LIA endmember distance and probability estimate functions.
#'
#' Data preprocessing and cleaning ensure the reliability and accuracy of provenance analysis.
#' This step results in the removal of all NA values from the selected Isotope tables, and groups.
#' The step also should exclude the groups which have low sample data (in the case of (Shnyr et al., (2026) it was 5).
#'
#' @param x Reference data frame or tibble.
#' @param cols Vector of column names which represent 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#' @param group Name of the column containing isotope groups as character string.
#' @param min_groupsize Integer value for the minimum number samples in a group. (Default = 5)
#'
#'
#' @returns
#' ref.data object with Isotope groupings and Isotope columns of
#' 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#' with shorter names.
#' @export
as.ref_data <- function(x, cols, group, min_groupsize = 5) {
  if (!all(cols %in% names(x))) {
    stop("column names not found")
  }
  cols <- c(
    grep("6", cols, value = TRUE),
    grep("7", cols, value = TRUE),
    grep("8", cols, value = TRUE)
  )

  x <- na.omit(x[, c(group, cols)])
  names(x) <- c("groups", "pb64", "pb74", "pb84")
  if (!is.null(min_groupsize)) {
    counts <- table(x$groups)
    valid <- names(counts[counts >= min_groupsize])
    x <- x[x$groups %in% valid, ]
  }
  class(x) <- c("ref.data", class(x))
  x
}

# Training Function ----------------------------------------------------------------

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
#' @importFrom dbscan dbscan
#' @importFrom smotefamily SMOTE
#' @importFrom xgboost xgb.train xgb.DMatrix
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
#' @export
pb_iso_train_data <- function(ref,
                       .minSize = 20,
                       .minPts_fac = 0.1,
                       .eps = 0.18,
                       .eta = 0.1,
                       .max_depth = 6,
                       .nrounds = 100,
                       nthread = 4L,
                       ...) {
  if (!"ref.data" %in% class(ref)) {
    stop(
      "ref must be of class ref.data. Use function `ref_data`
                     for preporcessing ref data first."
    )
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


# Prediction Function -----------------------------------------------------

xgboost_predict <- function(x, model_list = NULL, .probablity) {
  rownames(x) <- NULL
  dtest_all <- xgboost::xgb.DMatrix(as.matrix(x))

  all_model_results <- lapply(names(model_list), function(m_name) {
    m <- model_list[[m_name]]
    if (is.null(m))
      return(NULL)

    probs <- predict(m, dtest_all)

    idx <- which(probs >= .probablity)

    if (length(idx) == 0)
      return(NULL)

    subset_x <- x[idx, , drop = FALSE]
    subset_probs <- probs[idx]
    res <- data.frame(
      subset_x,
      group = m_name,
      prob = as.numeric(subset_probs),
      stringsAsFactors = FALSE
    )
    rownames(res) <- NULL
    return(res)
  })

  all_model_results <- all_model_results[!sapply(all_model_results, is.null)]

  if (length(all_model_results) == 0)
    return(NULL)

  final_df <- do.call(rbind, all_model_results)

  names(final_df) <- c("pb64", "pb74", "pb84", "group", "prob")
  final_df$group <- gsub("_", " ", final_df$group)

  final_df <- final_df[order(final_df$prob, decreasing = TRUE), ]
  rownames(final_df) <- NULL

  return(final_df)
}

# End member Prediction function ------------------------------------------

#' Predict Isotope Provenance
#'
#' Predicts Pb Isotope provenance of a sample matrix in reference to a xgboost trained list
#'
#' @param x Matrix of `pbisoendmembers` object of pbisotope samples
#' @param model_list Model list generated by `train_data()`
#' @param .probablity Probability between 0 and 1 of a Guess being correct. (Default = 0.95)
#'
#' @importFrom stats na.omit predict setNames
#'
#' @returns
#' data.frame object or list of data.frames
#' @seealso train_data
#' @export
pb_iso_prov_predict <- function(x,
                            model_list = NULL,
                            .probablity = 0.95) {
  if (inherits(x, "pbisoendmembers")) {
    target_groups <- x[3:4]
    pred <- lapply(target_groups, function(grp) {
      if (is.null(grp) || nrow(grp) == 0)
        return(NULL)
      xgboost_predict(grp, model_list = model_list, .probablity = .probablity)
    })

    names(pred) <- names(target_groups)
    return(pred)
  }

  return(xgboost_predict(x, model_list = model_list, .probablity = .probablity))
}
