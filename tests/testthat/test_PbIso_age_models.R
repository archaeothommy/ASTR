age_model_data <- tibble::tibble(
  `206Pb/204Pb` = 18,
  `207Pb/204Pb` = 15,
  `208Pb/204Pb` = 2
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
  expect_equal(pb_iso_age_model(age_model_data, model = "SK75")[["model_age_SK75"]], -1166.946)
  expect_equal(pb_iso_age_model(age_model_data, model = "CR75")[["mu_CR75"]], 10.478)
  expect_equal(pb_iso_age_model(age_model_data, model = "AJ84")[["kappa_AJ84"]], -15.421)
  expect_error(pb_iso_age_model(age_model_data, model = 23), "'arg' must be.*")
  expect_error(pb_iso_age_model(age_model_data, model = "23"), "'arg' should be one of.*")
  expect_length(pb_iso_age_model(age_model_data, model = "all"), 12)
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
