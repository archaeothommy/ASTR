# Helper function to generate clean mock isotope data
make_mock_isotope_data <- function(n = 10) {
  set.seed(123)
  # Generate collinear data along PC1 to ensure clean end-member separation
  pb206 <- seq(18.0, 19.5, length.out = n)
  pb207 <- 0.626208 * pb206 + 3.8 + rnorm(n, sd = 0.001)
  pb208 <- 2.0 * pb206 + 0.5 + rnorm(n, sd = 0.005)

  df <- data.frame(
    `206Pb/204Pb` = pb206,
    `207Pb/204Pb` = pb207,
    `208Pb/204Pb` = pb208,
    check.names = FALSE
  )
  class(df) <- c("ASTR", "data.frame")
  return(df)
}

# ==============================================================================
# S3 Method Dispatch & Input Validation
# ==============================================================================

test_that("errors when S3 method is not implemented for given object class", {
  x_numeric <- c(1, 2, 3)
  expect_error(
    pb_iso_endmembers(x_numeric),
    "no applicable method for 'pb_iso_endmembers'"
  )
})

test_that("errors when ASTR object is missing required isotope ratio columns", {
  astr_bad <- structure(
    data.frame(col1 = 1:5, col2 = 1:5),
    class = c("ASTR", "data.frame")
  )
  expect_error(
    pb_iso_endmembers(astr_bad),
    "Data set is missing required isotope ratio columns."
  )
})

test_that("errors when sample size is less than 3", {
  df_small <- make_mock_isotope_data(n = 2)
  expect_error(
    pb_iso_endmembers(df_small),
    "Too few samples. Suggest more than 3."
  )
})

test_that("errors when selected columns contain non-numeric data", {
  df_char <- make_mock_isotope_data(n = 5)
  df_char$`206Pb/204Pb` <- as.character(df_char$`206Pb/204Pb`)
  expect_error(
    pb_iso_endmembers(df_char),
    "Non-numeric values in isotope columns"
  )
})


# ==============================================================================
# Core Calculation & Class Assignment Tests
# ==============================================================================

test_that("classifies endmembers and assigns S3 class attributes for ASTR objects", {
  astr_obj <- make_mock_isotope_data(n = 10)

  res <- pb_iso_endmembers(astr_obj, tolerance = c(0.1, 0.1))

  # Check class heritage
  expect_s3_class(res, "ASTR_Pbiso_endmembr")
  expect_s3_class(res, "ASTR")

  # Check output structures
  expect_true("end_membr" %in% names(res))
  expect_true(all(res$end_membr %in% c("group1", "group2", "groupmix")))
  expect_equal(attr(res$end_membr, "ASTR_class"), "ASTR_context")
})


# ==============================================================================
# Warnings and Messages Tests
# ==============================================================================

test_that("emits warning when endmember groups overlap due to high tolerance", {
  astr_obj <- make_mock_isotope_data(n = 5)

  # Large tolerance forces group1 and group2 to overlap
  expect_warning(
    pb_iso_endmembers(astr_obj, tolerance = c(10, 10)),
    "Overlap in endmembers between groups. Suggest lower tolerance value."
  )
})

test_that("emits message when PC1 variance is low or PC distributions fail normality", {
  set.seed(999)
  # Isotropic non-linear 3D noise (forces low PC1 variance and non-normal residual PCs)
  df_noisy <- data.frame(
    `206Pb/204Pb` = runif(15, 18.0, 19.0),
    `207Pb/204Pb` = runif(15, 15.0, 16.0),
    `208Pb/204Pb` = runif(15, 38.0, 39.0),
    check.names = FALSE
  )
  class(df_noisy) <- c("ASTR", "data.frame")

  expect_message(
    pb_iso_endmembers(df_noisy),
    "PC1 represents less than 95% of the Variance"
  )
})

test_that("emits message when an endmember group has fewer than 2 points", {
  astr_obj <- make_mock_isotope_data(n = 10)

  # Extremely tiny tolerance restricts group capture to 1 point
  expect_message(
    pb_iso_endmembers(astr_obj, tolerance = c(0.000001, 0.000001)),
    "End Member group has less than two points"
  )
})
