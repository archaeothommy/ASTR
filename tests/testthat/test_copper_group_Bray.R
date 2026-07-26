test_that("copper_group_bray: basic classification", {
  df <- data.frame(
    ID = 1:7,
    As = c(0.2, 0.01, 0.15, 0.00, NA, 0.2, 0.15),
    Sb = c(0.00, 0.2, 0.00, 0.00, 0.15, NA, 0.11),
    Ag = c(0.00, 0.00, 0.12, 0.00, 0.00, 0.00, NA),
    Ni = c(0.00, 0.00, 0.00, 0.20, 0.00, 0.00, 0.20)
  )

  result <- copper_group_bray(df)

  # Check column exists
  expect_true("copper_group_bray" %in% names(result))

  # Expected group names
  expect_equal(
    result$copper_group_bray,
    c(
      "As", # ID 1:  As only
      "Sb", # ID 2:  Sb only
      "As+Ag", # ID 3:  As and Ag
      "Ni", # ID 4:  Ni only
      "Unclassified", # ID 5:  NA As
      "Unclassified", # ID 6:  NA Sb
      "Unclassified" # ID 7:  NA Ag
    )
  )
})

test_that("copper_group_bray: function arguments", {
  df <- data.frame(
    ID = 1,
    Arsenic = 0.3,
    Antimony = 0.2,
    Silver = 0.0,
    Nickel = 0.0
  )

  # Custom column names — As+Sb is group 6
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

  # NA with group_as_number = TRUE returns NA
  df_na <- data.frame(ID = 1, Arsenic = NA, Antimony = 0.2, Silver = 0.0, Nickel = 0.0)
  expect_equal(
    copper_group_bray(
      df_na,
      elements = c(As = "Arsenic", Sb = "Antimony", Ag = "Silver", Ni = "Nickel"),
      group_as_number = TRUE
    )$copper_group_bray,
    NA_integer_
  )
})

test_that("copper_alloy_pollard: Handling ASTR object", {
  suppressWarnings(
    test_data_ASTR <- as_ASTR(
      data.frame(
        ID = 1,
        As_atP = c(0.3, 0.1),
        Sb_atP = c(0.2, 0.5),
        Ag_atP = c(0.0, 0.2),
        Ni_atP = c(0.0, NA)
      )
    )
  )
  test_result_ASTR <- copper_group_bray(test_data_ASTR)

  expect_equal(units(test_result_ASTR[["As"]])[[1]], "wtP")
  expect_equal(attributes(test_result_ASTR[["copper_group_bray"]])[[1]], "ASTR_context")
  expect_true(inherits(test_result_ASTR, "ASTR"))
})
