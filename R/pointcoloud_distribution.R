#' Comparing Isotope Samples to Reference Data in 3D Space
#'
#' This package compares isotope samples to reference data in 3D space to identify isotopic consistency and the possibility of mixing between sources.
#'
#' @param wod Working data, with 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#' @param samples Heading of a column with Samples names from working data. Default "samples".
#' @param ref Reference data with 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#' @param groupby Heading of a column with reference group names from reference data. Default "group".
#'
#' @returns
#' List or 3
#' \item{hull_inclustion} Logical value representing the inclustion of working data within the hull of reference data.
#' \item{centroids} Locations of Centroids of each reference group.
#' \item{distances} Distances of each samples point from centroids.
#' @export
#'
#' @examples
pointcoloud_distribution <- function(wod,
                                     samples = "samples",
                                     ref,
                                     groupby = "group") {
  # Get working data list
  wod_points <- wod[grep("204", names(wod))]
  # Finds hull for the ref Data
  ref_hull <- convhulln(ref[grep("204", names(ref))])
  # Checks if working points are within the hull
  hull_inout <- inhulln(ref_hull, as.matrix(wod_points))
  # Identifes unique group names
  groups <- unique(ref[[groupby]])
  # Finds out if the points are within the hull of each indificual group
  group_inout <- sapply(groups, \(i) {
    t <- convhulln(ref[ref[[groupby]] == i, grep("204", names(ref))])
    inhulln(t, as.matrix(wod_points))
  })
  # Combines total and individual in and out logic
  hull_inclustion <- cbind(hull_inout, group_inout)
  # Renames rows of hull_inclustions
  rownames(hull_inclustion) <- wod[[samples]]
  # Calculate centroides
  formula_srt <- paste0(".~`", groupby, "`")
  ref_centroids <- aggregate(as.formula(formula_srt), ref, mean)
  # Calculate distance of each point from centroides
  distances <- cdist(wod[-1], ref_centroids[-1])
  # Rename distance table rows and columns
  rownames(distances) <- wod[[samples]]
  colnames(distances) <- ref_centroids[[groupby]]
  # Creat an output list.
  output <- list(
    "hull_inclustion" = hull_inclustion,
    "centroids" = ref_centroids,
    "distances" = distances
  )
  # Returns Output.
  return(output)
}
