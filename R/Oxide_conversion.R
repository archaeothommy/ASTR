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
#'   `oxidising`, `ask`, or a named vector mapping the specific oxide to its
#'   element. See details for further information.
#' @param which_concentrations Character string that determines which elements or
#'   oxides are converted based on their concentrations. Allowed values are
#'   `all` (no restriction), `major` (only concentrations >= 1 wt%), or "minor"
#'   (between 0.1 and 1 wt%).
#' @param normalise If `TRUE`, converted concentrations will be normalised to
#'   100%. Default to `FALSE`.
#' @param drop If `TRUE`, the default, columns with unconverted values are
#'   dropped. If false, columns with unconverted values are kept.
#'
#' @returns The original data frame with the converted concentrations
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
#'   * `oxidising`: Use the oxide with the highest oxidation state of the element
#'   (e.g., `Fe2O3`)
#'   * `reducing`: Use the oxide with the lowest oxidation state of the element
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
#' # Example data frame with element weight percents
#' df <- data.frame(Si = 45, Fe = 10, Cr = 2)
#'
#' # Convert elements to oxides using oxidising preference
#' element_to_oxide(df, elements = c("Si", "Fe", "Cr"), oxide_preference = "oxidising")
#'
#' # Convert elements to oxides using reducing preference
#' element_to_oxide(df, elements = c("Si", "Fe", "Cr"), oxide_preference = "reducing")
#'
#' # Manually specify which oxide to use for each element
#' element_to_oxide(df, elements = c("Fe", "Cr"), oxide_preference = c(Fe = "FeO", Cr = "Cr2O3"))
#'
#' # Preserve original element columns
#' element_to_oxide(df, elements = c("Si", "Fe", "Cr"), oxide_preference = "oxidising", drop = FALSE)
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
  checkmate::assert_character(elements,
    any.missing = FALSE,
    all.missing = FALSE
  )
  checkmate::assert_character(oxide_preference,
    any.missing = FALSE,
    all.missing = FALSE
  )
  checkmate::assert_character(which_concentrations,
    any.missing = FALSE,
    all.missing = FALSE
  )

  which_concentrations <- match.arg(which_concentrations)

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop(
      "The following elements are not present in df: ",
      paste(missing_from_df, collapse = ", ")
    )
  }

  # remove all entries without oxides or conversion factors from reference table
  conversion_table <- na.omit(conversion_oxides)

  # Handle oxide preference
  if (is.character(oxide_preference) && length(oxide_preference) == 1) {
    # Single string preference
    switch(oxide_preference,
      oxidising = {
        ct <- conversion_table[conversion_table$Element %in% elements, ]
        pref <- sapply(elements, function(el) {
          sub <- ct[ct$Element == el, ]
          if (nrow(sub) == 0) return(NA)
          if (nrow(sub) == 1) {
            return(sub$Oxide[1])
          } else {
            return(sub$Oxide[which.max(sub$OxidationState)])
          }
        })
        names(pref) <- elements
        pref <- pref[!is.na(pref)]
      },

      reducing = {
        ct <- conversion_table[conversion_table$Element %in% elements, ]
        pref <- sapply(elements, function(el) {
          sub <- ct[ct$Element == el, ]
          if (nrow(sub) == 0) return(NA)
          if (nrow(sub) == 1) {
            return(sub$Oxide[1])
          } else {
            return(sub$Oxide[which.min(sub$OxidationState)])
          }
        })
        names(pref) <- elements
        pref <- pref[!is.na(pref)]
      },
      ask = {
        pref <- interactive_oxide_select(elements)
      },
      {
        stop("oxide_preference must be 'oxidising', 'reducing', 'ask', or a named vector")
      }
    )
  } else if (is.vector(oxide_preference) && !is.null(names(oxide_preference))) {
    # Named vector preference
    # check names are valid elements
    invalid_elements <- setdiff(names(oxide_preference), conversion_oxides$Element)
    if (length(invalid_elements) > 0) {
      stop("Invalid element names in 'oxide_preference': ",
           paste(invalid_elements, collapse = ", "))
    }

    # check values are valid oxides
    invalid_oxides <- setdiff(oxide_preference, conversion_oxides$Oxide)
    if (length(invalid_oxides) > 0) {
      stop("Invalid oxide names in 'oxide_preference': ",
           paste(invalid_oxides, collapse = ", "))
    }

    # check that the element actually produces the specified oxide
    for (el in names(oxide_preference)) {
      ox <- conversion_oxides$Oxide[conversion_oxides$Element == el]
      if (!(oxide_preference[el] %in% ox)) {
        stop(sprintf("Element %s does not produce oxide %s", el, oxide_preference[el]))
      }
    }

    # checks pass
    pref <- oxide_preference
  } else {
    stop("oxide_preference must be a character string or a named vector")
  }

  # Apply oxide preference filter
  if (!is.null(pref)) {
    for (el in names(pref)) {
      conversion_table <- conversion_table[!(conversion_table$Element == el & conversion_table$Oxide != pref[[el]]), ]
    }
  }

  # Filter conversion table for requested elements
  conversion_table <- conversion_table[conversion_table$Element %in% elements, ]

  # Remove any remaining duplicates (keep first occurrence)
  conversion_table <- conversion_table[!duplicated(conversion_table$Element), ]
  rownames(conversion_table) <- conversion_table$Element

  # Extract and convert element values
  x <- as.matrix(df[elements])
  storage.mode(x) <- "double"

  # Apply major/minor filter
  switch(which_concentrations,
    all = {
      # do nothing, convert all
    },
    major = {
      # Only convert elements >= 1 wt%
      x[x < 1] <- 0
    },
    minor = {
      # Only convert elements (0.1 - 1 wt%)
      x[x < 0.1 | x >= 1] <- 0
    }
  )

  if (!all(elements %in% conversion_table$Element)) {
    stop("Not all requested elements have matching oxides in conversion table")
  }

  factors <- conversion_table[elements, "ElementToOxide"]
  oxides <- sweep(x, 2, factors, "*")
  colnames(oxides) <- conversion_table[elements, "Oxide"]

  # Normalise if requested
  if (normalise) {
    oxides <- normalise_rows(oxides)
  }

  # Add oxide columns to output
  df <- cbind(df, oxides)

  if (drop) {
    df[elements] <- NULL
  }

  return(df)
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
    stop(
      "The following oxides are not present in df: ",
      paste(missing, collapse = ", ")
    )
  }

  conv <- conversion_oxides

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
  factors <- conv[oxides, "OxideToElement"]
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

  if (drop) {
    out[oxides] <- NULL
  }

  return(out)
}

