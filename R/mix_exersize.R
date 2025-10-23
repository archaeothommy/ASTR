#####
# Mixing Model testing
#####

# Check If you have minimal amout of points. Issue waring.

# ---- Import ----
library(readxl)
library(geometry)
library(rdist)

# ---- Loading Data ----

wod <- read_excel(path = "data/mixing_modles_test_data.xlsx",
                  sheet = "art_trace",
                  range = "A2:I25")
# dust <- read_excel(path = "data/mixing_modles_test_data.xlsx",
#                         sheet = "Dust",
#                         range = "A3:H8")

ref <- read_excel("data/database-2025_lia.xlsx",
                  sheet = "Directly usable data")

# ---- Function 1 ----

# Select Relevant Col
#
# cols_pb <- names(art_trace)[grepl("Pb", names(art_trace)) & !grepl("err", names(art_trace))]
#
# art_trace_iso <- art_trace[, cols_pb]
#
# # Create a 3d convex hull
# art_trace_hull <- art_trace_iso[chull(art_trace_iso),]
#
# # Find the Centroid of the R
#
# centroid <- colMeans(art_trace_iso)
# #centroid <- colMeans(art_trace_hull)
#
# art_trace_hull_centroid <- rbind(art_trace_hull, centroid)
#
# # Find the distance of Hull points from Centroid
#
# distance <- pdist(art_trace_hull_centroid)
#
# art_trace_hull_centroid$ditance_from_euc <- distance[nrow(distance),]
#
# art_trace_hull_furthest <- tail(art_trace_hull_centroid[order(art_trace_hull_centroid$ditance_from_euc),],
#      n = 4)
#
# # ---- Ref data identification ----
#
# ref_data <- ref_data[c("corrected Region", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")]
#
# distance_matrix <- as.data.frame(cdist(ref_data[2:4], art_trace_hull_furthest[1:3]))
#
# ncol(distance_matrix)

# for(i in seq(ncol(distance_matrix))){
# table(ref_data[rownames(distance_matrix[distance_matrix[i] <= 0.05,]), "corrected Region"]) |>
#   sort(decreasing = TRUE) |>
#   head(5) |>
#     as.data.frame() |>
#     print()
#   }

# ---- Ploting -----

# # Plot Genral data
# source("R/isocron.R")
# plot(art_trace_iso$`206Pb/204Pb`, art_trace_iso$`208Pb/204Pb`)
# isocron86()
# points(centroid["206Pb/204Pb"], centroid["208Pb/204Pb"], col = 'blue', cex = 5)
# points(art_trace_hull_furthest$`206Pb/204Pb`, art_trace_hull_furthest$`208Pb/204Pb`, pch = 16)
# points(art_trace_hull$`206Pb/204Pb`, art_trace_hull$`208Pb/204Pb`, col = "red")
#
# plot(art_trace_iso$`206Pb/204Pb`, art_trace_iso$`207Pb/204Pb`)
# isocron76()
# points(centroid["206Pb/204Pb"], centroid["207Pb/204Pb"], col = 'blue', cex = 5)
# points(art_trace_hull_furthest$`206Pb/204Pb`, art_trace_hull_furthest$`207Pb/204Pb`, pch = 16)
# points(art_trace_hull$`206Pb/204Pb`, art_trace_hull$`207Pb/204Pb`, col = "red")

# ---- Day 2 ----

# Loading and cleaning of Ref Data.
ref <- read_excel("data/mixing_modles_reference_data.xlsx",
                  sheet = "9th_hoards")
ref <- ref[ref$half_ninth == "first",]
ref_2 <- read_excel("data/mixing_modles_reference_data.xlsx",
                    sheet = "early_Carolingian_coinage")
ref_2 <- ref_2[c("Group", grep("204", names(ref_2), value = TRUE))]
ref <- ref[c("Place", grep("204", names(ref), value = TRUE))]
colnames(ref_2) <- colnames(ref)
ref <- rbind(ref, ref_2)
rm(ref_2)
ref_hull <- ref[chull(ref[c(grep("204", names(ref)))]),]

# Ploting of Ref Data

plot(ref$Pb206_204, ref$Pb207_204, col = as.factor(ref$Place))

points(ref_hull$Pb206_204, ref_hull$Pb207_204, pch = 16)

# Console function for Hull size

# hull_centroid <- colMeans(ref_hull[-1])
# scalefactor <- 1.5
# scaled_hull <- as.data.frame(t(apply(ref_hull[-1], 1, function(p) {
#   hull_centroid + scalefactor * (p - hull_centroid)
# })))
#
# plot(scaled_hull$Pb206_204, scaled_hull$Pb207_204)
# points(ref$Pb206_204, ref$Pb207_204, col = as.factor(ref$Place), pch = 3)
# points(ref_hull$Pb206_204, ref_hull$Pb207_204, pch = 10)

# Console function Centroid Scaleing
#
# centroids <- aggregate(.~Place, ref, mean)
# centroid_centroids <- colMeans(centroids[-1])
# scalefactor <-5
# scaled_centroids <- as.data.frame(t(apply(centroids[-1], 1, function(p) {
#   centroid_centroids + scalefactor * (p - centroid_centroids)
# })))
# plot(scaled_centroids$Pb206_204, scaled_centroids$Pb207_204)
# points(centroids$Pb206_204, centroids$Pb207_204, pch = 10)
# points(ref$Pb206_204, ref$Pb207_204, col = as.factor(ref$Place), pch = 3)

# Hull Centroid

# centroids_hull <- aggregate(.~Place, ref_hull, mean)
# centroid_centroids <- colMeans(centroids_hull[-1])
# scalefactor <-2
# scaled_centroids <- as.data.frame(t(apply(centroids_hull[-1], 1, function(p) {
#   centroid_centroids + scalefactor * (p - centroid_centroids)
# })))
# plot(scaled_centroids$Pb206_204, scaled_centroids$Pb207_204)
# points(ref_hull$Pb206_204, ref_hull$Pb207_204, pch = 16)
# points(centroids_hull$Pb206_204, centroids_hull$Pb207_204, pch = 10)
# points(ref$Pb206_204, ref$Pb207_204, col = as.factor(ref$Place), pch = 3)

# Hull In and out
wod
ref
ref_centroids <- aggregate(.~Place, ref, mean)
ref_hull <- convhulln(ref[grep("204", names(ref))])
inhulln(ref_hull, as.matrix(ref[grep("204", names(ref))]))
groups <- unique(ref$Place)



# Isotope Points from the working Area
wod_points <- wod[names(wod) %in% names(wod)[grepl("204", names(wod)) & !grepl("err", names(wod))]]
inhulln(ref_hull, as.matrix(wod_points))

# Check if points are in larger environment

hull_inout <- inhulln(convhulln(ref[grep("204", names(ref))]),as.matrix(wod_points))

# Check if points are in individual Hulls
group_inout <- sapply(groups, \(i){t <- convhulln(ref[ref$Place == i, grep("204", names(ref))])
inhulln(t, as.matrix(wod_points))
})

cbind( hull_inout, group_inout)

# Function

hull_inclustion <- function(wod, ref, groupby = "Place"){
  ref_hull <- convhulln(ref[grep("204", names(ref))])
  hull_inout <- inhulln(ref_hull,as.matrix(wod))
  groups <- unique(ref[[groupby]])
  group_inout <- sapply(groups,
                        \(i){t <- convhulln(ref[ref[[groupby]] == i, grep("204", names(ref))])
                        inhulln(t, as.matrix(wod))
                        })
  output <- cbind( hull_inout, group_inout)
  return(output)
}
out <- hull_inclustion(wod_points, ref, "Place")
