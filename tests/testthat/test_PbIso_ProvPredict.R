library(testthat)

# ==============================================================================
# Helpers & Synthetic Data Generators
# ==============================================================================

make_synthetic_isotope_data <- function(n_per_group = 25, seed = 123) {
  set.seed(seed)

  # Group A: Centered near (18.2, 15.6, 38.2)
  gA <- data.frame(
    Region = "RegionA",
    ratio_206 = rnorm(n_per_group, mean = 18.2, sd = 0.02),
    ratio_207 = rnorm(n_per_group, mean = 15.6, sd = 0.02),
    ratio_208 = rnorm(n_per_group, mean = 38.2, sd = 0.02)
  )

  # Group B: Centered near (18.8, 15.8, 38.8)
  gB <- data.frame(
    Region = "RegionB",
    ratio_206 = rnorm(n_per_group, mean = 18.8, sd = 0.02),
    ratio_207 = rnorm(n_per_group, mean = 15.8, sd = 0.02),
    ratio_208 = rnorm(n_per_group, mean = 38.8, sd = 0.02)
  )

  rbind(gA, gB)
}

make_mock_endmembers_object <- function() {
  grp1 <- matrix(c(18.2, 15.6, 38.2, 18.21, 15.61, 38.21),
                 ncol = 3,
                 byrow = TRUE)
  colnames(grp1) <- c("pb64", "pb74", "pb84")

  grp2 <- matrix(c(18.8, 15.8, 38.8, 18.81, 15.81, 38.81),
                 ncol = 3,
                 byrow = TRUE)
  colnames(grp2) <- c("pb64", "pb74", "pb84")

  obj <- list(
    data = NULL,
    pca_ends = NULL,
    group1 = grp1,
    group2 = grp2
  )
  class(obj) <- c("pbisoendmembers", "list")
  return(obj)
}

# ==============================================================================
# 1. Tests for as.ref_data()
# ==============================================================================

describe("as.ref_data()", {
  it("creates a ref.data object with cleaned and renamed columns", {
    raw_df <- make_synthetic_isotope_data(n_per_group = 10)

    ref <- as.ref_data(
      x = raw_df,
      cols = c("ratio_206", "ratio_207", "ratio_208"),
      group = "Region",
      min_groupsize = 5
    )

    expect_s3_class(ref, "ref.data")
    expect_s3_class(ref, "data.frame")
    expect_named(ref, c("groups", "pb64", "pb74", "pb84"))
    expect_equal(nrow(ref), 20)
  })

  it("removes rows with NA values in selected columns or group", {
    raw_df <- make_synthetic_isotope_data(n_per_group = 10)
    raw_df[3, "ratio_206"] <- NA
    raw_df[12, "Region"] <- NA

    ref <- as.ref_data(
      x = raw_df,
      cols = c("ratio_206", "ratio_207", "ratio_208"),
      group = "Region",
      min_groupsize = 5
    )

    expect_equal(nrow(ref), 18)
    expect_false(any(is.na(ref)))
  })

  it("filters out groups smaller than min_groupsize", {
    raw_df <- make_synthetic_isotope_data(n_per_group = 10)
    small_group <- data.frame(
      Region = "RegionC",
      ratio_206 = c(18.5, 18.5, 18.5),
      ratio_207 = c(15.7, 15.7, 15.7),
      ratio_208 = c(38.5, 38.5, 38.5)
    )
    df_combined <- rbind(raw_df, small_group)

    ref <- as.ref_data(
      x = df_combined,
      cols = c("ratio_206", "ratio_207", "ratio_208"),
      group = "Region",
      min_groupsize = 5
    )

    expect_false("RegionC" %in% ref$groups)
    expect_equal(unique(ref$groups), c("RegionA", "RegionB"))
  })

  it("throws an error when specified columns are missing", {
    raw_df <- make_synthetic_isotope_data(n_per_group = 5)

    expect_error(as.ref_data(
      x = raw_df,
      cols = c("missing_206", "ratio_207", "ratio_208"),
      group = "Region"
    ),
    "column names not found")
  })
})

# ==============================================================================
# 2. Tests for pb_iso_train_data()
# ==============================================================================

