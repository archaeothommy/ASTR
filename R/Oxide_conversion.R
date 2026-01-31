#' Oxide conversion functions
#'
#' Convert between element and oxide weight percent (wt%) compositions using
#' pre-compiled conversion factors.
#'
#' @param df Data frame with compositional data.
#' @param elements character vector with the chemical symbols of the elements
#'   that should be converted.
#' @param oxides character vector with the chemical symbols of the oxides that
#'   should be converted.
#' @param oxide_preference String that controls which oxide should be used if an
#'   element forms more than one oxide. Allowed values are: `reducing`,
#'   `oxidizing`, `ask`, or a named vector mapping the specific oxide to its
#'   element. See details for further information.
#' @param which_concentrations Character string that determines which elements or
#'   oxides are converted based on their concentrations. Allowed values are
#'   `all` (no restriction), `major` (only concentrations >= 1 wt%), or "minor"
#'   (only concentrations >= 0.1 wt%).
#' @param normalise If `TRUE`, converted concentrations will be normalised to
#'   100%. Default to `FALSE`.
#' @param drop If `TRUE`, the default, columns with unconverted values are
#'   dropped. If false, columns with unconverted values are kept.
#'
#' @return The original data frame with the converted concentrations
#'
#' @details If the dataset includes already an element and its respective oxide,
#'   the function leaves the column of the respective oxide or element
#'   unaffected.
#'
#'   In `oxide_to_element()`, conversions from different oxides to the same
#'   element (e.g., Fe_2_O3 and FeO to Fe) result in one column for the element
#'   with the sum of all converted values of the respective element.
#'
#'   In `element_to_oxide()`, the parameter `oxide_preference` controls the
#'   behaviour of the function if the element forms more than one oxide:
#'   * `reducing`: Use the oxide with the highest oxide number of the element
#'   (e.g., `Fe2O3`)
#'   * `oxidising`: Use the oxide with the lowest oxide number of the element
#'   (e.g., `FeO`)
#'   * `ask`: The user is asked for each element which oxide should be used.
#'   * named vector: A named vector mapping the oxides to be used to the
#'   elements (e.g., `c(Fe = "FeO")`)
#'
#'   Conversion factors are pre-compiled for a wide range of oxides.
#'   consequently, conversion is restricted to the oxides on this list. If you
#'   encounter an oxide that is currently not included, please reach out to the
#'   package maintainers or create a pull request to add it.
#'
#' @export
#' @name oxide_conversion
#'
#' @examples
#' # example code
#'

