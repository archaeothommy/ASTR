test_that("classify_copper_group_bray works", {
  df <- data.frame(
    ID = 1:4,
    As = c(0.12, 0.05, 0.15, 0.20),
    Sb = c(0.00, 0.12, 0.05, 0.01),
    Ag = c(0.00, 0.00, 0.20, 0.05),
    Ni = c(0.00, 0.00, 0.00, 0.15)
  )
  result <- classify_copper_group_bray(df)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 4)
  expect_true("copper_group_bray" %in% colnames(result))
  expect_true(is.character(result$copper_group_bray))
  valid_groups <- c(
    "As", "Sb", "Ag", "Ni",
    "As+Sb", "As+Ag", "As+Ni",
    "Sb+Ag", "Sb+Ni", "Ag+Ni",
    "As+Sb+Ag", "As+Sb+Ni", "As+Ag+Ni",
    "Sb+Ag+Ni", "As+Sb+Ag+Ni",
    "None"
  )
  expect_true(all(result$copper_group_bray %in% valid_groups))
})
