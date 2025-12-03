test_that("Pollard et al. copper alloy classification", {
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
      "Copper",           # All < 1%
      "Leaded copper",    # Pb ≥ 1%
      "Bronze",           # Sn ≥ 1%
      "Leaded bronze",    # Sn, Pb ≥ 1%
      "Brass",            # Zn ≥ 1%
      "Gunmetal",         # Zn, Sn ≥ 1%
      "Leaded bronze",    # Sn, Pb ≥ 1% (same as ID 4)
      "Leaded gunmetal"   # All ≥ 1%
    )
  )
})
