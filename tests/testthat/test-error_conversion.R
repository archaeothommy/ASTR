test_input <- suppressWarnings(
  read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

# --- rel_to_abs ---

test_that("rel_to_abs: numeric conversion is correct", {
  result <- rel_to_abs(test_input)
  relative_raw <- as.numeric(test_input[["SiO2_errSD%"]])
  value_raw    <- as.numeric(test_input[["SiO2"]])
  expect_equal(as.numeric(result[["SiO2_errSD%"]]),
               (relative_raw / 100) * value_raw, tolerance = 1e-6)
})

test_that("rel_to_abs: error col units match base col after conversion", {
  result <- rel_to_abs(test_input)
  expect_equal(as.character(units(result[["SiO2_errSD%"]])),
               as.character(units(result[["SiO2"]])))
})

test_that("rel_to_abs: base col and class unchanged", {
  result <- rel_to_abs(test_input)
  expect_equal(as.numeric(result[["SiO2"]]), as.numeric(test_input[["SiO2"]]))
  expect_s3_class(result, "ASTR")
})

test_that("rel_to_abs: NA in base col produces NA in error col, no crash", {
  expect_no_error(result <- rel_to_abs(test_input))
  na_rows <- is.na(as.numeric(test_input[["SiO2"]]))
  expect_true(all(is.na(as.numeric(result[["SiO2_errSD%"]])[na_rows])))
})

test_that("rel_to_abs: warns when no relative error cols present", {
  df_no_err <- test_input[, !grepl("%$", colnames(test_input))]
  class(df_no_err) <- class(test_input)
  expect_warning(rel_to_abs(df_no_err), "No error columns found")
})

test_that("rel_to_abs: errors on non-ASTR input", {
  expect_error(rel_to_abs(data.frame(x = 1)))
})

# --- abs_to_rel ---

test_that("abs_to_rel: numeric conversion is correct", {
  abs_input <- rel_to_abs(test_input)
  result     <- abs_to_rel(abs_input)
  expect_equal(as.numeric(result[["SiO2_errSD%"]]),
               as.numeric(test_input[["SiO2_errSD%"]]), tolerance = 1e-6)
})

test_that("abs_to_rel: error col units are percent after conversion", {
  result <- abs_to_rel(rel_to_abs(test_input))
  expect_equal(as.character(units(result[["SiO2_errSD%"]])), "%")
})

test_that("abs_to_rel: errors on non-ASTR input", {
  expect_error(abs_to_rel(data.frame(x = 1)))
})
