# tests/testthat/test_oxide_conversion.R

# Test data
df <- data.frame(
  metadata = "Sample1",
  Xy = 34,
  Ag = c(5, 5),
  Fe = c(50, 45),
  Si = c(45, 50),
  Ac = 0.5,
  Sr = c(0.02, 0.5),
  Ba = c(0.5, 0.02)
)

#df2 <-

test_that("element_to_oxide: oxide preferences", {
  # Oxidising preference
  res_ox <- element_to_oxide(df,
    elements = c("Ag", "Fe", "Si"),
    oxide_preference = "oxidising"
  )
  expect_true(all(c("AgO", "Fe2O3", "SiO2") %in% names(res_ox)))

  # Reducing preference
  res_red <- element_to_oxide(df,
    elements = c("Ag", "Fe", "Si"),
    oxide_preference = "reducing"
  )
  expect_true(all(c("Ag2O", "FeO", "SiO2") %in% names(res_red)))

  # Named vector preference
  res_named <- element_to_oxide(df,
    elements = c("Ag", "Fe"),
    oxide_preference = c(Ag = "Ag2O", Fe = "FeO")
  )
  expect_true(all(c("Ag2O", "FeO") %in% names(res_named)))
})

test_that("element_to_oxide: chemical concentration", {
  res <- element_to_oxide(
    df,
    elements = c("Ag", "Fe", "Si", "Sr", "Ba"),
    oxide_preference = "reducing",
    which_concentrations = "major"
  )
  expect_true(all(is.na(res[, c("SrO", "BaO")])))

  res <- element_to_oxide(
    df,
    elements = c("Ag", "Fe", "Si", "Sr", "Ba"),
    oxide_preference = "reducing",
    which_concentrations = "minor"
  )
  expect_true(all(is.na(res[, c("Ag2O", "FeO")])))

  res <- element_to_oxide(
    df,
    elements = c("Ag", "Fe", "Si", "Sr", "Ba"),
    oxide_preference = "reducing",
    which_concentrations = "no_trace"
  )
  expect_true(all(is.na(res$BaO[2]), is.na(res$SrO[1])))
})

test_that("oxide conversion: errors", {
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Ac"), oxide_preference = "oxidising"),
    regexp = "Oxides of one or more.*"
  )
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Lu"), oxide_preference = "oxidising"),
    regexp = "The following elements.*"
  )
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Si"), oxide_preference = "surprise"),
    regexp = "'oxide_preference' must either.*"
  )
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Si"), oxide_preference = c(Fe = "CuO", Si = "SiO2", Ag = "AgO")),
    regexp = "'oxide_preference' includes invalid combinations.*"
  )
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Si"), oxide_preference = c(Fe = "FeO", Si = "SiO", Ag = "AgO")),
    regexp = "Invalid oxide names.*"
  )
  expect_error(
    element_to_oxide(df, elements = c("Ag", "Fe", "Si"), oxide_preference = c(Fe = "CuO", Si = "SiO2", Xy = "AgO")),
    regexp = "Invalid element names.*"
  )
})

test_that("oxide_to_element converts back correctly", {
  df_ox <- data.frame(
    Ag2O = 5 * 1.07416,
    FeO = 50 * 1.286489,
    SiO2 = 45 * 2.139286
  )

  res <- oxide_to_element(df_ox, oxides = c("Ag2O", "FeO", "SiO2"))
  expect_true(all(c("Ag", "Fe", "Si") %in% names(res)))
  expect_equal(res$Ag, 5, tolerance = 0.1)
  expect_equal(res$Fe, 50, tolerance = 0.1)
  expect_equal(res$Si, 45, tolerance = 0.1)
})

test_that("oxide_to_element: errors", {
  expect_error(
    oxide_to_element(df, oxides = c("Ag2O", "FeO", "SiO2", "Lu2O3")),
    regexp = "The following oxides are not present in df.*"
  )

  expect_error(
    oxide_to_element(data.frame(Ag2O = 5), oxides = c("Ag2O", "FeO")),
    regexp = "The following oxides are not present in df.*"
  )

  # Test for unavailable conversion factors
  df_bad <- data.frame(XyO = 10)
  expect_error(
    oxide_to_element(df_bad, oxides = "XyO"),
    regexp = "Conversion factors for one or more oxides are not available.*"
  )
})

test_that("conversion is reversible", {
  ox <- element_to_oxide(df,
                         elements = c("Ag", "Fe", "Si"),
                         oxide_preference = "reducing")
  el <- oxide_to_element(ox,
                         oxides = c("Ag2O", "FeO", "SiO2"))

  expect_equal(el$Ag, df$Ag, tolerance = 0.1)
  expect_equal(el$Fe, df$Fe, tolerance = 0.1)
  expect_equal(el$Si, df$Si, tolerance = 0.1)
})

test_that("oxide conversion: drop argument", {
  res <- element_to_oxide(df,
    elements = c("Ag", "Fe"),
    oxide_preference = "reducing",
    drop = TRUE
  )
  expect_true(all(!c("Ag", "Fe") %in% names(res)))

  # Test drop in oxide_to_element
  df_ox <- data.frame(
    Ag2O = 5 * 1.07416,
    FeO = 50 * 1.286489,
    other = "keep"
  )
  res_ox <- oxide_to_element(df_ox,
                             oxides = c("Ag2O", "FeO"),
                             drop = TRUE)
  expect_true(all(c("Ag", "Fe", "other") %in% names(res_ox)))
  expect_false(any(c("Ag2O", "FeO") %in% names(res_ox)))
})

test_that("oxide conversion: normalise argument", {
  res <- element_to_oxide(df,
    elements = c("Ag", "Fe", "Si"),
    oxide_preference = "reducing",
    normalise = TRUE
  )
  expect_equal(res$SiO2, c(55.6, 60.5), tolerance = 0.01)
  # Check both rows sum to 100
  expect_equal(rowSums(res[, c("Ag2O", "FeO", "SiO2")]), c(100, 100), tolerance = 0.01)

  # Test normalise in oxide_to_element
  df_ox <- data.frame(
    Ag2O = c(5 * 1.07416, 5 * 1.07416),
    FeO = c(50 * 1.286489, 45 * 1.286489),
    SiO2 = c(45 * 2.139286, 50 * 2.139286)
  )

  res_ox <- oxide_to_element(df_ox,
                             oxides = c("Ag2O", "FeO", "SiO2"),
                             normalise = TRUE)

  # Both rows should sum to 100
  expect_equal(rowSums(res_ox[, c("Ag", "Fe", "Si")]), c(100, 100), tolerance = 0.01)
})

df_math <- data.frame(
  ID = "feldspar",
  O = 48.81,
  Na = 8.77,
  Al = 10.29,
  Si = 32.13
)

test_that("Oxide conversion: math is correct", {
  res <- element_to_oxide(
    df_math,
    elements = names(df_math)[-2:-1],
    oxide_preference = "oxidising",
    normalise = TRUE
  )
  expect_equal(res$Na2O, 11.82, tolerance = 0.01)

  # Test full circle with feldspar data
  res_ox <- element_to_oxide(
    df_math,
    elements = c("Na", "Al", "Si"),
    oxide_preference = "oxidising",
    normalise = TRUE
  )

  res_el <- oxide_to_element(
    res_ox,
    oxides = c("Na2O", "Al2O3", "SiO2"),
    normalise = TRUE
  )

  expect_equal(res_el$Na, df_math$Na, tolerance = 0.1)
  expect_equal(res_el$Al, df_math$Al, tolerance = 0.1)
  expect_equal(res_el$Si, df_math$Si, tolerance = 0.1)
})
