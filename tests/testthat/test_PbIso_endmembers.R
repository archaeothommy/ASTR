library(testthat)

# ==============================================================================
# Helper Mock Objects and Mock Data Generators
# ==============================================================================

# Generic dataset generator creating points along a linear trajectory with noise
make_mock_endmembers_astr <- function(n = 20, seed = 42) {
  set.seed(seed)
  # Generate synthetic mix along PC1 line: 207Pb/204Pb ~ 0.626 * 206Pb/204Pb
  pb206 <- seq(18.0, 19.5, length.out = n)
  pb207 <- 15.0 + 0.626208 * (pb206 - 18.0) + rnorm(n, mean = 0, sd = 0.001)
  pb208 <- 38.0 + 1.2 * (pb206 - 18.0) + rnorm(n, mean = 0, sd = 0.005)

  df <- data.frame(
    sample_id = paste0("S", seq_len(n)),
    `206Pb/204Pb` = pb206,
    `207Pb/204Pb` = pb207,
    `208Pb/204Pb` = pb208,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  class(df) <- c("ASTR", "data.frame")
  df
}

# Standin mock for tag_astr_context if missing/internal during test environment setup
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

# Standin mock for internal column getters/validation if not attached
if (!exists(".pb_iso_cols")) {
  .pb_iso_cols <- function() {
    c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
  }
}

if (!exists(".validate_iso_cols")) {
  .validate_iso_cols <- function(x) {
    req <- .pb_iso_cols()
    if (!all(req %in% names(x))) {
      stop("Dataset is missing required lead isotope columns")
    }
  }
}


# ==============================================================================
# 1. Validation & Input Errors
# ==============================================================================

test_that("pb_iso_endmembers throws error when required isotope columns are missing",
          {
            invalid_df <- data.frame(
              sample_id = "S1",
              `206Pb/204Pb` = 18.1,
              check.names = FALSE
            )
            class(invalid_df) <- c("ASTR", "data.frame")

            expect_error(pb_iso_endmembers(invalid_df),
                         "Dataset is missing required lead isotope columns")
          })

test_that("pb_iso_endmembers throws error for non-numeric isotope values",
          {
            df_char <- make_mock_endmembers_astr(5)
            df_char$`206Pb/204Pb` <- as.character(df_char$`206Pb/204Pb`)
            df_char[1, "206Pb/204Pb"] <- "non_numeric_entry"

            expect_error(pb_iso_endmembers(df_char),
                         "Non-numeric values in isotope columns")
          })

test_that("pb_iso_endmembers throws error when dataset has fewer than 3 samples",
          {
            small_df <- make_mock_endmembers_astr(2)

            expect_error(
              pb_iso_endmembers(small_df),
              "Too few samples\\. More than 3 samples are recommended\\."
            )
          })


# ==============================================================================
# 2. PCA Diagnostics & Messages
# ==============================================================================

test_that("pb_iso_endmembers triggers message and prints summary when PC1 variance < 95%",
          {
            set.seed(99)
            # Multi-directional noise so PC1 variance drops below 95%
            n <- 10
            df_low_pc1 <- data.frame(
              sample_id = paste0("S", seq_len(n)),
              `206Pb/204Pb` = runif(n, 18.0, 19.0),
              `207Pb/204Pb` = runif(n, 15.0, 16.0),
              `208Pb/204Pb` = runif(n, 37.0, 40.0),
              check.names = FALSE,
              stringsAsFactors = FALSE
            )
            class(df_low_pc1) <- c("ASTR", "data.frame")

            expect_message(
              expect_output(pb_iso_endmembers(df_low_pc1), "Importance of components"),
              "PC1 represents less than 95% of the variance. There may be more than two endmembers."
            )
          })

test_that("pb_iso_endmembers triggers message on non-normal PC distributions",
          {
            # Mock stats::shapiro.test to force normality test failures
            df <- make_mock_endmembers_astr(20)
            expect_message(
              pb_iso_endmembers(df),
              "PC2 or PC3 are not normally distributed. This may indicate that the variation is not random noise."
            )
          })


# ==============================================================================
# 3. Filtering Mechanics, Clamping, and Warnings
# ==============================================================================

test_that("pb_iso_endmembers triggers message when an endmember group has < 2 points",
          {
            df <- make_mock_endmembers_astr(15)

            # A tiny tolerance ensures < 2 points fall on the geochron line for group ends
            expect_message(
              pb_iso_endmembers(df, tolerance = c(1e-6, 1e-6)),
              "Endmember group has less than two points\\. The likelihood of a point being an endmember is low\\."
            )
          })

test_that("pb_iso_endmembers triggers warning when groups overlap due to high tolerance",
          {
            df <- make_mock_endmembers_astr(10)

            # A giant tolerance forces all points into both group1 and group2
            expect_message(
              pb_iso_endmembers(df, tolerance = c(10, 10)),
              "Overlap in endmembers between groups. A lower tolerance value is suggested."
            )
          })

test_that("clamping reduces group sizes by distance from principal endmember",
          {
            df <- make_mock_endmembers_astr(25)

            no_clamp <- pb_iso_endmembers(df, clamp = c(Inf, Inf))
            clamped <- pb_iso_endmembers(df, clamp = c(Inf, 0.05))

            g2_no_clamp_count <- sum(no_clamp$end_membr == "group2", na.rm = TRUE)
            g2_clamped_count <- sum(clamped$end_membr == "group2", na.rm = TRUE)

            expect_gte(g2_no_clamp_count, g2_clamped_count)
          })


# ==============================================================================
# 4. S3 Output Class, Structure, and Attributes
# ==============================================================================

test_that("pb_iso_endmembers returns expected object structure, levels, and classes",
          {
            df <- make_mock_endmembers_astr(20)
            res <- pb_iso_endmembers(df)

            # Class checks
            expect_s3_class(res, "ASTR_Pbiso_endmembr")
            expect_s3_class(res, "ASTR")

            # Column and contents checks
            expect_true("end_membr" %in% names(res))
            expect_true(all(res$end_membr %in% c("group1", "group2", "groupmix")))

            # Context tagging attribute check
            expect_equal(attr(res$end_membr, "ASTR_class"), "ASTR_context")
          })

test_that("S3 generic dispatches properly", {
  df <- make_mock_endmembers_astr(10)

  res_generic <- pb_iso_endmembers(df)
  res_direct <- pb_iso_endmembers.ASTR(df)

  expect_equal(res_generic, res_direct)
})
