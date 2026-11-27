age_model_data <- tibble::tibble(
  `206Pb/204Pb` = c(18, NA, 18),
  `207Pb/204Pb` = c(15, 15, NA),
  `208Pb/204Pb` = c(2, NA, 2)
)

suppressWarnings(
  test_input <- read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = 1:7
  )
)

age_models_ASTR <- pb_iso_age_model(test_input, model = "all")

test_that("Pb isotope age models", {
  # Values are as expected
  sk75 <- pb_iso_age_model(age_model_data, model = "SK75")
  expect_equal(sk75[["model_age_SK75"]][1], -1166.946)
  cr75 <- pb_iso_age_model(age_model_data, model = "CR75")
  expect_equal(cr75[["mu_CR75"]][1], 10.478)
  aj84 <- pb_iso_age_model(age_model_data, model = "AJ84")
  expect_equal(aj84[["kappa_AJ84"]][1], -15.421)
  expect_length(pb_iso_age_model(age_model_data, model = "all"), 12)

  # Failure is as expected
  expect_error(pb_iso_age_model(age_model_data, model = 23), "'arg' must be.*")
  expect_error(pb_iso_age_model(age_model_data, model = "23"), "'arg' should be one of.*")

  # Rows with a missing input ratio yield NA for all model parameters
  expect_true(all(is.na(sk75[["model_age_SK75"]][2:3])))
  expect_true(all(is.na(sk75[["mu_SK75"]][2:3])))
  expect_true(all(is.na(sk75[["kappa_SK75"]][2:3])))
  expect_true(all(is.na(cr75[["model_age_CR75"]][2:3])))
  expect_true(all(is.na(cr75[["mu_CR75"]][2:3])))
  expect_true(all(is.na(cr75[["kappa_CR75"]][2:3])))
  expect_true(all(is.na(aj84[["model_age_AJ84"]][2:3])))
  expect_true(all(is.na(aj84[["mu_AJ84"]][2:3])))
  expect_true(all(is.na(aj84[["kappa_AJ84"]][2:3])))
})

test_that("ASTR objects handled as intended", {
  expect_true("ASTR" %in% class(age_models_ASTR))
  expect_equal(get_contextual_columns(age_models_ASTR[1:8]), get_contextual_columns(test_input))
  expect_equal(
    attributes(age_models_ASTR[["mu_AJ84"]]),
    attributes(test_input[["Sample"]])
  )
  expect_true("ASTR" %in% class(stacey_kramers_1975(test_input)))
  expect_equal(
    attributes(pb_iso_age_model(test_input, model = "CR75")[["kappa_CR75"]]),
    attributes(test_input[["Sample"]])
  )
})
