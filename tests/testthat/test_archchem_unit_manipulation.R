# test columns selection function not checked elsewhere

test_input <- suppressWarnings(
  read_archchem(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

test_that("", {
  expect_(

  )
})
