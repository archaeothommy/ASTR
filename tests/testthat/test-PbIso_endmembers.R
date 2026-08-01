library(testthat)

# ==============================================================================
# Helper Functions & Mock Data Setup
# ==============================================================================

# Creates synthetic lead isotope data with configurable properties
make_mock_pb_data <- function(n_rows = 10, as_df = FALSE, seed = 42) {
  set.seed(seed)
  pc1 <- seq(-2, 2, length.out = n_rows)

  # Linear relationship with tiny variance to force high PC1 proportion (> 0.95)
  pb206 <- 18.5 + pc1 + rnorm(n_rows, sd = 0.0001)
  pb207 <- 15.6 + 0.626208 * pc1 + rnorm(n_rows, sd = 0.0001)
  pb208 <- 38.5 + pc1 * 1.2 + rnorm(n_rows, sd = 0.0001)

  mat <- cbind("206Pb/204Pb" = pb206, "207Pb/204Pb" = pb207, "208Pb/204Pb" = pb208)
  if (as_df) return(as.data.frame(mat))
  return(mat)
}

# ==============================================================================
# Tests for pb_iso_endmembers()
# ==============================================================================

test_that("pb_iso_endmembers checks input arguments and throws errors", {
  cols <- c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")

  # 1. Invalid x class (neither data.frame nor matrix)
  expect_error(
    pb_iso_endmembers(x = "not_a_df", col = cols),
    "is not a dataframe or a matrix"
  )

  # 2. Null col argument
  df <- make_mock_pb_data(as_df = TRUE)
  expect_error(
    pb_iso_endmembers(x = df, col = NULL),
    "Column names needed!"
  )

  # 3. Incorrect column names (must contain 6, 7, and 8)
  expect_error(
    pb_iso_endmembers(x = df, col = c("A", "B", "C")),
    "Incorrect number or names of colums"
  )

  # 4. Non-numeric elements inside data frame or matrix
  non_num_df <- data.frame(
    "206Pb/204Pb" = c("a", "b", "c"),
    "207Pb/204Pb" = c(1, 2, 3),
    "208Pb/204Pb" = c(4, 5, 6)
  )
  expect_error(
    pb_iso_endmembers(x = non_num_df, col = names(non_num_df)),
    "Non-numeric values in dataframe or matrix"
  )
})

test_that("pb_iso_endmembers warns when sample count is less than 3", {
  small_mat <- make_mock_pb_data(n_rows = 2)
  cols <- colnames(small_mat)

  expect_error(
    pb_iso_endmembers(small_mat, col = cols),
    "To few samples. Suggest to  be more than 3"
  )
})

test_that("pb_iso_endmembers handles low PC1 variance message and output printing", {
  # Generate noisy matrix where PC1 captures < 95% of total variance
  set.seed(99)
  noisy_mat <- matrix(rnorm(30), ncol = 3)
  colnames(noisy_mat) <- c("206Pb", "207Pb", "208Pb")

  # Should trigger both the PC1 message and print the summary output
  expect_message(
    expect_output(
      pb_iso_endmembers(noisy_mat, col = colnames(noisy_mat)),
      "Importance of components"
    ),
    "PC1 represents less than 95% of the Variance"
  )
})

test_that("pb_iso_endmembers checks Shapiro-Wilk normality condition for PC2/PC3", {
  mat <- make_mock_pb_data(n_rows = 15, seed = 123)
  cols <- colnames(mat)

  # Triggers the PC2/PC3 non-normality message
  expect_message(
    pb_iso_endmembers(mat, col = cols),
    "PC2 or PC3 are not normally distributed. This may indicate that their variation may not be random noise."
  )
})

test_that("pb_iso_endmembers handles group size messages and group overlap warnings", {
  mat <- make_mock_pb_data(n_rows = 6)
  cols <- colnames(mat)

  # 1. Extremely small tolerance results in empty or single-point endmember groups (< 2 points)
  expect_message(
    pb_iso_endmembers(mat, col = cols, tolerance = c(1e-8, 1e-8)),
    "End Member group has less than two points"
  )

  # 2. Large tolerance forces shared sample indices between end_group1 and end_group2
  expect_warning(
    pb_iso_endmembers(mat, col = cols, tolerance = c(100, 100)),
    "Overlap in endmembers between gorups"
  )
})

test_that("pb_iso_endmembers returns correct S3 object on success", {
  df <- make_mock_pb_data(n_rows = 12, as_df = TRUE)
  cols <- colnames(df)

  res <- suppressMessages(suppressWarnings(
    pb_iso_endmembers(df, col = cols, tolerance = c(0.1, 0.1), clamp = c(10, 10))
  ))

  # Validate S3 Class inheritance and list structure
  expect_s3_class(res, "pbisoendmembers")
  expect_type(res, "list")
  expect_named(res, c("data", "pca_ends", "group1", "group2", "mixing", "tolarance", "clamp", "pca"))

  # Validate component formats
  expect_true(is.matrix(res$data))
  expect_s3_class(res$pca, "prcomp")
  expect_equal(res$tolarance, c(0.1, 0.1))
  expect_equal(res$clamp, c(10, 10))
})

# ==============================================================================
# Tests for summary.pbisoendmembers()
# ==============================================================================

test_that("summary.pbisoendmembers prints formatted output and returns summary list", {
  df <- make_mock_pb_data(n_rows = 10, as_df = TRUE)
  cols <- colnames(df)

  end_obj <- suppressMessages(suppressWarnings(
    pb_iso_endmembers(df, col = cols, tolerance = c(0.05, 0.05), clamp = c(5, 5))
  ))

  # 1. Check printed output content
  expect_output(summary(end_obj), "Summary of End memebers:")
  expect_output(summary(end_obj), "Tolarance: 0.05 0.05")
  expect_output(summary(end_obj), "PCA Endmembers")
  expect_output(summary(end_obj), "Counts")

  # 2. Check invisible return list values and components
  res <- summary(end_obj)

  expect_type(res, "list")
  expect_named(res, c("Counts", "Tolarance", "Clamp", "Data"))
  expect_equal(res$Tolarance, c(0.05, 0.05))
  expect_equal(res$Clamp, c(5, 5))
  expect_true(is.matrix(res$Data))
})
