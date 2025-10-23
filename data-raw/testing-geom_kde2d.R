
library(tidyverse)
library(ggplot2)
library(ks)
library(rlang)

set.seed(42)
df <- data.frame(
  x = c(rnorm(100), 1),
  y = c(rnorm(100), 10),
  group = rep(c("A", "B"), c(100, 1))
)

ggplot(df, aes(x, y,
               group = group,
               fill = group)) +
  geom_kde2d(alpha = 0.3,
             size = 4) +
  theme_minimal()


# basic use, everything big enough for KDE
library(ggplot2)
ggplot(iris,
       aes(x = Sepal.Length,
           y = Sepal.Width,
           group = Species)) +
  geom_kde2d()


# with data that contain one group too small for kde
 iris |>
   slice(49:n()) |>  # 48 is n = 3, 49 is n = 2, cannot do KDE with n = 2
   ggplot(
     aes(x = Sepal.Length,
         y = Sepal.Width,
         group = Species)) +
   geom_kde2d()  +
   theme_minimal()

 # more aesthetics
 iris |>
   slice(49:n()) |>
 ggplot(
        aes(x = Sepal.Length,
            y = Sepal.Width,
            group = Species,
            fill = Species,
            colour = Species)) +
   geom_kde2d() +
   theme_minimal()

 # with data that contain two groups too small for kde
 mtcars |>
   mutate(gear = as.factor(gear)) |>
   arrange(desc(gear)) |>
  slice(1:2, 7:8, 9:n()) |>
   ggplot(
     aes(x = wt,
         y = qsec,
         group = gear,
         fill = gear)) +
   geom_kde2d()  +
   theme_minimal()

# investigate the clipping situation
# coord_cartesian(clip = "off") helps here
 mtcars |>
   mutate(gear = as.factor(gear)) |>
   arrange(desc(gear)) |>
   slice(1:2, 7:8, 9:n()) |>
   ggplot(
     aes(x = wt,
         y = qsec,
         group = gear,
         fill = gear)) +
   geom_kde2d()  +
   theme_minimal() +
   coord_cartesian(clip = "off")

# not bad here also, with setting the coord_cartesian, I think this is more natural
 # way to handle this
 iris |>
   slice(49:n()) |>  # 48 is n = 3, 49 is n = 2, cannot do KDE with n = 2
   ggplot(
     aes(x = Sepal.Length,
         y = Sepal.Width,
         group = Species)) +
   geom_kde2d()  +
   theme_minimal()  +
   coord_cartesian(xlim = c(4, 9),
                   ylim = c(2, 4),
                   clip = "off")


#-----------------------------------
ad <- read_csv("data-raw/ArgentinaDatabase.csv")

 # 207Pb
ggplot(ad,
       aes(x = `206Pb/204Pb`,
           y = `207Pb/204Pb`,
           fill = `Mining site`)) +
  geom_kde2d(size = 2) +
  theme_minimal()

# 208Pb
ggplot(ad,
       aes(x = `206Pb/204Pb`,
           y = `208Pb/204Pb`,
           fill = `Mining site`)) +
  geom_kde2d(size = 2) +
  theme_minimal()

# 206Pb
ggplot(ad,
       aes(x = `206Pb/204Pb`,
           y = `206Pb/207Pb`,
           fill = `Mining site`)) +
  geom_kde2d(size = 2) +
  theme_minimal()

ggplot(ad,
       aes(x = `207Pb/204Pb`,
           y = `206Pb/207Pb`,
           fill = `Mining site`)) +
  geom_kde2d(size = 2) +
  theme_minimal()

# etc
ggplot(ad,
       aes(x = `208Pb/204Pb`,
           y = `206Pb/204Pb`,
           fill = `Mining site`)) +
  geom_kde2d(size = 2) +
  theme_minimal()



# Error in `geom_kde2d()`:
#   ! Problem while converting geom to grob.
# ℹ Error occurred in the 1st layer.
# Caused by error in `data.frame()`:
#   ! arguments imply differing number of rows: 0, 1
# ---