element_to_oxide <- function(
    df,
    elements,
    oxide_preference,
    which_concentrations = c("all", "major", "minor"),
    normalise = FALSE,
    drop = TRUE
) {

  # Validate inputs
  checkmate::assert_data_frame(df)
  checkmate::assert_character(oxide_preference,
                              any.missing = FALSE,
                              all.missing = FALSE
                              )
  checkmate::assert_character(which_concentrations,
                              any.missing = FALSE,
                              all.missing = FALSE,
                              pattern = "all|major|minor"
                              )

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # remove all entries without oxides or conversion factors from reference table
  conversion_oxides <- na.omit(conversion_oxides)

  # Handle oxide preference
  switch (oxide_preference,
    oxidising = {
      pref <- # implement according to documentation
        c(Fe = "Fe2O3", Mn = "MnO2", Cr = "CrO3")

    },
    reducing = {
      pref <- # implement according to documentation
        c(Fe = "FeO", Mn = "MnO", Cr = "Cr2O3")

    },
    ask = {
      conversion_oxides <- interactive_oxide_select(conversion_oxides, elements)
      pref <- NULL
    },
    {

      # check if names are valid elements and oxides are valid oxides and matching to the element


      # checks pass
      pref <- oxide_preference

      # checks not passed: error for each type of fail (elements not valid, oxides not valid)
      stop("'oxide preference' assumed to be a named vector",
           "")

    }
  )

  # Apply oxide preference filter
    if (!is.null(pref)) {
      for (el in names(pref)) {
        conversion_oxides <- conversion_oxides[!(conversion_oxides$Element == el & conversion_oxides$Oxide != pref[[el]]), ]
      }
    }

  # Filter conversion table for requested elements
  conversion_oxides <- conversion_oxides[conversion_oxides$Element %in% elements, ]

  # Remove any remaining duplicates (keep first occurrence)
  conversion_oxides <- conversion_oxides[!duplicated(conversion_oxides$Element), ]
  rownames(conversion_oxides) <- conversion_oxides$Element

  # Intersect with available elements
  elements <- intersect(elements, rownames(conversion_oxides))
  if (!length(elements)) {
    warning("No valid elements found for conversion")
    return(df)
  }

  # Extract and convert element values
  x <- as.matrix(df[elements])
  storage.mode(x) <- "double"

  # Apply major/minor filter --> How do you handle if major and minor elements change between samples?
  switch (which_concentrations,
    all = {},  # leave empty / do nothing (not sure if this works)
    major = {},
    minor = {}
  )

  # if (which_elements != "all") {
  #   thr <- if (which_elements == "major") 1.0 else 0.1
  #   x[x <= thr] <- NA_real_
  # }

  factors <- conversion_oxides[elements, "element_to_oxide"]
  oxides <- sweep(x, 2, factors, "*")
  colnames(oxides) <- conversion_oxides[elements, "Oxide"]

  # Sum duplicate oxides (if multiple elements map to same oxide)
  oxides <- sum_duplicates(oxides)

  # Normalise if requested
  if (normalise) {
    oxides <- normalise_rows(oxides)
  }

  # Add oxide columns to output
  df <- cbind(df, oxides)

  if (drop) {
    df[elements] <- NULL
  }

  return(out)
}

#' @rdname oxide_conversion
#' @export
oxide_to_element <- function(df, oxides, normalise = FALSE, drop = TRUE) {

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
  elements <- sum_duplicates(elements)

  # Normalise if requested
  if (normalise) {
    elements <- normalise_rows(elements)
  }

  # Add element columns to output
  out <- df
  for (nm in colnames(elements)) {
    out[[nm]] <- elements[, nm]
  }

  return(out)
}

#' Interactive oxide selection
#'
#' Provies a selection
#'
#' @keywords internal
#'

# I think this can be simplified.
# There is no need input other than the list of elements
# All other information can be retrieved from the internal data object with the conversion factors
interactive_oxide_select <- function(conv, elements) {
  cat("Interactive oxide selection:\n")
  for (el in elements) {
    ox <- conv$Oxide[conv$Element == el]
    if (length(ox) <= 1) next

    cat("\nElement:", el, "\n")
    cat("Available oxides:", paste0(ox, collapse = ", "), "\n")

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

#' Sum columns with same column name
#' @keywords internal

# This function looks like this could be achieved easier.
# To get list of duplicated column names, think about using something like: values[duplicated(names(values))]
# Remember that R is vector based, meaning that you can do component-wise addition like with any other vector.
# You might need to transform them first though because R always assumes column vectors.
sum_duplicates <- function(values) {

  if (ncol(values) == 0) return(values)

  unique_names <- unique(colnames(values))
  if (length(unique_names) == ncol(values)) {
    return(values)  # No duplicates
  }

  res <- matrix(0, nrow(values), length(unique_names))
  colnames(res) <- unique_names

  for (nm in unique_names) {
    idx <- which(colnames(values) == nm)
    if (length(idx) == 1) {
      res[, nm] <- values[, idx]
    } else {
      res[, nm] <- rowSums(values[, idx, drop = FALSE], na.rm = TRUE)
    }
  }

  return(res)
}

#' Normalise rows to 100%
#'
#' Normalises values in a vector to 100%
#'
#' @keywords internal
normalise_rows <- function(values) {

  checkmate::assert_numeric(values)

  if (ncol(values) == 0) return(values)

  row_sums <- rowSums(values, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  # Normalise and return as percentages
  values / row_sums * 100
}
