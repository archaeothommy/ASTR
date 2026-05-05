test_that("copper_alloy_bb: basic classification", {
  test_data <- data.frame(
    ID   = 1:11,
    Tin  = c(1,   1,   5,   5,   5,   5,   0.5, 5,   NA,  5,   5),
    Zn   = c(2,   5,   2,   4,   8,   15,  2,   8,   2,   NA,  8),
    Lead = c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 9,   6,   0.5, 0.5, NA)
  )
  expect_equal(
    copper_alloy_bb(
      test_data,
      elements = c(Sn = "Tin", Zn = "Zn", Pb = "Lead")
    )$copper_alloy_bb,
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

test_that("copper_alloy_bb: Handling ASTR object", {
  test_data_ASTR <- as_ASTR(
    data.frame(
      ID     = 1:8,
      Sn_atP = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
      Zn_atP = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
      Pb_atP = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
    )
  )
  test_result_ASTR <- copper_alloy_bb(test_data_ASTR)
  expect_equal(units(test_result_ASTR[["Zn"]])[[1]], "wtP")
  expect_equal(attributes(test_result_ASTR[["copper_alloy_bb"]])[[1]], "ASTR_context")
  expect_true(inherits(test_result_ASTR, "ASTR"))
})
