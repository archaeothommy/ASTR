# test columns selection function not checked elsewhere

test_input <- suppressWarnings(
  read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

no_unit <- remove_units(test_input, recover_unit_names = TRUE)

test_that("units are removed from ASTR objects", {
  expect_false(inherits(no_unit$`Co_mg/kg`, "units"))
  expect_all_true(c("Te_mg/kg", "As_wt%", "S_at%") %in% colnames(no_unit))
})


unify_units <- unify_concentration_unit(test_input, "µg/g")

test_that("concentrations are unified", {
  expect_false(units(test_input$Na2O) == units(unify_units$Na2O))
  expect_all_equal(c(deparse_unit(unify_units$Na2O), deparse_unit(unify_units$Sb)), "µg g-1")
})


test_that("concentrations are converted and errors provoked as intended", {
  convert_units <- convert_concentration_units(
    test_input, values = c("S"), unit_to = "oxP", oxide_preference = "oxidising"
  )
  expect_equal(units(convert_units[["SO3"]])[[1]], "wtP")

  convert_units <- convert_concentration_units(test_input, values = c("Na2O", "CaO"), unit_to = "wtP")
  expect_equal(units(convert_units[["Ba"]])[[1]], "wtP")

  convert_units <- convert_concentration_units(test_input, values = c("Se", "Te"), unit_to = "atP")
  expect_equal(units(convert_units[["Sb"]])[[1]], "atP")

  convert_units <- convert_concentration_units(
    test_input, values = c("Se", "Te"), unit_to = "oxP", oxide_preference = "oxidising"
  )
  expect_equal(units(convert_units[["Sb2O5"]])[[1]], "wtP")

  convert_units <- convert_concentration_units(test_input, values = c("Na2O", "CaO"), unit_to = "atP")
  expect_equal(units(convert_units[["Ba"]])[[1]], "atP")

  expect_error(
    convert_concentration_units(test_input, values = c("S", "Na2O"), unit_to = "ppm"),
    "Unit conversion failed: Values include oxides and elements.*"
  )
  expect_error(
    convert_concentration_units(test_input, values = c("S", "Te"), unit_to = "ppm"),
    "Unit conversion failed: Units cannot be converted.*"
  )

})
