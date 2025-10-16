# golden tests

test_input <- read_archchem("input_format.csv")

test_that("reading of a basic example table works as expected", {
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_input)
  })
})
