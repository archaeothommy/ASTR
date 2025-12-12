test_that("wt_to_at converts correctly", {
  conv <- data.frame(
    Element = c("Si", "O"),
    AtomicWeight = c(28.085, 15.999)
  )

  test_data <- data.frame(Si = c(46.75, 0, NA), O = c(53.25, 100, NA))

  result <- wt_to_at(test_data, conv, elements = c("Si", "O"))
  expect_equal(result$Si_at, c(33.33, 0, NA), tolerance = 0.1)
  expect_equal(result$O_at, c(66.67, 100, NA), tolerance = 0.1)
})

test_that("at_to_wt reverses correctly", {
  conv <- data.frame(
    Element = c("Si", "O"),
    AtomicWeight = c(28.085, 15.999)
  )

  test_data <- data.frame(Si_at = c(33.33, 0, 100), O_at = c(66.67, 100, 0))

  result <- at_to_wt(test_data, conv, elements = c("Si", "O"))
  expect_equal(result$Si, c(46.75, 0, 100), tolerance = 0.1)
  expect_equal(result$O, c(53.25, 100, 0), tolerance = 0.1)
})
