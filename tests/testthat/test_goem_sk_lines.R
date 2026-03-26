set.seed(50)
df <- data.frame(
  pb64 = rnorm(10, 18, 0.2),
  pb74 = rnorm(10, 15.7, 0.1),
  pb84 = rnorm(10, 37.5, 0.1)
)

p <- ggplot(df, aes(x = pb64, y = pb74)) +
  geom_point() +
  geom_sk_lines(system = "76", show_geochron = FALSE) +
  geom_sk_lines(system = "76", show_isochrons = FALSE) +
  geom_sk_labels(system = "76", show_geochron  = FALSE) +
  geom_sk_labels(system = "76", show_isochrons = FALSE) +
  coord_cartesian(
    xlim = range(df$pb64) * c(.99, 1.01),
    ylim = range(df$pb74) * c(.99, 1.01)
  )

test_that("geom_image", {
  expect_s3_class(p, "ggplot")
  expect_equal(p$layers[[2]]$stat_params$show_geochron, FALSE)
  expect_equal(rlang::as_name(p$mapping$x), "pb64")
  expect_doppelganger("image", p)
})
