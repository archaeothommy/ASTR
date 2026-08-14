library(testthat)

# Shared data
df <- data.frame(
  ID  = c("A", "B", "C"),
  La  = c(10, 5, 8),
  Ce  = c(20, 8, 15),
  Nd  = c(15, 6, 12)
)

# normalise_100

test_that("normalise_100 works", {
  result <- normalise_100(df)
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  expect_equal(rowSums(result[numeric_cols]), rep(100, nrow(df)), tolerance = 1e-10)
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
  result <- normalise_sample(df, reference = "A", id_column = "ID")
  ref_row <- df[df$ID == "A", ]
  expect_equal(result$La, df$La / ref_row$La)
  expect_equal(result$Ce, df$Ce / ref_row$Ce)
  expect_error(normalise_sample(df, reference = "Z", id_column = "ID"))

  df_dup <- rbind(df, df[1, ])
  expect_error(normalise_sample(df_dup, reference = "A", id_column = "ID"))
  expect_error(normalise_sample(df, reference = "A", id_column = "nonexistent"))
})

# normalise_data wrapper

test_that("normalise_data dispatches correctly", {
  # geochem
  result_geochem <- normalise_data(df, type = "geochem", reference = "chondrite")
  expect_true("La_chondrite" %in% names(result_geochem))

  # hundred
  result_hundred <- normalise_data(df, type = "hundred")
  numeric_cols <- names(df)[sapply(df, is.numeric)]
  expect_equal(rowSums(result_hundred[numeric_cols]), rep(100, nrow(df)), tolerance = 1e-10)

  # element
  result_element <- normalise_data(df, type = "element", reference = "La")
  expect_equal(result_element$Ce, df$Ce / df$La)

  # sample
  result_sample <- normalise_data(df, type = "sample", reference = "A", id_column = "ID")
  ref_row <- df[df$ID == "A", ]
  expect_equal(result_sample$La, df$La / ref_row$La)

  # errors
  expect_error(normalise_data(df, type = "wrong"))
  expect_error(normalise_data(list(), type = "hundred"))
})
