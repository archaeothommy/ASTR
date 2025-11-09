# Creaete Synthetic Data
set.seed(22041999)
iso <- c("206Pb/204Pb","207Pb/204Pb","208Pb/204Pb")
## Create Synthetic Reference data
groups <- LETTERS[1:4]
rand_iso <- \(){c(runif(1, 18.3, 19), runif(1, 15.5, 15.9), runif(1, 37.5, 39))}
list_df <- lapply(groups, \(x){
   ls <- sapply(rand_iso(),  \(g){stats::rnorm(20, g, stats::runif(1, 0.05, 0.1))})
 colnames(ls) <- iso
 ls <- as.data.frame(ls)
 ls$ID <- x
 ls
})
ref <- as.data.frame(do.call(rbind, list_df))
## Create working data
df <- as.data.frame(sapply(rand_iso(),  \(g){rnorm(20, g, 0.1)}))
colnames(df) <- iso
df$ID <- letters[1:20]
rm(list_df, iso, groups, rand_iso)

test_that("pointcloud_distribution", {
  expect_type(pointcloud_distribution(df, ref), "list")
  suppressMessages({expect_message(pointcloud_distribution(df, ref))})
  expect_error(pointcloud_distribution(df))
  expect_error(pointcloud_distribution(df, ref, isotope_sample = "204"))
  expect_error(pointcloud_distribution(df, ref, id_sample = "id"))
})
