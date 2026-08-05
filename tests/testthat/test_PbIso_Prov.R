# ==============================================================================
# Helper / Test Data Generators
# ==============================================================================

make_mock_astr <- function(n = 10, groups = c("RegionA", "RegionB")) {
  set.seed(42)
  df <- data.frame(
    sample_id = paste0("S", seq_len(n)),
    region = rep_len(groups, n),
    `206Pb/204Pb` = runif(n, 18.0, 19.5),
    `207Pb/204Pb` = runif(n, 15.4, 15.8),
    `208Pb/204Pb` = runif(n, 38.0, 39.5),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  class(df) <- c("ASTR", "data.frame")
  df
}

make_mock_large_astr <- function(samples_per_group = 25) {
  set.seed(123)
  g1 <- data.frame(
    region = "RegionA",
    `206Pb/204Pb` = rnorm(samples_per_group, 18.2, 0.01),
    `207Pb/204Pb` = rnorm(samples_per_group, 15.5, 0.01),
    `208Pb/204Pb` = rnorm(samples_per_group, 38.2, 0.01),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  g2 <- data.frame(
    region = "RegionB",
    `206Pb/204Pb` = rnorm(samples_per_group, 19.1, 0.01),
    `207Pb/204Pb` = rnorm(samples_per_group, 15.7, 0.01),
    `208Pb/204Pb` = rnorm(samples_per_group, 39.1, 0.01),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  df <- rbind(g1, g2)
  class(df) <- c("ASTR", "data.frame")
  df
}


# ==============================================================================
# 1. Internal Helpers
# ==============================================================================

test_that(".pb_iso_cols returns expected column names", {
  expect_equal(.pb_iso_cols(), c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb"))
})

test_that(".validate_iso_cols validates column presence correctly", {
  good_df <- make_mock_astr(3)
  bad_df <- data.frame(`206Pb/204Pb` = 18.1, check.names = FALSE)

  expect_silent(.validate_iso_cols(good_df))
  expect_error(
    .validate_iso_cols(bad_df),
    "Dataset is missing required lead isotope columns"
  )
})

test_that(".ensure_pbiso_ref validates and converts reference objects", {
  good_astr <- make_mock_astr(10)
  non_astr <- data.frame(`206Pb/204Pb` = 18.1)

  expect_error(.ensure_pbiso_ref(non_astr, "region"), "`ref` must be of class 'ASTR'.")

  # Converts standard ASTR to ASTR_Pbiso_ref_data
  ref_out <- .ensure_pbiso_ref(good_astr, ref_group = "region", min_groupsize = 2)
  expect_s3_class(ref_out, "ASTR_Pbiso_ref_data")
})

test_that(".tag_astr_context tags specified columns with attribute", {
  df <- data.frame(a = 1:3, b = 4:6)
  tagged <- .tag_astr_context(df, c("a", "missing_col"))

  expect_equal(attr(tagged$a, "ASTR_class"), "ASTR_context")
  expect_null(attr(tagged$b, "ASTR_class"))
})

test_that(".check_required_packages handles installed and missing packages", {
  # Standard installed packages pass silently
  expect_silent(.check_required_packages(c("stats", "utils")))

  # Missing package non-interactive handling
  mockery_env <- new.env()
  rlang::with_interactive(value = FALSE, {
    expect_error(
      .check_required_packages("nonExistentPackage12345"),
      "Function requires package\\(s\\): nonExistentPackage12345"
    )
  })
})


# ==============================================================================
# 2. Reference Data Preprocessing (as_pbiso_ref_data)
# ==============================================================================

test_that("as_pbiso_ref_data.ASTR processes groups, handles NAs, and assigns S3 class", {
  raw_df <- make_mock_astr(12, groups = c("A", "B", "C"))
  # Add NAs and a tiny group C
  raw_df[1, "206Pb/204Pb"] <- NA
  raw_df[2:3, "region"] <- "C" # Group C has size 2

  ref_data <- as_pbiso_ref_data(raw_df, group = "region", min_groupsize = 4)

  expect_s3_class(ref_data, "ASTR_Pbiso_ref_data")
  expect_false(any(is.na(ref_data)))
  expect_false("B" %in% ref_data$region) # Excluded because count < min_groupsize
  expect_equal(names(ref_data), c("region", .pb_iso_cols()))
})


# ==============================================================================
# 3. Distance Metrics (euc_dist, mf_dist, pb_iso_prov_dist)
# ==============================================================================

test_that("euc_dist.ASTR calculates Euclidean distances and joins results", {
  query <- make_mock_astr(2, groups = c("Q1", "Q2"))
  ref <- make_mock_astr(10, groups = c("Ref1", "Ref2"))

  res <- euc_dist(query, ref = ref, ref_group = "region", .n = 1)

  expect_true("ed_dist" %in% names(res))
  expect_true("ed_ref_region" %in% names(res))
  expect_equal(nrow(res), 2)
  expect_equal(attr(res$ed_dist, "ASTR_class"), "ASTR_context")
})

test_that("mf_dist.ASTR calculates Mass-Fractionation distances", {
  query <- make_mock_astr(2)
  ref <- make_mock_astr(10)

  res <- mf_dist(query, ref = ref, ref_group = "region", .n = 1, s = 0.001)

  expect_true("mf_dist_sq" %in% names(res))
  expect_true("mf_ref_region" %in% names(res))
  expect_equal(nrow(res), 2)
  expect_equal(attr(res$mf_dist_sq, "ASTR_class"), "ASTR_context")
})

test_that("pb_iso_prov_dist.ASTR switches distance models correctly", {
  query <- make_mock_astr(2)
  ref <- make_mock_astr(10)

  res_ed <- pb_iso_prov_dist(query, ref = ref, ref_group = "region", dist_type = "ed")
  expect_true("ed_dist" %in% names(res_ed))

  res_mf <- pb_iso_prov_dist(query, ref = ref, ref_group = "region", dist_type = "mf")
  expect_true("mf_dist_sq" %in% names(res_mf))

  res_all <- pb_iso_prov_dist(query, ref = ref, ref_group = "region", dist_type = "all")
  expect_true(all(c("ed_dist", "mf_dist_sq") %in% names(res_all)))
})


# ==============================================================================
# 4. Machine Learning Training Pipeline (pb_iso_train_data)
# ==============================================================================

test_that("pb_iso_train_data executes full DBSCAN, SMOTE, and XGBoost workflow", {
  large_dataset <- make_mock_large_astr(samples_per_group = 25)

  # Test direct dispatch on ASTR object
  models <- pb_iso_train_data(
    ref = large_dataset,
    ref_group = "region",
    min_groupsize = 5,
    .minSize = 20,
    .minPts_fac = 0.1,
    .eps = 0.5, # Generous eps for test clustering
    .nrounds = 5,
    nthread = 1
  )

  expect_type(models, "list")
  expect_gt(length(models), 0)
  expect_s3_class(models[[1]], "xgb.Booster")
})

test_that("helper_train_function validates .minPts_fac boundaries", {
  ref_obj <- as_pbiso_ref_data(make_mock_astr(10), group = "region", min_groupsize = 1)

  expect_error(
    helper_train_function(ref_obj, .minPts_fac = 1.5),
    "\\.minPts_fac must be between 0 and 1\\."
  )
  expect_error(
    helper_train_function(ref_obj, .minPts_fac = 0),
    "\\.minPts_fac must be between 0 and 1\\."
  )
})


# ==============================================================================
# 5. ML Prediction (pb_iso_prov_predict)
# ==============================================================================

test_that("pb_iso_prov_predict.ASTR predicts probabilities using trained models", {
  large_dataset <- make_mock_large_astr(samples_per_group = 25)
  models <- pb_iso_train_data(
    ref = large_dataset,
    ref_group = "region",
    .minSize = 20,
    .eps = 0.5,
    .nrounds = 5,
    nthread = 1
  )

  query <- make_mock_astr(3)

  # Error on NULL/empty models
  expect_error(pb_iso_prov_predict(query, model_list = NULL), "`model_list` is NULL or empty\\.")
  expect_error(pb_iso_prov_predict(query, model_list = list()), "`model_list` is NULL or empty\\.")

  # Valid prediction
  preds <- pb_iso_prov_predict(query, model_list = models, .top = 1)

  expect_true(all(c("ml_group", "ml_prob") %in% names(preds)))
  expect_equal(nrow(preds), 3)
  expect_equal(attr(preds$ml_group, "ASTR_class"), "ASTR_context")
  expect_equal(attr(preds$ml_prob, "ASTR_class"), "ASTR_context")
})
