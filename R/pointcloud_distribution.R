#' Comparing Isotope Samples to Reference Data in 3D Space
#'
#' This package compares isotope samples to reference data in 3D space to
#' identify isotopic consistency and the possibility of mixing between sources.
#'
#' @param df Data frame with sample data, including isotope ratios and ID
#'   columns.
#' @param ref Data frame with reference data, including isotope ratios and group
#'   column.
#' @param isotope_sample,isotope_ref Character vectors with column names of
#'   isotope ratios. Default to `c("206Pb/204Pb", "207Pb/204Pb",
#'   "208Pb/204Pb")`.
#' @param id_sample,id_ref String with the column name of the sample IDs and
#'   identifier for the reference groups. Default `ID`.
#'
#' @returns A `list` of three elements:
#'
#' * in_hull: `logical`. Boolean value indicating the **inclusion** of sample
#' data within the convex **hull** of the reference data.
#' * centroids: `data.frame`. The coordinates of the **centroids** (mean values)
#'  for each defined reference group.
#' * distances: `matrix`. A distance **matrix** where rows represent the samples
#'  and columns represent the reference **centroids**, containing the distance
#'  of each sample from each centroid.
#'
#' @details Calculates the **convex hull** for the complete set of reference
#' points and all specified **subgroups**. It determines the inclusion or
#' exclusion of sample **isotope values** within these hulls.
#'
#' The function also calculates:
#' * The **centroid** of each reference subgroup as **mean value** of points
#' within each vertex group.
#' * The **distance** from each sample point to every subgroup's centroid.
#'
#' Interpretation: Inclusion within a hull suggests the sample is part of
#' the **mixing group** (main hull) or is highly likely to be the specific **end
#' member** (subgroup hull). The distance calculation provides a measure of
#' proximity to these end member centers.
#'
#' @importFrom geometry convhulln inhulln
#' @importFrom  rdist cdist
#' @importFrom stats aggregate as.formula
#'
#' @export
#'
#' @examples
#' # Create synthetic data
#' set.seed(24021999)
#' iso <- c("206Pb/204Pb","207Pb/204Pb","208Pb/204Pb")
#'
#' # Create synthetic reference data
#' groups <- LETTERS[1:4]
#' rand_iso <- function(){c(runif(1, 18.3, 19), runif(1, 15.5, 15.9), runif(1, 37.5, 39))}
#' list_df <- lapply(groups, function(x){
#'   ls <- sapply(rand_iso(),  function(g){stats::rnorm(20, g, stats::runif(1, 0.05, 0.1))})
#'   colnames(ls) <- iso
#'   ls <- as.data.frame(ls)
#'   ls$ID <- x
#'   ls
#' })
#' ref <- as.data.frame(do.call(rbind, list_df))
#'
#' ## Create sample data
#' df <- as.data.frame(sapply(rand_iso(),  function(g){rnorm(20, g, 0.1)}))
#' colnames(df) <- iso
#' df$ID <- letters[1:20]
#' rm(list_df, iso, groups, rand_iso)
#'
#' # Run pointcloud_distribution
#' pointcloud_distribution(df, ref, isotope_sample = c("206Pb/204Pb",
#' "207Pb/204Pb", "208Pb/204Pb"), id_sample = "ID")
#'
#' # cleanup
#' rm(df, ref)
pointcloud_distribution <- function(df,
                                    ref,
                                    isotope_sample = c("206Pb/204Pb",
                                                       "207Pb/204Pb",
                                                       "208Pb/204Pb"),
                                    isotope_ref = isotope_sample,
                                    id_sample = "ID",
                                    id_ref = id_sample) {
  # Checks for isotope columns
  if (length(isotope_sample) != 3) {
    stop("isotope_sample must have exactly 3 values.")
  }

  if (length(isotope_ref) != 3) {
    stop("isotope_ref must have exactly 3 values.")
  }

  # Checks for Sample ID cols
  if (!(id_sample %in% names(df))) {
    stop("Sample ID not found in sample data.")
  }

  if (!(id_ref %in% names(ref))) {
    stop("Reference group columns not found in reference data.")
  }

  # Get working data list
  df_points <- df[isotope_sample]

  # Get Ref data list
  ref <- ref[, c(id_ref, isotope_ref)]

  # Find hull for the ref Data
  ref_hull <- geometry::convhulln(ref[isotope_ref])

  # Checks if working points are within the hull
  hull_inout <- geometry::inhulln(ref_hull, as.matrix(df_points))

  # Check if any points are in hull or throw message
  if (!(TRUE %in% hull_inout)) {
    message("No samples points located within reference hull.")
  }

  # Identifies unique group names
  groups <- unique(ref[[id_ref]])

  # Finds out if points are within the hull of each individual group
  group_inout <- sapply(groups, function(i) {
    t <- geometry::convhulln(ref[ref[[id_ref]] == i, isotope_ref])
    geometry::inhulln(t, as.matrix(df_points))
  })

  # Combines total and individual in and out logic
  hull_inclusion <- cbind(hull_inout, group_inout)

  # Renames rows of hull_inclusions
  rownames(hull_inclusion) <- df[[id_sample]]

  # Calculate centroids
  formula_srt <- paste0(".~`", id_ref, "`")
  ref_centroids <- aggregate(as.formula(formula_srt), ref, mean)

  # Calculate distance of each point from centroids
  distances <- rdist::cdist(df[isotope_sample], ref_centroids[isotope_ref])

  # Rename distance table rows and columns
  rownames(distances) <- df[[id_sample]]
  colnames(distances) <- ref_centroids[[id_ref]]

  # Create an output list
  output <- list(
    "in_hull" = hull_inclusion,
    "centroids" = ref_centroids,
    "distances" = distances
  )

  # Returns Output
  return(output)
}
