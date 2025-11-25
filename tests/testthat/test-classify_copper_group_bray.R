test_that("copper_group_bray classification works", {
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
  expect_equal(resul[4, "copper_group_bray"], "Ni")
})


test_that("copper_group_bray returns numeric groups when requested", {
  df <- data.frame(
    ID = 1,
    As = 0.3,
    Sb = 0.2,
    Ag = 0.0,
    Ni = 0.0
  )

  result_num <- copper_group_bray(df, group_as_number = TRUE)

  # "As+Sb" is group 6 in the lookup table
  expect_equal(result_num$copper_group_bray, 6)
})


test_that("copper_group_bray handles custom element names", {
  df <- data.frame(
    ID = 1,
    Arsenic = 0.2,
    Antimony = 0.0,
    Silver = 0.0,
    Nickel = 0.0
  )

  custom_elements <- c(As = "Arsenic", Sb = "Antimony", Ag = "Silver", Ni = "Nickel")

  result <- copper_group_bray(df, elements = custom_elements)

  expect_equal(result$copper_group_bray, "As")
})


