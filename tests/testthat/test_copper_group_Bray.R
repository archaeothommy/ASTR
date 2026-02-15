test_that("copper_group_bray: basic classification", {
  df <- data.frame(
    ID = 1:4,
    As = c(0.2, 0.01, 0.15, 0.00),
    Sb = c(0.00, 0.2, 0.00, 0.00),
    Ag = c(0.00, 0.00, 0.12, 0.00),
    Ni = c(0.00, 0.00, 0.00, 0.20)
  )

  result <- copper_group_bray(df)

  # Check column exists
  expect_true("copper_group_bray" %in% names(result))

  # Expected group names
  expected <- c("As", "Sb", "As+Ag", "Ni")

  expect_equal(result$copper_group_bray, expected)
})

test_that("copper_group_bray: function arguments", {
  df <- data.frame(
    ID = 1,
    Arsenic = 0.3,
    Antimony = 0.2,
    Silver = 0.0,
    Nickel = 0.0
  )

  # "As+Sb" is group 6 in the lookup table
  expect_equal(
    copper_group_bray(
      df,
      elements = c(As = "Arsenic", Sb = "Antimony", Ag = "Silver", Ni = "Nickel")
    )$copper_group_bray,
    "As+Sb"
  )
  expect_equal(
    copper_group_bray(
      df,
      elements = c(As = "Arsenic", Sb = "Antimony", Ag = "Silver", Ni = "Nickel"),
      group_as_number = TRUE
    )$copper_group_bray,
    6
  )
})
