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
  expect_equal(result$La_chondrite, units::drop_units(df$La / references_geochem$chondrite["La"]))
  expect_equal(result$Ce_chondrite, units::drop_units(df$Ce / references_geochem$chondrite["Ce"]))
  expect_equal(result$Nd_chondrite, units::drop_units(df$Nd / references_geochem$chondrite["Nd"]))

  # Check non-element columns unchanged
  expect_equal(result$X, df$X)
  expect_equal(result$Sample, df$Sample)

  # Check NA values preserved
  expect_true(is.na(result$La[2]))
  expect_true(is.na(result$Ce[3]))

  # Error when no matching elements
  df_none <- data.frame(Sample = c("A", "B"), X = c(1, 2))
  expect_error(
    normalise_geochem(df_none, reference = "chondrite"),
    regexp = "does not include any element"
  )

  # Structure checks
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(df))
  expect_equal(names(result), c(names(df), "La_chondrite", "Ce_chondrite", "Nd_chondrite"))
})

test_that("ASTR objects handled as intended", {

  suppressWarnings(
    test_input <- read_ASTR(
      system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
      id_column = "Sample",
      context = 1:7
    )
  )

  normalised <- normalise_geochem(test_input, "chondrite")

  expect_true("ASTR" %in% class(normalised))
  expect_equal(get_contextual_columns(normalised[1:8]), get_contextual_columns(test_input))
  expect_equal(
    attributes(normalised[["Sb_chondrite"]]),
    attributes(test_input[["Sample"]])
  )

})


