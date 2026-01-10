test_that("oxide conversions work", {
  df <- data.frame(Si = 46.75, Fe = 5.15)

  oxides <- element_to_oxide(df, elements = c("Si", "Fe"))
  expect_true(all(c("SiO2", "Fe2O3") %in% names(oxides)))

  elements <- oxide_to_element(oxides, oxides = c("SiO2", "Fe2O3"))
  expect_true(all(c("Si", "Fe") %in% names(elements)))

  oxides_norm <- element_to_oxide(df, elements = c("Si", "Fe"), normalize = TRUE)
  expect_equal(sum(oxides_norm$SiO2, oxides_norm$Fe2O3, na.rm = TRUE), 100, tolerance = 0.1)

  expect_true("FeO" %in% names(element_to_oxide(df, "Fe", "reducing")))
})
