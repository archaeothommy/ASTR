test_that("copper_alloy_pollard: basic classification", {
  test_data <- data.frame(
    ID = 1:8,
    Sn = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
    Zn = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
    Pb = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
  )

  result <- copper_alloy_pollard(test_data)

  expect_equal(
    result$copper_alloy_pollard,
    c(
      "Copper",         # All < 1%
      "Leaded copper",  # Pb ≥ 1%
      "Bronze",         # Sn ≥ 1%
      "Leaded bronze",  # Sn, Pb ≥ 1%
      "Brass",          # Zn ≥ 1%
      "Gunmetal",       # Zn, Sn ≥ 1%
      "Leaded bronze",  # Sn, Pb ≥ 1% (same as ID 4)
      "Leaded gunmetal" # All ≥ 1%
    )
  )
})

test_that("copper_alloy_pollard: function arguments", {
  df <- data.frame(
    ID = 1,
    Tin = 8,
    Lead = 3,
    Zinc = 0.5
  )

  # "As+Sb" is group 6 in the lookup table
  expect_equal(
    copper_alloy_pollard(
      df,
      elements = c(Sn = "Tin", Zn = "Zinc", Pb = "Lead")
    )$copper_alloy_pollard,
    "Leaded bronze"
  )
  expect_equal(
    copper_alloy_pollard(
      df,
      elements = c(Sn = "Tin", Zn = "Zinc", Pb = "Lead"),
      group_as_symbol = TRUE
    )$copper_alloy_pollard,
    "LB"
  )
})

test_that("copper_alloy_pollard: Handling ASTR object", {
  test_data_ASTR <- as_ASTR(
    data.frame(
      ID = 1:8,
      Sn_atP = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
      Zn_atP = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
      Pb_atP = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
    )
  )
  test_result_ASTR <- copper_alloy_pollard(test_data_ASTR)

  expect_equal(units(test_result_ASTR[["Zn"]])[[1]], "wtP")
  expect_equal(attributes(test_result_ASTR[["copper_alloy_pollard"]])[[1]], "ASTR_context")
  expect_true(inherits(test_result_ASTR, "ASTR"))
})
