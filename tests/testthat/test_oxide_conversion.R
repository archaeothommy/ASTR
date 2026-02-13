# tests/testthat/test_oxide_conversion.R

# Test data
df <- data.frame(
  metadata = "Sample1",
  Ag = 100,
  Fe = 50,
  Si = 45
)

test_that("element_to_oxide respects oxide preferences", {
  # Oxidising preference
  res_ox <- element_to_oxide(df, elements = c("Ag", "Fe", "Si"),
                             oxide_preference = "oxidising")
  expect_true(all(c("AgO", "Fe2O3", "SiO2") %in% names(res_ox)))

  # Reducing preference
  res_red <- element_to_oxide(df, elements = c("Ag", "Fe", "Si"),
                              oxide_preference = "reducing")
  expect_true(all(c("Ag2O", "FeO", "SiO2") %in% names(res_red)))

  # Named vector preference
  res_named <- element_to_oxide(df, elements = c("Ag", "Fe"),
                                oxide_preference = c(Ag = "Ag2O", Fe = "FeO"))
  expect_true(all(c("Ag2O", "FeO") %in% names(res_named)))
})

test_that("oxide_to_element converts back correctly", {
  df_ox <- data.frame(
    Ag2O = 100 * 1.07416,
    FeO = 50 * 1.286489,
    SiO2 = 45 * 2.139286
  )

  res <- oxide_to_element(df_ox, oxides = c("Ag2O", "FeO", "SiO2"))
  expect_true(all(c("Ag", "Fe", "Si") %in% names(res)))
  expect_equal(res$Ag, 100, tolerance = 0.1)
  expect_equal(res$Fe, 50, tolerance = 0.1)
  expect_equal(res$Si, 45, tolerance = 0.1)
})

test_that("conversion is reversible", {
  ox <- element_to_oxide(df, elements = c("Ag", "Fe", "Si"),
                         oxide_preference = "reducing")
  el <- oxide_to_element(ox, oxides = c("Ag2O", "FeO", "SiO2"))

  expect_equal(el$Ag, df$Ag, tolerance = 0.1)
  expect_equal(el$Fe, df$Fe, tolerance = 0.1)
  expect_equal(el$Si, df$Si, tolerance = 0.1)
})

test_that("drop argument preserves original columns", {
  res <- element_to_oxide(df, elements = c("Ag", "Fe"),
                          oxide_preference = "reducing",
                          drop = FALSE)
  expect_true(all(c("Ag", "Fe", "Ag2O", "FeO") %in% names(res)))
})
