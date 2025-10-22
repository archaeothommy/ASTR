# golden tests

test_input <- read_archchem(
  system.file("extdata", "input_format.csv", package = "ASTR"),
  context = c("other", "other2")
)

test_that("reading of a basic example table works as expected", {
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_input)
  })
})
