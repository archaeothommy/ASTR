# tests/testthat/test_atomic_conversion.R

#element wt% to Atomic wt%
test_that("wt_to_at converts correctly", {
  df <- data.frame(Si = 46.74, O = 53.26)
  result <- wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
  expect_true("Si_at" %in% names(result))
  expect_true("O_at" %in% names(result))
})

#Atomic wt% to element wt%
test_that("at_to_wt converts back", {
  df <- data.frame(Si = 33.33, O = 66.67)
  result <- at_to_wt(df, elements = c("Si", "O"))
  expect_true("Si" %in% names(result))
  expect_true("O" %in% names(result))
})

test_that("atomic conversions are reversible", {
  df <- data.frame(Si = 46.74, O = 53.26)
  at <- wt_to_at(df, elements = c("Si", "O"))
  wt <- at_to_wt(at, elements = c("Si", "O"))
  expect_equal(wt$Si, df$Si, tolerance = 0.1)
  expect_equal(wt$O, df$O, tolerance = 0.1)
})

test_that("wt_to_at returns correct atomic values for SiO2", {
  df <- data.frame(Si = 46.74, O = 53.26)
  res <- wt_to_at(df, elements = c("Si", "O"))

  expect_equal(res$Si, 33.33, tolerance = 0.1)
  expect_equal(res$O, 66.67, tolerance = 0.1)
  expect_equal(rowSums(res), 100, tolerance = 1e-6)
})

test_that("at_to_wt returns correct weight values for SiO2", {
  df <- data.frame(Si = 33.33, O = 66.67)
  res <- at_to_wt(df, elements = c("Si", "O"))

  expect_equal(res$Si, 46.74, tolerance = 0.1)
  expect_equal(res$O, 53.26, tolerance = 0.1)
  expect_equal(rowSums(res), 100, tolerance = 1e-6)
})

test_that("drop argument behaves correctly", {
  df <- data.frame(Si = 46.74, O = 53.26, Al = 0)

  res_keep <- wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
  expect_true("Si_at" %in% names(res_keep))
  expect_true("O_at" %in% names(res_keep))
  expect_true("Al" %in% names(res_keep))

  res_drop <- wt_to_at(df, elements = c("Si", "O"), drop = TRUE)
  expect_true("Si" %in% names(res_drop))
  expect_false("Si_at" %in% names(res_drop))
})

test_that("missing or invalid elements throw errors", {
  df <- data.frame(Si = 46.74)

  expect_error(
    wt_to_at(df, elements = c("Si", "O"))
  )

  expect_error(
    wt_to_at(data.frame(Xx = 10), elements = "Xx")
  )
})

test_that("converted values stay within physical bounds", {
  df <- data.frame(Si = 46.74, O = 53.26)
  at <- wt_to_at(df, elements = c("Si", "O"))

  expect_true(all(at >= 0))
  expect_true(all(at <= 100))
})