describe("pb_iso_train_data()", {
  it("throws error if input ref is not of class ref.data", {
    raw_df <- make_synthetic_isotope_data(n_per_group = 10)

    expect_error(pb_iso_train_data(ref = raw_df),
                 "ref must be of class ref.data")
  })

  it("successfully trains XGBoost models on a valid ref.data object",
     {
       raw_df <- make_synthetic_isotope_data(n_per_group = 25, seed = 42)
       ref <- as.ref_data(
         x = raw_df,
         cols = c("ratio_206", "ratio_207", "ratio_208"),
         group = "Region",
         min_groupsize = 20
       )

       models <- pb_iso_train_data(
         ref = ref,
         .minSize = 20,
         .minPts_fac = 0.1,
         .eps = 0.18,
         .nrounds = 5,
         nthread = 1
       )

       expect_type(models, "list")
       expect_true(length(models) > 0)
       expect_s3_class(models[[1]], "xgb.Booster")
     })

  it("handles filtering small groups below .minSize during clustering",
     {
       raw_df <- make_synthetic_isotope_data(n_per_group = 25, seed = 99)
       # Group A: 25 samples, Group B: 10 samples
       raw_df <- raw_df[c(1:25, 26:35), ]

       ref <- as.ref_data(
         x = raw_df,
         cols = c("ratio_206", "ratio_207", "ratio_208"),
         group = "Region",
         min_groupsize = 5
       )

       models <- pb_iso_train_data(
         ref = ref,
         .minSize = 20,
         # Group B (<20) passes through unclustered or skipped
         .nrounds = 5,
         nthread = 1
       )

       expect_type(models, "list")
     })
})

# ==============================================================================
# 3. Tests for pb_iso_prov_predict() and xgboost_predict()
# ==============================================================================

describe("pb_iso_prov_predict()", {
  # Setup shared trained model for prediction tests
  setup_models <- function() {
    raw_df <- make_synthetic_isotope_data(n_per_group = 25, seed = 123)
    ref <- as.ref_data(
      x = raw_df,
      cols = c("ratio_206", "ratio_207", "ratio_208"),
      group = "Region",
      min_groupsize = 20
    )
    pb_iso_train_data(
      ref = ref,
      .minSize = 20,
      .nrounds = 10,
      nthread = 1
    )
  }

  it("predicts provenance for a simple data frame or matrix input", {
    models <- setup_models()

    test_samples <- data.frame(
      pb64 = c(18.2, 18.8),
      pb74 = c(15.6, 15.8),
      pb84 = c(38.2, 38.8)
    )

    pred <- pb_iso_prov_predict(
      x = test_samples,
      model_list = models,
      .probablity = 0.1 # Low threshold to guarantee hits in test
    )

    expect_s3_class(pred, "data.frame")
    expect_named(pred, c("pb64", "pb74", "pb84", "group", "prob"))
    expect_true(nrow(pred) > 0)
    expect_false(is.unsorted(rev(pred$prob))) # Verify descending sort order
  })

  it("returns NULL when no sample passes the .probablity threshold", {
    models <- setup_models()

    test_samples <- data.frame(
      pb64 = c(18.2),
      pb74 = c(15.6),
      pb84 = c(38.2)
    )

    pred <- pb_iso_prov_predict(
      x = test_samples,
      model_list = models,
      .probablity = 0.99999 # Impossibly high threshold
    )

    expect_null(pred)
  })

  it("handles pbisoendmembers S3 objects correctly", {
    models <- setup_models()
    end_obj <- make_mock_endmembers_object()

    pred_list <- pb_iso_prov_predict(x = end_obj,
                                     model_list = models,
                                     .probablity = 0.1)

    expect_type(pred_list, "list")
    expect_named(pred_list, c("group1", "group2"))
    expect_s3_class(pred_list$group1, "data.frame")
    expect_s3_class(pred_list$group2, "data.frame")
  })

  it("handles empty or NULL groups inside pbisoendmembers object", {
    models <- setup_models()
    end_obj <- make_mock_endmembers_object()
    end_obj$group1 <- NULL # Simulate empty target group

    pred_list <- pb_iso_prov_predict(x = end_obj,
                                     model_list = models,
                                     .probablity = 0.1)

    expect_null(pred_list$group1)
    expect_s3_class(pred_list$group2, "data.frame")
  })
})
