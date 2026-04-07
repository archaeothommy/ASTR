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

test_that("copper_alloy_pollard: Handling ASTR object", {
  test_data_ASTR <- as_ASTR(
    data.frame(
      ID = 1,
      As_atP = 0.3,
      Sb_atP = 0.2,
      Ag_atP = 0.0,
      Ni_atP = 0.0
    )
  )
  test_result_ASTR <- copper_group_bray(test_data_ASTR)

  expect_equal(units(test_result_ASTR[["As"]])[[1]], "wtP")
  expect_equal(attributes(test_result_ASTR[["copper_group_bray"]])[[1]], "ASTR_context")
  expect_true(inherits(test_result_ASTR, "ASTR"))
})
