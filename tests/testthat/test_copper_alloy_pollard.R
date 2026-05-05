test_that("copper_alloy_pollard: basic classification", {
  test_data <- data.frame(
    ID = 1:11,
    Sn = c(0.5, 0.5, 5,   5,   0.5, 5,   5,   5,   NA,  0.5, 5),
    Zn = c(0.5, 0.5, 0.5, 0.5, 5,   5,   0.5, 5,   0.5, NA,  0.5),
    Pb = c(0.5, 5,   0.5, 5,   0.5, 0.5, 5,   5,   0.5, 0.5, NA)
  )
  result <- copper_alloy_pollard(test_data)
  expect_equal(
    result$copper_alloy_pollard,
    c(
      "Copper",         # ID 1:  All < 1%
      "Leaded copper",  # ID 2:  Pb >= 1%
      "Bronze",         # ID 3:  Sn >= 1%
      "Leaded bronze",  # ID 4:  Sn, Pb >= 1%
      "Brass",          # ID 5:  Zn >= 1%
      "Gunmetal",       # ID 6:  Zn, Sn >= 1%
      "Leaded bronze",  # ID 7:  Sn, Pb >= 1%
      "Leaded gunmetal", # ID 8:  All >= 1%
      "Unclassified",   # ID 9:  NA Sn
      "Unclassified",   # ID 10: NA Zn
      "Unclassified"    # ID 11: NA Pb
    )
  )
})

test_that("copper_alloy_pollard: function arguments", {
  df <- data.frame(
    ID   = 1,
    Tin  = 8,
    Lead = 3,
    Zinc = 0.5
  )
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
      ID     = 1:8,
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
