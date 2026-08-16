# Shared data
df <- data.frame(
  Sample = c("A", "B", "C", "D"),
  La = c(10, NA, 5, 20),
  Ce = c(20, 8, NA, 40),
  Nd = c(15, 6, 3, 30),
  X = c(1, 2, 3, 4)
)

suppressWarnings(
  test_input <- read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = 1:7
  )
)

# normalise_geochem

test_that("normalise_geochem handles all cases", {

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

  normalised <- normalise_geochem(test_input, "chondrite")

  expect_true("ASTR" %in% class(normalised))
  expect_equal(get_contextual_columns(normalised[1:8]), get_contextual_columns(test_input))
  expect_equal(
    attributes(normalised[["Sb_chondrite"]]),
    attributes(test_input[["Sample"]])
  )

})


# normalise_100

test_that("normalise_100 works", {
  result <- normalise_100(df)
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  expect_equal(rowSums(result[numeric_cols], na.rm = TRUE), rep(100, nrow(df)), tolerance = 1e-10)
  expect_equal(result$ID, df$ID)
  expect_error(normalise_100(list()))
})

# normalise_element

test_that("normalise_element works", {
  result <- normalise_element(df, reference = "La")
  expect_equal(result$Ce, df$Ce / df$La)
  expect_equal(result$Nd, df$Nd / df$La)
  expect_error(normalise_element(df, reference = "ID"))
  expect_error(normalise_element(df, reference = "Sm"))
})

# normalise_sample

test_that("normalise_sample works", {
  result <- normalise_sample(df, reference = "A", id_column = "Sample")
  ref_row <- df[df$Sample == "A", ]
  expect_equal(result$La, df$La / ref_row$La)
  expect_equal(result$Ce, df$Ce / ref_row$Ce)
  expect_error(normalise_sample(df, reference = "Z", id_column = "Sample"))

  df_dup <- rbind(df, df[1, ])
  expect_error(normalise_sample(df_dup, reference = "A", id_column = "Sample"))
  expect_error(normalise_sample(df, reference = "A", id_column = "nonexistent"))
})

# normalise_data wrapper

test_that("normalise_data dispatches correctly", {
  expect_equal(normalise_data(df, type = "geochem", reference = "chondrite"), normalise_geochem(df, "chondrite"))
  expect_equal(normalise_data(df, type = "hundred"), normalise_100(df))
  expect_equal(normalise_data(df, type = "element", reference = "La"), normalise_element(df, "La"))
  expect_equal(normalise_data(df, type = "sample", reference = "A", id_column = "Sample"), normalise_sample(df, "A", id_column = "Sample"))

  # errors
  expect_error(normalise_data(df, type = "wrong"))
  expect_error(normalise_data(list(), type = "hundred"))
})
