#####
# Mixing Model testing
#####

# Check If you have minimal amout of points. Issue waring.

# ---- Import ----
library(readxl)
library(geometry)
library(rdist)

# ---- Loading Data ----

art_trace <- read_excel(path = "data/mixing_modles_test_data.xlsx",
           sheet = "art_trace",
           range = "A2:I25")
# dust <- read_excel(path = "data/mixing_modles_test_data.xlsx",
#                         sheet = "Dust",
#                         range = "A3:H8")

ref_data <- read_excel("data/database-2025_lia.xlsx",
                       sheet = "Directly usable data")

# ---- Function 1 ----

# Select Relevant Col

cols_pb <- names(art_trace)[grepl("Pb", names(art_trace)) & !grepl("err", names(art_trace))]

art_trace_iso <- art_trace[, cols_pb]

# Create a 3d convex hull
art_trace_hull <- art_trace_iso[chull(art_trace_iso),]

# Find the Centroid of the R

centroid <- colMeans(art_trace_iso)
#centroid <- colMeans(art_trace_hull)

art_trace_hull_centroid <- rbind(art_trace_hull, centroid)

# Find the distance of Hull points from Centroid

distance <- pdist(art_trace_hull_centroid)

art_trace_hull_centroid$ditance_from_euc <- distance[nrow(distance),]

art_trace_hull_furthest <- tail(art_trace_hull_centroid[order(art_trace_hull_centroid$ditance_from_euc),],
     n = 4)

# ---- Ref data identification ----

ref_data <- ref_data[c("corrected Region", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")]

distance_matrix <- as.data.frame(cdist(ref_data[2:4], art_trace_hull_furthest[1:3]))

ncol(distance_matrix)

# for(i in seq(ncol(distance_matrix))){
# table(ref_data[rownames(distance_matrix[distance_matrix[i] <= 0.05,]), "corrected Region"]) |>
#   sort(decreasing = TRUE) |>
#   head(5) |>
#     as.data.frame() |>
#     print()
#   }

# ---- Ploting -----

# Plot Genral data
source("R/isocron.R")
plot(art_trace_iso$`206Pb/204Pb`, art_trace_iso$`208Pb/204Pb`)
isocron86()
points(centroid["206Pb/204Pb"], centroid["208Pb/204Pb"], col = 'blue', cex = 5)
points(art_trace_hull_furthest$`206Pb/204Pb`, art_trace_hull_furthest$`208Pb/204Pb`, pch = 16)
points(art_trace_hull$`206Pb/204Pb`, art_trace_hull$`208Pb/204Pb`, col = "red")

plot(art_trace_iso$`206Pb/204Pb`, art_trace_iso$`207Pb/204Pb`)
isocron76()
points(centroid["206Pb/204Pb"], centroid["207Pb/204Pb"], col = 'blue', cex = 5)
points(art_trace_hull_furthest$`206Pb/204Pb`, art_trace_hull_furthest$`207Pb/204Pb`, pch = 16)
points(art_trace_hull$`206Pb/204Pb`, art_trace_hull$`207Pb/204Pb`, col = "red")
