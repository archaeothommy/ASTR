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
#' A \code{list} of three elements:
#'
#' \item{hull_inclusion}{\code{logical}. A Boolean value indicating the **inclusion**
#' of the working data (sample points) within the convex **hull** of the reference data.}
#' \item{centroids}{\code{data.frame}. The coordinates (locations) of the **centroids** #' (mean values) for each defined reference group.}
#' \item{distances}{\code{matrix}. A distance **matrix** where rows represent the working data samples
#' and columns represent the reference **centroids**, containing the distance of each sample from each centroid.}
#'
#' @export
#'
#' @examples
#' # Creaete Synthetic Data
#' iso <- c("206Pb/204Pb","207Pb/204Pb","208Pb/204Pb")
#' ## Create Synthetic Reference data
#' groups <- LETTERS[1:4]
#' rand_iso <- \(){c(runif(1, 18.3, 19), runif(1, 15.5, 15.9), runif(1, 37.5, 39))}
#' list_df <- lapply(groups, \(x){
#'   ls <- sapply(rand_iso(),  \(g){stats::rnorm(20, g, stats::runif(1, 0.05, 0.1))})
#'   colnames(ls) <- iso
#'   ls <- as.data.frame(ls)
#'   ls$groups <- x
#'   ls
#' })
#' ref <- as.data.frame(do.call(rbind, list_df))
#' ## Create working data
#' wod <- as.data.frame(sapply(rand_iso(),  \(g){rnorm(20, g, 0.1)}))
#' colnames(wod) <- iso
#' wod$samples <- letters[1:20]
#' rm(list_df, iso, groups, rand_iso)
#' # Run Pointcloud_distribution
#' pointcloud_distribution(ref, "sample", ref, "groups")
pointcloud_distribution <- function(wod,
                                     samples = "samples",
                                     ref,
                                     groupby = "groups") {
  # Get iso names from Wod
  wod_names <- grep("204", names(wod), value = TRUE)
  # Get iso names for Ref
  ref_names <- grep("204", names(ref), value = TRUE)

  # Get working data list
  wod_points <- wod[wod_names]
  # Get Ref data list
  ref <- ref[,c(groupby, ref_names)]
  # Finds hull for the ref Data
  ref_hull <- geometry::convhulln(ref[ref_names])
  # Checks if working points are within the hull
  hull_inout <- geometry::inhulln(ref_hull, as.matrix(wod_points))
  # Identifes unique group names
  groups <- unique(ref[[groupby]])
  # Finds out if the points are within the hull of each indificual group
  group_inout <- sapply(groups, \(i) {
    t <- geometry::convhulln(ref[ref[[groupby]] == i, ref_names])
    geometry::inhulln(t, as.matrix(wod_points))
  })
  # Combines total and individual in and out logic
  hull_inclustion <- cbind(hull_inout, group_inout)
  # Renames rows of hull_inclustions
  rownames(hull_inclustion) <- wod[[samples]]
  # Calculate centroides
  formula_srt <- paste0(".~`", groupby, "`")
  ref_centroids <- aggregate(as.formula(formula_srt), ref, mean)
  # Calculate distance of each point from centroides
  distances <- rdist::cdist(wod[wod_names], ref_centroids[grep("204", names(ref_centroids))]) # Correct this.
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





