#' Find Endmembers from a list of LIA points
#'
#' @description
#' Finds endmembers from a set of
#' Lead Isotope Points using Principle Component
#' analysis and the Geochron slope according to the two-stage model.
#'
#' @param x data.frame or matrix object containing
#' Pb 206/204, 207/204, 208/204 isotope ratios.
#' @param col Isotope column names containing Pb
#' 206/204, 207/204, 208/204 isotope ratios.
#' Names must contains the significant numbers 6, 7 and 8.
#' @param tolerance Vector of length two, with corresponding group 1 and group
#'  2 tolerance value for points considered to be intercepted.
#'      (Default c(0.01, 0.01))
#' @param clamp Limit filter for points away from the principle component end
#' based on Euclidean distance, (Default c(Inf, Inf))
#' @param ... Additional Parameters
#'
#' @returns
#' An object of class 'pbisoendmembers' as a list of 6
#'      \item{data}{Isotope data}
#'      \item{pca_ends}{Endmembers maped using PCA}
#'      \item{group1,group2}{End member groups}
#'      \item{mixing}{Mixing Group}
#'      \item{tolerance}{Totlarance value}
#'      \item{clamp}{Clamping values}
#'      \item{pca}{List of PCA analysis}
#' @importFrom stats prcomp shapiro.test
#' @export
#' @examples
#'
#' # Create data structure
#'
#' col_names <- c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")
#' df <- ASTR::ArgentinaDatabase[
#' ASTR::ArgentinaDatabase$`Mining area` == "Distrito El Aguilar",
#' col_names]
#' ref_data <- as.ref_data(ASTR::ArgentinaDatabase, col_names, "Mining area")
#'
#' # Create object with class liaendmembers
#' end_members <- pb_iso_endmembers(
#'         df,
#'         col_names,
#'         tolerance = c(0.01, 0.01),
#'         clamp = c(Inf, Inf)
#' )
#' # Print summary of the liaendmembers object
#' summary(end_members)
#' # Get Uclidian distance
#' isoprov_dist(end_members, ref_data, dist_type = "ed")
#' # Get Mass Fractionnation Corrected distance
#' isoprov_dist(end_members, ref_data, dist_type = "mfd")
#' # Train XGBOOST model on Reference data
#' \dontrun{ml_model <- train_data(ref_data)}
#' # Get XGBOOST predicted ml_resutls
#' isoprov_predict(end_members, ml_model)
pb_iso_endmembers <- function(x,
                       col = NULL,
                       tolerance = c(0.01, 0.01),
                       clamp = c(Inf, Inf),
                       ...) {
  requireNamespace("stats")
  # Argument Checks
  if (!inherits(x, "data.frame") && !inherits(x, "matrix")) {
    stop(paste(deparse(substitute(x)), "is not a dataframe or a matrix"))
  }

  if (is.null(col)) {
    stop("Column names needed!")
  }

  if (length(grep("6|7|8", col)) != 3) {
    stop("Incorrect number or names of colums")
  }

  x <- x[, col]

  if (inherits(x, "data.frame")) {
    x <- as.matrix(x)
  }

  if (!is.numeric(x)) {
    stop("Non-numeric values in dataframe or matrix")
  }
  row.names(x) <- seq_len(nrow(x))

  isotope_matrix <- x
  if (nrow(isotope_matrix) < 3) {
    warning("To few samples. Suggest to  be more than 3")
  }
  # Conduct PCA and check if there are only 2 end memebrs
  pca_result <- prcomp(isotope_matrix, scale = FALSE)
  pca_values <- pca_result$x
  row.names(pca_values) <- row.names(isotope_matrix)
  sum <- summary(pca_result)
  pc1_vla <- sum$importance[["Cumulative Proportion", "PC1"]]
  if (pc1_vla < 0.95) {
    message("PC1 represents less than 95% of the Variance, There may be more than two end members.")
    print(sum)
  }

  # Check if PC2 and PC3 are normally distributed
  norm_test_pc1 <- shapiro.test(pca_values[, "PC1"])$p.value < 0.95
  norm_test_pc2 <- shapiro.test(pca_values[, "PC2"])$p.value > 0.95
  norm_test_pc3 <- shapiro.test(pca_values[, "PC3"])$p.value > 0.95

  if (!(norm_test_pc1 && norm_test_pc2 && norm_test_pc3)) {
    message(
      "PC2 or PC3 are not normally distributed. This may indicate that their variation may not be random noise."
    )
  }

  # Derive end Memebrs
  pca_ends <- pca_values[pca_values[, "PC1"] %in% c(min(pca_values[, "PC1"]), max(pca_values[, "PC1"])), ]

  isotpe_ends <- isotope_matrix[as.numeric(row.names(pca_ends)), ]

  geo_slope <- 0.626208

  end_member_filter <- function(x, tolerance, clamp, ...) {
    geo_intercept <-
      isotpe_ends[x, grep("7", colnames(isotpe_ends))] - isotpe_ends[x, grep("6", colnames(isotpe_ends))] * geo_slope
    point_itercept <- geo_slope * isotope_matrix[, grep("6", colnames(isotpe_ends))] + geo_intercept
    prob_end <- abs(isotope_matrix[, grep("7", colnames(isotpe_ends))] - point_itercept) < tolerance
    geochorn_end <- isotope_matrix[prob_end, , drop = FALSE]

    dist <- apply(geochorn_end, 1, \(a) {
      end <- isotpe_ends[x, ]
      dist <- sqrt(sum((unlist(end) - a)^2))
      dist
    })
    geochorn_end[dist < clamp, , drop = FALSE]
  }

  end_group1 <- end_member_filter(1, tolerance[[1]], clamp[[1]])
  end_group2 <- end_member_filter(2, tolerance[[2]], clamp[[2]])

  if (nrow(end_group1) < 2 || nrow(end_group2) < 2) {
    message(
      "End Member group has less than two points. Likely hood of the point being an endmember is low"
    )
  }
  if (any(row.names(end_group1) %in% row.names(end_group2))) {
    warning("Overlap in endmembers between gorups. Suggest lower tolerance value.")
  }
  mixing_group <- isotope_matrix[-as.integer(c(row.names(end_group1), row.names(end_group2))), ]

  endmember_list <- list(
    data = isotope_matrix,
    pca_ends = isotpe_ends,
    group1 = end_group1,
    group2 = end_group2,
    mixing = mixing_group,
    tolarance = tolerance,
    clamp = clamp,
    pca = pca_result
  )
  endmember_list <-
    structure(endmember_list, class = c("pbisoendmembers", "list"))
  return(endmember_list)
}

