# Visual tests ------------------------------------------------------------

test_KDE_df <- data.frame(
  x = c(rnorm(50), rnorm(50, 5), rnorm(2, 10)),
  y = c(rnorm(50), rnorm(50, 5), rnorm(2, 10)),
  group = rep(c("A", "B", "C"), c(50, 50, 2))
)

test_that("geom_image", {
  expect_doppelganger(
    "image",
    ggplot(test_KDE_df, aes(x = x, y = y)) + geom_kde2d(aes(x = x, y = y, colour = group))
  )
})
