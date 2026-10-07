library(testthat)

# ==============================================================================
# Helper Mock Objects and Setup
# ==============================================================================

# Mock for tag_astr_context in case it is internal/external to current scope
if (!exists("tag_astr_context")) {
  tag_astr_context <- function(df, cols) {
    for (col in cols) {
      if (col %in% names(df)) {
        attr(df[[col]], "ASTR_class") <- "ASTR_context"
      }
    }
    df
  }
}

# Mock for check_required_packages in case it is internal
if (!exists("check_required_packages")) {
  check_required_packages <- function(pkgs) {
    missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
    if (length(missing) > 0) {
      stop("Missing required packages: ", paste(missing, collapse = ", "))
    }
    TRUE
  }
}

# Factory for ASTR test datasets
make_test_astr <- function(n = 10, seed = 123) {
  set.seed(seed)
  df <- data.frame(
    sample_id = paste0("S", seq_len(n)),
    `206Pb/204Pb` = runif(n, 18.0, 19.5),
    `207Pb/204Pb` = runif(n, 15.0, 16.0),
    `208Pb/204Pb` = runif(n, 37.0, 39.5),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  class(df) <- c("ASTR", "data.frame")
  df
}

# Factory for ASTR reference datasets
make_test_ref_astr <- function(n_per_group = 10, groups = c("RegionA", "RegionB")) {
  dfs <- lapply(groups, function(g) {
    df <- make_test_astr(n = n_per_group)
    df$Region <- g
    df
  })
  res <- do.call(rbind, dfs)
  # Re-order so region is first non-isotope column
  res <- res[, c("Region", "sample_id", .pb_iso_cols())]
  class(res) <- c("ASTR", "data.frame")
  res
}


# ==============================================================================
# 1. Internal Helpers & Data Validation
# ==============================================================================

test_that(".pb_iso_cols returns correct column names", {
  expect_equal(.pb_iso_cols(), c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb"))
})

test_that(".validate_iso_cols throws error when missing columns", {
  bad_df <- data.frame(sample_id = "S1", `206Pb/204Pb` = 18.2, check.names = FALSE)
  expect_error(.validate_iso_cols(bad_df), "Dataset is missing required lead isotope columns")
})

test_that(".ensure_pbiso_ref validates and converts reference objects", {
  non_astr <- data.frame(a = 1)
  expect_error(.ensure_pbiso_ref(non_astr, "Region"), "`ref` must be of class 'ASTR'")

  ref_raw <- make_test_ref_astr(n_per_group = 6)
  ref_processed <- .ensure_pbiso_ref(ref_raw, ref_group = "Region", min_groupsize = 5)
  expect_s3_class(ref_processed, "ASTR_Pbiso_ref_data")
})


# ==============================================================================
# 2. Reference Data Creation (as_pbiso_ref_data)
# ==============================================================================

test_that("as_pbiso_ref_data filters NA values and small groups", {
  raw_ref <- make_test_ref_astr(n_per_group = 6, groups = c("GroupKeep", "GroupDrop"))
  # Add NA to GroupKeep
  raw_ref[1, "206Pb/204Pb"] <- NA
  # Reduce GroupDrop below min_groupsize
  raw_ref <- raw_ref[raw_ref$Region != "GroupDrop" | c(rep(TRUE, 2), rep(FALSE, 4)), ]

  res <- as_pbiso_ref_data(raw_ref, group = "Region", min_groupsize = 5L)

  expect_s3_class(res, "ASTR_Pbiso_ref_data")
  expect_false("GroupDrop" %in% res$Region)
  expect_false(any(is.na(res)))
  expect_equal(ncol(res), 4) # Group col + 3 isotope cols
})


# ==============================================================================
# 3. Distance Calculation Functions (euc_dist, mf_dist, pb_iso_prov_dist)
# ==============================================================================

test_that("euc_dist returns valid structure and tagged context columns", {
  query <- make_test_astr(n = 3)
  ref <- as_pbiso_ref_data(make_test_ref_astr(n_per_group = 6), group = "Region")

  res <- euc_dist(query, ref, ref_group = "Region", n = 1)

  expect_s3_class(res, "ASTR")
  expect_true("ed_dist" %in% names(res))
  expect_equal(nrow(res), 3)
  expect_equal(attr(res$ed_dist, "ASTR_class"), "ASTR_context")
})

test_that("mf_dist calculates mass-fractionation corrected distances correctly", {
  query <- make_test_astr(n = 3)
  ref <- as_pbiso_ref_data(make_test_ref_astr(n_per_group = 6), group = "Region")

  res <- mf_dist(query, ref, ref_group = "Region", n = 1, s = 0.001)

  expect_s3_class(res, "ASTR")
  expect_true("mf_dist_sq" %in% names(res))
  expect_equal(nrow(res), 3)
  expect_true(all(res$mf_dist_sq >= 0))
})

test_that("pb_iso_prov_dist dispatches correctly for 'ed', 'mf', and 'all'", {
  query <- make_test_astr(n = 2)
  ref <- make_test_ref_astr(n_per_group = 6)

  res_ed <- pb_iso_prov_dist(query, ref, ref_group = "Region", dist_type = "ed")
  expect_true("ed_dist" %in% names(res_ed))
  expect_false("mf_dist_sq" %in% names(res_ed))

  res_mf <- pb_iso_prov_dist(query, ref, ref_group = "Region", dist_type = "mf")
  expect_true("mf_dist_sq" %in% names(res_mf))
  expect_false("ed_dist" %in% names(res_mf))

  res_all <- pb_iso_prov_dist(query, ref, ref_group = "Region", dist_type = "all")
  expect_true(all(c("ed_dist", "mf_dist_sq") %in% names(res_all)))
})


# ==============================================================================
# 4. Machine Learning Model Training & Prediction
# ==============================================================================

test_that("helper_train_function validates .minPts_fac bounds", {
  ref <- as_pbiso_ref_data(make_test_ref_astr(n_per_group = 25), group = "Region")

  expect_error(
    helper_train_function(ref, .minPts_fac = 1.5),
    "\\.minPts_fac must be between 0 and 1\\."
  )
})

test_that("pb_iso_train_data and pb_iso_prov_predict run end-to-end workflow", {
  skip_if_not_installed("dbscan")
  skip_if_not_installed("smotefamily")
  skip_if_not_installed("xgboost")

  # Create reference data with enough samples per group to clear .minSize (>= 20)
  ref_raw <- make_test_ref_astr(n_per_group = 22, groups = c("Mine_A", "Mine_B"))
  ref_data <- as_pbiso_ref_data(ref_raw, group = "Region", min_groupsize = 5)

  # Train model list
  models <- pb_iso_train_data(
    ref = ref_data,
    .minSize = 20,
    .minPts_fac = 0.1,
    .eps = 0.5, # Generous eps to prevent all-outlier clusters in random test data
    .nrounds = 5,
    nthread = 1L
  )

  expect_type(models, "list")
  expect_gt(length(models), 0)

  # Test predictions
  query <- make_test_astr(n = 4)
  preds <- pb_iso_prov_predict(query, model_list = models, .top = 1)

  expect_s3_class(preds, "ASTR")
  expect_true(all(c("ml_group", "ml_prob") %in% names(preds)))
  expect_equal(nrow(preds), 4)
  expect_equal(attr(preds$ml_group, "ASTR_class"), "ASTR_context")
})

test_that("pb_iso_prov_predict handles errors and missing models gracefully", {
  query <- make_test_astr(n = 2)

  expect_error(
    pb_iso_prov_predict(query, model_list = NULL),
    "`model_list` is NULL or empty\\."
  )
  expect_error(
    pb_iso_prov_predict(query, model_list = list()),
    "`model_list` is NULL or empty\\."
  )
})
