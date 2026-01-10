utils::globalVariables("oxide_conversion")

#' Oxide conversion functions
#'
#' Convert between element and oxide weight percent (wt%) compositions using
#' built-in conversion factors. Handles duplicate oxides by summation.
#' Includes options for oxide preference, normalization, and element filtering.
#'
#' @param df Data frame with compositional data.
#' @param elements Character vector of element column names to convert.
#' @param oxides Character vector of oxide column names to convert.
#' @param oxide_preference Either "reducing", "oxidizing", "interactive",
#'        or a named vector mapping elements to specific oxides (e.g., c(Fe = "FeO")).
#' @param which_elements Filter elements: "all", "major" (>1 wt%), or "minor" (>0.1 wt%).
#' @param normalize Logical; normalize converted values to 100%? Default FALSE.
#'
#' @return Data frame with converted columns added. Original columns preserved.
#'
#' @details
#' For `element_to_oxide()`:
#' - Uses built-in conversion factors from `oxide_conversion` dataset
#' - Multiple oxides for same element (e.g., FeO/Fe2O3) are handled via `oxide_preference`
#' - Duplicate outputs (e.g., Fe from FeO and Fe2O3) are summed automatically
#' - Includes optional normalization to 100%
#' - Can filter major/minor elements based on thresholds
#'
#' For `oxide_to_element()`:
#' - Converts oxide percentages back to elemental percentages
#' - Multiple oxides of same element (e.g., FeO + Fe2O3) sum to single element column
#' - Preserves original oxide columns
#'
#' @keywords internal
#' @name oxide_conversion
NULL

#' @rdname oxide_conversion
#' @export
element_to_oxide <- function(
  df,
  elements,
  oxide_preference = NULL,
  which_elements = c("all", "major", "minor"),
  normalize = FALSE
) {

  # Validate inputs
  if (!is.data.frame(df)) {
    stop("df must be a data frame")
  }

  missing <- setdiff(elements, names(df))
  if (length(missing) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing, collapse = ", "))
  }

  which_elements <- match.arg(which_elements)
  conv <- oxide_conversion

  # Handle oxide preference
  if (!is.null(oxide_preference)) {
    if (length(oxide_preference) == 1 && is.character(oxide_preference)) {

      if (oxide_preference == "reducing") {
        # Typical reducing environment oxides
        pref <- c(Fe = "FeO", Mn = "MnO", Cr = "Cr2O3")
      } else if (oxide_preference == "oxidizing") {
        # Typical oxidizing environment oxides
        pref <- c(Fe = "Fe2O3", Mn = "MnO2", Cr = "CrO3")
      } else if (oxide_preference == "interactive") {
        # Interactive selection for each element
        conv <- .interactive_oxide_select(conv, elements)
        pref <- NULL
      } else {
        stop("oxide_preference must be 'reducing', 'oxidizing', 'interactive', ",
             "or a named vector of element-oxide pairs")
      }

    } else if (is.character(oxide_preference) && !is.null(names(oxide_preference))) {
      # Custom named vector provided
      pref <- oxide_preference
    } else {
      stop("oxide_preference must be a named character vector or one of: ",
           "'reducing', 'oxidizing', 'interactive'")
    }

    # Apply oxide preference filter
    if (!is.null(pref)) {
      for (el in names(pref)) {
        conv <- conv[!(conv$Element == el & conv$Oxide != pref[[el]]), ]
      }
    }
  }

  # Filter conversion table for requested elements
  conv <- conv[conv$Element %in% elements, ]

  # Remove any remaining duplicates (keep first occurrence)
  conv <- conv[!duplicated(conv$Element), ]
  rownames(conv) <- conv$Element

  # Intersect with available elements
  elements <- intersect(elements, rownames(conv))
  if (!length(elements)) {
    warning("No valid elements found for conversion")
    return(df)
  }

  # Extract and convert element values
  x <- as.matrix(df[elements])
  storage.mode(x) <- "double"

  # Apply major/minor filter
  if (which_elements != "all") {
    thr <- if (which_elements == "major") 1.0 else 0.1
    x[x <= thr] <- NA_real_
  }

  # Convert elements to oxides
  factors <- conv[elements, "element_to_oxide"]
  oxides <- sweep(x, 2, factors, "*")
  colnames(oxides) <- conv[elements, "Oxide"]

  # Sum duplicate oxides (if multiple elements map to same oxide)
  oxides <- .sum_duplicates(oxides)

  # Normalize if requested
  if (normalize) {
    oxides <- .normalize_rows(oxides)
  }

  # Add oxide columns to output
  out <- df
  for (nm in colnames(oxides)) {
    out[[nm]] <- oxides[, nm]
  }

  return(out)
}

