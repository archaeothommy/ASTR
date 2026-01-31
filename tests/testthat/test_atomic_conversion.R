# tests/testthat/test_atomic_conversion.R

df <- data.frame(metadata = "R2D2", Si = 46.74, O = 53.26)
df2 <- data.frame(metadata = "R2D2", Si = 33.33, O = 66.67)

res <- wt_to_at(df, elements = c("Si", "O"))
res2 <- at_to_wt(df2, elements = c("Si", "O"))

#element wt% to Atomic wt%
test_that("wt_to_at converts correctly", {
  expect_true("Si" %in% names(res))
  expect_equal(res$O, 66.67, tolerance = 0.1)
  expect_equal(rowSums(res[2:3]), 100, tolerance = 1e-6)
  expect_false("Si_at" %in% names(res))
})

#Atomic wt% to element wt%
test_that("at_to_wt converts correctly", {
  expect_true("Si" %in% names(res2))
  expect_equal(res2$O, 53.26, tolerance = 0.1)
  expect_equal(rowSums(res2[2:3]), 100, tolerance = 1e-6)
  expect_false("Si_at" %in% names(res2))
})

test_that("atomic conversions are reversible", {
  at <- wt_to_at(df, elements = c("Si", "O"))
  wt <- at_to_wt(at, elements = c("Si", "O"))
  expect_equal(wt$Si, df$Si, tolerance = 0.1)
  expect_equal(wt$O, df$O, tolerance = 0.1)
})

test_that("drop argument behaves correctly", {
  res_keep <- wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
  expect_true("Si_at" %in% names(res_keep))
  expect_true("Si" %in% names(res_keep))

  res2_keep <- at_to_wt(df2, elements = c("Si", "O"), drop = FALSE)
  expect_true("Si_wt" %in% names(res2_keep))
  expect_true("Si" %in% names(res2_keep))
})

test_that("converted values stay within physical bounds", {
  expect_true(all(res[2:3] >= 0) & all(res[2:3] <= 100))
  expect_true(all(res2[2:3] >= 0) & all(res2[2:3] <= 100))
})

test_that("functions throw correct errors where intended", {
  expect_error(wt_to_at(data.frame(Si = 46.74), elements = c("Si", "O")),
               regexp = "The following elements are not present*"
               )
  expect_error(at_to_wt(data.frame(Xx = 10), elements = "Xx"),
               regexp = "The following are not valid*"
               )
  expect_error(wt_to_at("test", elements = "Si"))
})
