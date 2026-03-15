# test columns selection function not checked elsewhere

test_input <- suppressWarnings(
  as_archchem(
    archchem_example_input,
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

test_that("column selection based on archchem column types", {
  expect_all_true(
    colnames(get_isotope_columns(test_input)) ==
      c(
        "ID", "143Nd/144Nd", "d65Cu", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb",
        "207Pb/206Pb", "208Pb/206Pb"
      )
  )
  expect_all_true(
    colnames(get_element_columns(test_input)) ==
      c("ID", "FeOtot/SiO2", "(Na2O+K2O)/SiO2")
  )
  expect_all_true(
    colnames(get_ratio_columns(test_input)) ==
      c(
        "ID", "143Nd/144Nd", "d65Cu", "FeOtot/SiO2", "(Na2O+K2O)/SiO2", "206Pb/204Pb", "207Pb/204Pb",
        "208Pb/204Pb", "207Pb/206Pb", "208Pb/206Pb"
      )
  )
  expect_all_true(
    colnames(get_concentration_columns(test_input)) ==
      c(
        "ID", "Na2O", "BaO", "Pb", "MgO", "Al2O3", "SiO2", "P2O5", "S", "CaO", "TiO2",
        "MnO", "FeOtot", "ZnO", "K2O", "Cu", "As", "LOI", "Ag", "Sn", "Sb", "Te", "Bi",
        "U", "V", "Cr", "Co", "Ni", "Sr", "Se"
      )
  )
})
