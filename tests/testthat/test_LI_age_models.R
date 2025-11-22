age_model_data <- tibble::tibble(
  `206Pb/204Pb` = 18,
  `207Pb/204Pb` = 15,
  `208Pb/204Pb` = 2
)

test_that("Pb isotope age models", {
  expect_equal(pb_iso_age_model(age_model_data, model = "SK75")[["model_age_SK75"]], -1166.946)
  expect_equal(pb_iso_age_model(age_model_data, model = "CR75")[["mu_CR75"]], 10.478)
  expect_equal(pb_iso_age_model(age_model_data, model = "AJ84")[["kappa_AJ84"]], -15.421)
  expect_error(pb_iso_age_model(age_model_data, model = 23), "Assertion on*")
  expect_error(pb_iso_age_model(age_model_data, model = "23"), "This model is not supported.")
  expect_length(pb_iso_age_model(age_model_data, model = "all"), 12)
})
