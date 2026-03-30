# tests/testthat/test-normalise_geochem.R

test_that("normalise_geochem handles all cases", {

  df <- data.frame(
    Sample = c("A", "B", "C", "D"),
    La = c(10, NA, 5, 20),
    Ce = c(20, 8, NA, 40),
    Nd = c(15, 6, 3, 30),
    X = c(1, 2, 3, 4)
  )

  # Run normalisation using internal reference data
  result <- normalise_geochem(df, reference = "chondrite")

  # Check normalization math (using real reference values)
  ref <- references_geochem$chondrite

  expect_equal(result$La, df$La / ref["La"])
  expect_equal(result$Ce, df$Ce / ref["Ce"])
  expect_equal(result$Nd, df$Nd / ref["Nd"])

  # Check non-element columns unchanged
  expect_equal(result$X, df$X)
  expect_equal(result$Sample, df$Sample)

  # Check NA values preserved
  expect_true(is.na(result$La[2]))
  expect_true(is.na(result$Ce[3]))

  # Warning when some elements missing
  df_partial <- df[, c("Sample", "La")]
  expect_warning(
    normalise_geochem(df_partial, reference = "chondrite"),
    regexp = "does not include all elements"
  )

  # Error when no matching elements
  df_none <- data.frame(Sample = c("A", "B"), X = c(1, 2))
  expect_error(
    normalise_geochem(df_none, reference = "chondrite"),
    regexp = "does not include any element"
  )

  # Structure checks
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(df))
  expect_equal(names(result), names(df))
})
