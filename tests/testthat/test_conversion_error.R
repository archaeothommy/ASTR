test_input <- suppressWarnings(
  read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

# --- abs_to_rel ---

result <- abs_to_rel(test_input)

test_that("abs_to_rel: numeric conversion is correct", {
  expect_equal(as.numeric(result[["d65Cu_err2SD%"]]),
               as.numeric(test_input[["d65Cu_err2SD"]] / test_input[["d65Cu"]] * 100), tolerance = 1e-6)
})

test_that("abs_to_rel: error col units are percent after conversion", {
  expect_equal(as.character(units(result[["SiO2_errSD%"]])), "%")
})

test_that("abs_to_rel: input returned unchanged if no absolute error cols present", {
  df_no_err <- test_input[, !is_err_abs(colnames(test_input))]
  expect_identical(abs_to_rel(df_no_err), df_no_err)
})

test_that("abs_to_rel: errors on non-ASTR input", {
  expect_error(abs_to_rel(data.frame(x = 1)))
})

# --- rel_to_abs ---

result2 <- rel_to_abs(result)

test_that("rel_to_abs: numeric conversion is correct", {
  expect_equal(as.numeric(result2[["SiO2_errSD"]]),
               as.numeric(result[["SiO2_errSD%"]] * result[["SiO2"]] / 100), tolerance = 1e-6)
})

test_that("rel_to_abs: column renamed to absolute error", {
  expect_all_false(grepl("_err.{3}%", colnames(result2), perl = TRUE))
})

test_that("rel_to_abs: error col units match base col after conversion", {
  expect_equal(units(result2[["SiO2_errSD"]]),
               units(result2[["SiO2"]]))
})

test_that("rel_to_abs: base col and class unchanged", {
  expect_equal(result2[["SiO2"]], result[["SiO2"]])
  expect_s3_class(result2, "ASTR")
})

test_that("rel_to_abs: input returned unchanged if no relative error cols present", {
  df_no_err <- test_input[, !is_err_percent(colnames(test_input))]
  expect_identical(rel_to_abs(df_no_err), df_no_err)
})

# test not valid because column does no include NAs
#test_that("rel_to_abs: NA in base col produces NA in error col, no crash", {
#  na_rows <- is.na(as.numeric(test_input[["SiO2"]]))
#  expect_true(all(is.na(as.numeric(result[["SiO2_errSD"]])[na_rows])))
#})

test_that("rel_to_abs: errors on non-ASTR input", {
  expect_error(rel_to_abs(data.frame(x = 1)))
})

# --- conversion is reversible ---

error_reversed <- rel_to_abs(abs_to_rel(test_input))

test_that("error conversion is reversible and unitless values handled correctly", {
  expect_equal(test_input[["SiO_err2SD"]], error_reversed[["SiO2_err2SD"]])
  expect_equal(test_input[["d65Cu_err2SD"]], error_reversed[["d65Cu_err2SD"]])
  expect_equal(test_input[["206Pb/204Pb_err2SD"]], error_reversed[["206Pb/204Pb_err2SD"]])
})