#' @rdname oxide_conversion
#' @export
oxide_to_element <- function(df, oxides, normalize = FALSE) {

  # Validate inputs
  if (!is.data.frame(df)) {
    stop("df must be a data frame")
  }

  missing <- setdiff(oxides, names(df))
  if (length(missing) > 0) {
    stop("The following oxides are not present in df: ",
         paste(missing, collapse = ", "))
  }

  conv <- oxide_conversion

  # Filter for requested oxides
  conv <- conv[conv$Oxide %in% oxides, ]

  if (nrow(conv) == 0) {
    warning("No valid oxides found for conversion")
    return(df)
  }

  # Use Oxide as row names for indexing
  rownames(conv) <- conv$Oxide

  # Ensure all oxides are in conversion table
  oxides <- intersect(oxides, rownames(conv))
  if (!length(oxides)) {
    warning("No matching oxides found in conversion table")
    return(df)
  }

  # Extract and convert oxide values
  x <- as.matrix(df[oxides])
  storage.mode(x) <- "double"

  # Convert oxides to elements
  factors <- conv[oxides, "oxide_to_element"]
  elements <- sweep(x, 2, factors, "*")
  colnames(elements) <- conv[oxides, "Element"]

  # Sum duplicate elements (e.g., Fe from FeO + Fe2O3)
  elements <- .sum_duplicates(elements)

  # Normalize if requested
  if (normalize) {
    elements <- .normalize_rows(elements)
  }

  # Add element columns to output
  out <- df
  for (nm in colnames(elements)) {
    out[[nm]] <- elements[, nm]
  }

  return(out)
}

# Helper function for interactive oxide selection
.interactive_oxide_select <- function(conv, elements) {
  cat("Interactive oxide selection:\n")
  for (el in elements) {
    ox <- conv$Oxide[conv$Element == el]
    if (length(ox) <= 1) next

    cat("\nElement:", el, "\n")
    cat("Available oxides:", paste(ox, collapse = ", "), "\n")

    repeat {
      choice <- readline(paste("Choose oxide for", el, ": "))
      if (choice %in% ox) break
      cat("Invalid choice. Please select from:", paste(ox, collapse = ", "), "\n")
    }

    conv <- conv[!(conv$Element == el & conv$Oxide != choice), ]
  }

  cat("\nSelection complete.\n")
  return(conv)
}

# Sum duplicate columns (e.g., Fe from FeO and Fe2O3)
.sum_duplicates <- function(mat) {
  if (ncol(mat) == 0) return(mat)

  unique_names <- unique(colnames(mat))
  if (length(unique_names) == ncol(mat)) {
    return(mat)  # No duplicates
  }

  res <- matrix(0, nrow(mat), length(unique_names))
  colnames(res) <- unique_names

  for (nm in unique_names) {
    idx <- which(colnames(mat) == nm)
    if (length(idx) == 1) {
      res[, nm] <- mat[, idx]
    } else {
      res[, nm] <- rowSums(mat[, idx, drop = FALSE], na.rm = TRUE)
    }
  }

  return(res)
}

# Normalize rows to 100%
.normalize_rows <- function(mat) {
  if (ncol(mat) == 0) return(mat)

  row_sums <- rowSums(mat, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  # Normalize and return as percentages
  sweep(mat, 1, row_sums, "/") * 100
}
