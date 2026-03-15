# golden tests

test_input <- read_archchem(
  system.file("extdata", "input_format.csv", package = "ASTR"),
  id_column = "other",
  context = c("other", "other2")
)

test_input_xlsx <- read_archchem(
  system.file("extdata", "input_format.xlsx", package = "ASTR"),
  id_column = "other",
  context = c("other", "other2")
)

test_input2 <- suppressWarnings(
  read_archchem(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

test_input3 <- readr::read_csv(system.file("extdata", "input_format.csv", package = "ASTR"))
test_input3[2, ] <- test_input3[1, ]
test_input3 <- suppressWarnings(
  as_archchem(test_input3, id_column = "other2", context = "other")
)

test_that("reading of a basic example table works as expected", {
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_input)
  })
  expect_equal(test_input_xlsx, test_input)
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_input2)
  })
  expect_snapshot({
    print(test_input)
  })
  # checks that automatic renaming of ID values works
  expect_all_equal(test_input3$ID[2], "27_2")
})

# parsing throws expected errors

test_input3 <- readr::read_csv(system.file("extdata", "input_format.csv", package = "ASTR"))
test_input3[2, ] <- test_input3[1, ]

test_that("archem functions result in expected errors and warnings", {
  expect_error(
    suppressWarnings(as_archchem(test_input3, id_column = "other")),
    "Column name .* could not be parsed"
  )
  expect_warning(
    as_archchem(test_input3, id_column = "other", context = "other2"),
    "Detected multiple data rows with the same ID"
  )
  expect_error(
    validate(2),
    "x is not an object of class archchem"
  )
})
