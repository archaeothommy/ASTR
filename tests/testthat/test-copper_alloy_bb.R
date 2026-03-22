test_that("copper_alloy_bb", {
  test_data <- data.frame(
    ID = 1:8,
    Tin = c(1, 1, 5, 5, 5, 5, 0.5, 5),
    Zn = c(2, 5, 2, 4, 8, 15, 2, 8),
    Lead = c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 9, 6)
  )

  expect_equal(
    copper_alloy_bb(test_data, elements = c("Sn" = "Tin", "Zn" = "Zn", "Pb" = "Lead"))$copper_alloy_bb,
    c(
      "Copper",           # ID 1: Copper (Zn<3, Sn<3)
      "Copper/brass",     # ID 2: Copper/brass (3≤Zn<8, Sn<3)
      "Bronze/gunmetal",  # ID 3: Bronze (Sn≥3, Zn<3*Sn)
      "Gunmetal",         # ID 4: Bronze/gunmetal (Sn≥3, 0.33<Zn/Sn<0.67)
      "Gunmetal",         # ID 5: Gunmetal (Sn≥3, 0.67<Zn/Sn<2.5)
      "Brass/gunmetal",   # ID 6: Brass/gunmetal (Zn>2.5*Sn, Zn≤4*Sn)
      "Leaded Copper",    # ID 7: Leaded Copper (Copper + Pb>8)
      "(Leaded) Gunmetal" # ID 8: (Leaded) Gunmetal (Gunmetal + 4≤Pb≤8)
    )
  )
})