#' Interactive oxide selection
#'
#' Provides a selection
#'
#' @returns named vector with all oxides for the supplied list of elements
#'
#' @keywords internal
#'
interactive_oxide_select <- function(elements) {
  message("Starting interactive selection of oxides")

  oxides <- setNames(elements, elements)

  for (el in elements) {
    ox <- conversion_oxides$Oxide[conversion_oxides$Element == el]

    if (length(ox) > 1) {
      choice <- readline(
        paste0("Choose oxide for ", el, " [available: ", paste0(ox, collapse = ", "), "]: ")
      )

      repeat {
        if (choice %in% ox) break
        choice <- readline(
          paste0("Invalid input. Please choose from the available oxides [", paste0(ox, collapse = ", "), "]: ")
        )
      }
    } else {
      choice <- ox
    }

    oxides[el] <- choice
  }

  message("Selection complete")
  return(oxides)
}

#' Sum columns with same column name
#'
#' The function recognises and includes column names that in fact have the same
#' name but were made unique by R functions.
#'
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom dplyr rowwise mutate ungroup c_across
#' @importFrom tidyselect starts_with
#'
sum_duplicates <- function(values) {
  if (ncol(values) == 0) {
    return(values)
  }

  # get duplicated column names, even if they were made unique by R
  col_names <- sub("\\.+[[:digit:]]+", "", colnames(values))
  col_names <- unique(col_names[duplicated(col_names)])

  if (length(col_names) == 0) {
    return(values)
  } # No duplicates

  for (i in col_names) {
    values <- values %>%
      dplyr::rowwise() %>%
      dplyr::mutate({{ i }} := sum(dplyr::c_across(tidyselect::starts_with(i))), .keep = "unused") %>%
      dplyr::ungroup()
  }

  return(values)
}

#' Normalise rows to 100%
#'
#' Normalises values in a vector to 100%
#'
#' @keywords internal
normalise_rows <- function(values) {
  checkmate::assert_numeric(values)

  if (ncol(values) == 0) {
    return(values)
  }

  row_sums <- rowSums(values, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  # Normalise and return as percentages
  values / row_sums * 100
}
