test_that("element_to_oxide converts correctly", {
  conv <- data.frame(
    Element = c("Si", "Fe", "Al"),
    Oxide = c("SiO2", "FeO", "Al2O3"),
    element_to_oxide = c(2.139, 1.286, 1.889),
    oxide_to_element = c(0.467, 0.777, 0.529)
  )

  test_data <- data.frame(Si = c(46.75, 0, NA), Fe = c(5.15, 10, 0), Al = 8.10)

  result <- element_to_oxide(test_data, conv, elements = c("Si", "Fe", "Al"))

  expect_equal(result$SiO2, c(100.0, 0, NA), tolerance = 0.1)
  expect_equal(result$FeO, c(6.62, 12.86, 0), tolerance = 0.1)
  expect_equal(result$Al2O3, c(15.30, 15.30, 15.30), tolerance = 0.1)
})

test_that("oxide_to_element reverses correctly", {
  conv <- data.frame(
    Element = "Si",
    Oxide = "SiO2",
    element_to_oxide = 2.139,
    oxide_to_element = 0.467
  )

  test_data <- data.frame(SiO2 = c(100, 50, 0))

  result <- oxide_to_element(test_data, conv, oxides = "SiO2")

  expect_equal(result$Si, c(46.7, 23.35, 0), tolerance = 0.1)
})
