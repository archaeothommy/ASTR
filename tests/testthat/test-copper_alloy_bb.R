test_that("Bayley & Butcher copper alloy classification", {
  test_data <- data.frame(
    ID = 1:11,
    Sn = c(1,   1,   5,   5,   5,   5,   0.5, 5,   NA,  5,   5),
    Zn = c(2,   5,   2,   4,   8,   15,  2,   8,   2,   NA,  8),
    Pb = c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 9,   6,   0.5, 0.5, NA)
  )
  result <- copper_alloy_bb(test_data)
  expect_equal(
    result$copper_alloy_bb,
    c(
      "Copper",             # ID 1:  Zn<3, Sn<3
      "Copper/brass",       # ID 2:  3<=Zn<8, Sn<3
      "Bronze/gunmetal",    # ID 3:  Sn>=3, 0.33*Sn<Zn<0.67*Sn
      "Gunmetal",           # ID 4:  Sn>=3, 0.67*Sn<Zn<2.5*Sn
      "Gunmetal",           # ID 5:  Sn>=3, 0.67*Sn<Zn<2.5*Sn
      "Brass/gunmetal",     # ID 6:  Zn>2.5*Sn, Zn<=4*Sn
      "Leaded Copper",      # ID 7:  Copper + Pb>8
      "(Leaded) Gunmetal",  # ID 8:  Gunmetal + 4<=Pb<=8
      "Unclassified",       # ID 9:  NA Sn
      "Unclassified",       # ID 10: NA Zn
      "Unclassified"        # ID 11: NA Pb
    )
  )
})
