# tests/testthat/test-atomic_conversion.R

#element wt% to Atomic wt%
test_that("wt_to_at converts correctly", {
  df <- data.frame(Si = 46.75, O = 53.25)
  result <- wt_to_at(df, elements = c("Si", "O"))
  expect_true("Si_at" %in% names(result))
  expect_true("O_at" %in% names(result))
})

#Atomic wt% to element wt%
test_that("at_to_wt converts back", {
  df <- data.frame(Si_at = 33.33, O_at = 66.67)
  result <- at_to_wt(df, elements = c("Si", "O"))
  expect_true("Si" %in% names(result))
  expect_true("O" %in% names(result))
})

test_that("atomic conversions are reversible", {
  df <- data.frame(Si = 46.75, O = 53.25)
  at <- wt_to_at(df, elements = c("Si", "O"))
  wt <- at_to_wt(at, elements = c("Si", "O"))
  expect_equal(wt$Si, df$Si, tolerance = 0.1)
  expect_equal(wt$O, df$O, tolerance = 0.1)
})
