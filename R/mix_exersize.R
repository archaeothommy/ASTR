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

hull_inclustion <- function(wod, samples = "Samples",
                            ref, groupby = "Place"){
  #Get working data list
  wod_points <- wod[grep("204", names(wod))]
  # Finds hull for the ref Data
  ref_hull <- convhulln(ref[grep("204", names(ref))])
  # Checks if working points are within the hull
  hull_inout <- inhulln(ref_hull,as.matrix(wod_points))
  # Identifes unique group names
  groups <- unique(ref[[groupby]])
  # Finds out if the points are within the hull of each indificual group
  group_inout <- sapply(groups,
                        \(i){t <- convhulln(ref[ref[[groupby]] == i,
                                                grep("204", names(ref))]
                                            )
                        inhulln(t, as.matrix(wod_points))})
  # Combines total and Individual in and out logic
  output <- cbind(hull_inout, group_inout)
  rownames(output) <- wod[[samples]]
  formula_srt <- paste0(".~`", groupby,"`")
  ref_centroids <- aggregate(as.formula(formula_srt), ref, mean)
  distances <- cdist(wod[-1], ref_centroids[-1])
  rownames(distances) <- wod[[samples]]
  colnames(distances) <- ref_centroids[[groupby]]
  output <- list("Hull Inclustion" = output,
                 "centroids" = ref_centroids,
                 "distances" = distances)
  return(output)
  # Returns Output.
  return(output)
}

# hull_inclustion(ref[-1], ref, "Place")

centroid_distance <- function(wod,
         samples = "Samples",
         ref,
         groupby = "Place") {
  formula_srt <- paste0(".~`", groupby,"`")
  ref_centroids <- aggregate(as.formula(formula_srt), ref, mean)
  distances <- cdist(wod[-1], ref_centroids[-1])
  rownames(distances) <- wod[[samples]]
  colnames(distances) <- ref_centroids[[groupby]]
  output <- list("centroids" = ref_centroids,
       "distances" = distances)
  return(output)
}
# Hull Inclustion Test

ref <- read_excel("data/REF Salzburg.xlsx")
ref <- na.omit(ref)
ref <- ref[c("ample ID", grep("204", names(ref), value = TRUE))]

wod <- read_excel("data/WOD_Salzburg.xlsx")
wod <- wod[c("Sample", grep("204", names(wod), value = TRUE))]

hull_inclustion(wod, samples = "Sample", ref, "ample ID")
test <- centroid_distance(wod, samples = "Sample", ref, "ample ID")
ref_dist <- centroid_distance(ref, "ample ID", ref, "ample ID")
test_cent <- centroid_distance(test$centroids, samples = "Sample", ref, "ample ID")

rowSums(test$distances)

plot(ref$`206Pb/204Pb`, ref$`207Pb/204Pb`, col = as.factor(ref$`ample ID`))
points(wod$`206Pb/204Pb`, wod$`207Pb/204Pb`, pch = 3)
points(test$centroids$`206Pb/204Pb`, test$centroids$`207Pb/204Pb`,cex = 2, pch = 16)
source("R/isocron.R")
isocron76()
plot(ref$`206Pb/204Pb`, ref$`208Pb/204Pb`, col = as.factor(ref$`ample ID`))
points(wod$`206Pb/204Pb`, wod$`208Pb/204Pb`, pch = 3)
points(test$centroids$`206Pb/204Pb`, test$centroids$`208Pb/204Pb`, cex = 2, pch = 16)
isocron86()

library(Ternary)



TernaryPlot(clab = "Agean", blab = "Spain 1", alab = "Spain 2")
TernaryPoints(test_cent$distances, pch = 16, cex = 2)
TernaryPoints(ref_dist, col = as.factor(rownames(ref_dist)))
