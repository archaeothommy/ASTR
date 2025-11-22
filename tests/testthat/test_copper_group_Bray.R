test_that("copper_group_bray", {
  df <- data.frame(
    ID = 1:4,
    As = c(0.12, 0.05, 0.15, 0.20),
    Sb = c(0.00, 0.12, 0.05, 0.01),
    Ag = c(0.00, 0.00, 0.20, 0.05),
    Ni = c(0.00, 0.00, 0.00, 0.15)
  )
  result <- copper_group_bray(df)
  expect_true("copper_group_bray" %in% colnames(result))
  expect_true(is.character(result$copper_group_bray))
  expect_equal(result[4, 6], "As+Ni")

})
