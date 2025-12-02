# test-copper_alloy_bb.R
test_that("Basic alloy classifications work", {
  df <- data.frame(
    ID = 1:3,
    Sn = c(1, 5, 5),
    Zn = c(2, 2, 15),
    Pb = c(0.5, 0.5, 0.5)
  )

  result <- copper_alloy_bb(df)
  expect_equal(result$copper_alloy_bb,
               c("Copper", "Bronze/gunmetal", "Brass/gunmetal"))
})

test_that("Leaded variants work", {
  df <- data.frame(
    ID = 1:2,
    Sn = c(5, 5),
    Zn = c(2, 8),
    Pb = c(6, 10)
  )

  result <- copper_alloy_bb(df)
  expect_equal(result$copper_alloy_bb,
               c("(Leaded) Bronze/gunmetal", "Leaded Gunmetal"))
})

test_that("Custom column names work", {
  df <- data.frame(
    SampleID = 1:2,
    Tin = c(5, 1),
    Zinc = c(12, 20),
    Lead = c(1, 0.5)
  )

  result <- copper_alloy_bb(df,
    elements = c(Sn = "Tin", Zn = "Zinc", Pb = "Lead"),
    id_sample = "SampleID"
  )

  expect_equal(result$copper_alloy_bb, c("Gunmetal", "Brass"))
})
