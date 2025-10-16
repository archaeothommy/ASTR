# golden tests
test_that("reading of a basic example table works as expected", {
  expect_snapshot({
    test_input <- read_archchem("input_format.csv")
    # turn to data.frame to render the entire table
    as.data.frame(test_input)
  })
})
