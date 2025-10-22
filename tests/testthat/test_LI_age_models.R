age_model_data <- tibble::tibble(
  `206Pb/204Pb` = 18,
  `207Pb/204Pb` = 15,
  `208Pb/204Pb` = 2
)

test_that("Pb isotope age models", {
  expect_equal(pb_iso_age_model(age_model_data, model = "SK75")[[1]], -1166.946)
  expect_equal(pb_iso_age_model(age_model_data, model = "CR75")[[2]], 10.478)
  expect_equal(pb_iso_age_model(age_model_data, model = "AJ84")[[3]], -15.421)
  expect_length(pb_iso_age_model(age_model_data, model = "all"), 9)
})
