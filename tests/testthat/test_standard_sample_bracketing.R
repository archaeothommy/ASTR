# tests

test_input <- readxl::read_excel(
  system.file("extdata",
              "bracketing/ULB_Cu_20190903-test 2.xlsx",
              package = "ASTR"),
  sheet = "03092019",
  skip = 2
)

library(dplyr)

# subset just the sequences of samples to apply SSB
subset_to_bracket <-
  test_input %>%
  slice(13:45, 68:104)

test_that("standard sample bracketing works as expected", {
  expect_snapshot({
    # turn to data.frame to render the entire table
    standard_sample_bracketing(subset_to_bracket,
                               values = "Cu65/63 corr 68/66",
                               id_col = "Sample Name...1",
                               id_std = "Cu/Zn in house 25ppb")
  })
})
