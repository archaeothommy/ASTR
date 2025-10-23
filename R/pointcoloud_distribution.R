pointcoloud_distribution <- function(wod, samples = "Samples",
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