#' Summary of LIA Endmember groups
#'
#' Summary of Lead Isotope analysis 'pbisoendmembers' object
#'
#' @param object An object of class "pbisoendmembers"
#' @param ... further arguments passed to or from other methods.
#'
#'
#' @returns
#' A list containing:
#'
#' \item{Counts}{The number of observations in each group}
#' \item{Tolerance}{Tolerance values used in the calculation.}
#' \item{Clamp}{Clamping values used in the calculation.}
#' \item{Data}{A data frame of the lead isotope ratios that were used.}
#'
#' @export
#' @inherit pb_iso_endmembers examples
summary.pbisoendmembers <- function(object, ...) {
  cat("Summary of End memebers:\n\n")
  cat("Tolarance:", object$tolarance, "\n")
  cat("Clamp:", object$clamp, "\n\n")
  cat("PCA Endmembers\n")
  print(object$pca_ends)
  cat("\n")
  count <- data.frame(
    "Group1" = nrow(object$group1),
    "Group2" = nrow(object$group2),
    "Mixing" = nrow(object$mixing),
    "Total" = sum(nrow(object$data))
  )
  row.names(count) <- "Counts"
  print(count)
  cat(rep("-", 18), "\n")
  print(summary(object$pca))
  invisible(
    list(
      "Counts" = unlist(count),
      "Tolarance" = object$tolarance,
      "Clamp" = object$clamp,
      "Data" = object$data
    )
  )
}
