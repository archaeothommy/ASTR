#' Oxide conversion functions
#'
#' Convert between element and oxide weight percent (oxide%) compositions using
#' pre-compiled conversion factors.
#'
#' @param df Data frame with compositional data.
#' @param elements,oxides Character vector with the chemical symbols of the
#'   elements or oxides that should be converted.
#' @param oxide_preference String that controls which oxide should be used if an
#'   element forms more than one oxide. Allowed values are: `reducing`,
#'   `oxidising`, `ask`, or a named vector mapping the specific oxide to its
#'   element. See details for further information.
#' @param which_concentrations Character string that determines by concentration
#'   which of the `elements` or `oxides` are converted. Allowed values are:
#'   * `all` (convert all elements or oxides; the default)
#'   * `major` (convert elements or oxides with concentrations >= 1 wt%)
#'   * `minor` (convert elements or concentrations between 0.1 and 1 wt%).
#'   * `no_trace` (convert elements or oxides with concentration >=0.1 wt%)
#' @param normalise If `TRUE`, converted concentrations will be normalised to
#'   100%. Default to `FALSE`.
#' @param drop If `FALSE`, the default, columns with unconverted values are
#'   kept. If `TRUE`, columns with unconverted values are dropped. Dropping
#'   column could result in loss of information as this will also drop
#'   columns with values excluded from conversion by the parameter
#'   `which_concentrations`.
#'
#' @returns The original data frame with the converted concentrations
#'
#' @details If the dataset includes already an element and its respective oxide,
#'   the conversion leaves the column of the respective oxide or element
#'   unaffected.
#'
#'   In `element_to_oxide()`, the parameter `oxide_preference` controls the
#'   behaviour of the function if the element forms more than one oxide:
#'   * `oxidising`: Use the oxide with the highest oxidation state of the element
#'   (e.g., `Fe2O3`)
#'   * `reducing`: Use the oxide with the lowest oxidation state of the element
#'   (e.g., `FeO`)
#'   * `ask`: The user is asked for each element which oxide should be used.
#'   * named vector: A named vector mapping the oxides to be used to the
#'   elements (e.g., `c(Fe = "FeO", Cu = "Cu2O")`)
#'
#'   In `oxide_to_element()`, conversions from different oxides to the same
#'   element (e.g., Fe<sub>2</sub>O<sub>3</sub> and FeO to Fe) result in one column for the element
#'   with the sum of all converted values of the respective element.
#'
#'   Conversion factors are pre-compiled for a wide range of oxides.
#'   consequently, conversion is restricted to the oxides on this list. If you
#'   encounter an oxide that is currently not included, please reach out to the
#'   package maintainers or create a pull request in the [package's GitHub
#'   repo](https://github.com/archaeothommy/ASTR) to add it.
#'
#' @export
#' @name oxide_conversion
#'
#' @examples
#' # Example data frame with element weight percents
#' df <- data.frame(ID = "Sample1", Si = 45, Fe = 50, Al = 5)
#'
#' # Select elements by oxide_preference
#' element_to_oxide(df, elements = c("Si", "Fe", "Al"), oxide_preference = "oxidising")
#' element_to_oxide(df, elements = c("Fe", "Al"), oxide_preference = c(Fe = "FeO", Al = "Al2O3"))
#' \dontrun{
#' element_to_oxide(df, elements = c("Si", "Fe", "Al"), oxide_preference = "ask")
#' }
#'
#' # Loss of information when converting a subset 'which_concentration' and 'drop = TRUE'
#' df2 <- data.frame(ID = "feldspar", Na = 8.77, Al = 10.29, Si = 32.13, Ba = 0.3, Sr = 0.05)
#' element_to_oxide(
#'   df2,
#'   elements =  names(df2[-1]),
#'   which_concentration = "major",
#'   oxide_preference = "reducing",
#'   drop = TRUE
#' )
#'
#' # Conversions are reversible
#' oxides <- element_to_oxide(
#'   df,
#'   elements = names(df[-1]),
#'   oxide_preference = "oxidising",
#'   drop = TRUE,
#'   normalise = TRUE
#' )
#' elements <- oxide_to_element(
#'   oxides,
#'   oxides = names(oxides[-1]),
#'   drop = TRUE,
#'   normalise = TRUE
#' )
#' all.equal(df, elements)
#'
#' # Conversion from oxide to element summarises columns converting to the same element
#' df3 <- data.frame(Fe2O3 = 20, FeO = 20, Cr2O3 = 15, CrO2 = 15, CuO = 20, Cu2O = 20)
#' oxide_to_element(df3, oxides = names(df3), drop = TRUE)

element_to_oxide <- function(
  df,
  elements,
  oxide_preference,
  which_concentrations = c("all", "major", "minor", "no_trace"),
  normalise = FALSE,
  drop = FALSE
) {
  # Validate inputs
  checkmate::assert_data_frame(df)

  checkmate::assert_character(elements,
    any.missing = FALSE,
    all.missing = FALSE,
    pattern = paste0(elements_data, collapse = "|")
  )
  checkmate::assert_character(oxide_preference,
    any.missing = FALSE,
    all.missing = FALSE
  )
  checkmate::assert_character(which_concentrations,
    any.missing = FALSE,
    all.missing = FALSE,
    pattern = "all|major|minor|no_trace"
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

  # create subset of reference table for elements in data frame with recorded oxides
  conversion_table <- conversion_oxides[conversion_oxides$Element %in% elements & !is.na(conversion_oxides$Oxide), ]

  # check that all requested elements have oxides
  if (!all(elements %in% conversion_table$Element)) {
    stop(
      "Oxides of one or more elements not available. See 'ASTR::conversion_oxides' for a list of available oxides. ",
      "To proceed, please exclude the elements from the conversion.\n\n",
      "See instructions in the 'Details' section of the function documentation to add oxides to the list. "
    )
  }

  # Handle oxide preference
  if (length(oxide_preference) == 1 && !oxide_preference %in% conversion_table$Oxide) {
    # Single string preference
    switch(oxide_preference,
      oxidising = {
        pref <- conversion_table %>%
          dplyr::group_by(.data$Element) %>%
          dplyr::filter(.data$OxidationState == max(.data$OxidationState)) %>%
          dplyr::select("Element", "Oxide") %>%
          tibble::deframe()
      },
      reducing = {
        pref <- conversion_table %>%
          dplyr::group_by(.data$Element) %>%
          dplyr::filter(.data$OxidationState == min(.data$OxidationState)) %>%
          dplyr::select("Element", "Oxide") %>%
          tibble::deframe()
      },
      ask = {
        pref <- interactive_oxide_select(elements)
      },
      {
        stop("'oxide_preference' must either have the value 'oxidising', 'reducing', or 'ask', or be a named vector.")
      }
    )
  } else {
    # Named vector preference
    # check names are valid elements
    invalid_elements <- setdiff(names(oxide_preference), conversion_oxides$Element)
    if (length(invalid_elements) > 0) {
      stop("Invalid element names in 'oxide_preference': ", paste0(invalid_elements, collapse = ", "))
    }

    # check values are valid oxides
    invalid_oxides <- setdiff(oxide_preference, conversion_oxides$Oxide)
    if (length(invalid_oxides) > 0) {
      stop("Invalid oxide names in 'oxide_preference': ", paste0(invalid_oxides, collapse = ", "))
    }

    # check that the element matches the specified oxide
    check <- oxide_preference
    for (el in names(check)) {
      ox <- conversion_oxides$Oxide[conversion_oxides$Element == el]
      if (check[el] %in% ox) {
        check[el] <- NA
      }
    }

    # if matching is not successful, throw error and specify non-matching pairs
    if (any(!is.na(check))) {
      check <- check[!is.na(check)]
      stop(
        "'oxide_preference' includes invalid combinations:\n",
        paste(check, names(check), sep = " is not an oxide of ", collapse = "\n")
      )
    }

    pref <- oxide_preference
  }

  # Apply major/minor filter
  switch(which_concentrations,
    all = {
      oxide_percent <- df
      # do nothing, convert all
    },
    major = {
      # Only convert elements >= 1 wt%
      oxide_percent <- df
      oxide_percent[oxide_percent < 1] <- NA
    },
    minor = {
      # Only convert elements (0.1 - 1 wt%)
      oxide_percent <- df
      oxide_percent[oxide_percent < 0.1 | oxide_percent >= 1] <- NA
    },
    no_trace = {
      # Only elements (> 0.1 wt%)
      oxide_percent <- df
      oxide_percent[oxide_percent < 0.1] <- NA
    }
  )

  oxide_percent <- t(
    t(oxide_percent[elements]) * conversion_table$ElementToOxide[match(elements, conversion_table$Element)]
  )

  colnames(oxide_percent)[match(names(pref), colnames(oxide_percent))] <- pref

  # Normalise if requested
  if (normalise) {
    oxide_percent <- normalise_rows(oxide_percent)
  }

  # Add oxide columns to output
  df <- cbind(df, oxide_percent)

  # drop input columns if requested
  if (drop) {
    df[elements] <- NULL
  }

  return(df)
}

#' @rdname oxide_conversion
#' @export
oxide_to_element <- function(
  df,
  oxides,
  normalise = FALSE,
  drop = FALSE
) {
  #Validate inputs
  checkmate::assert_data_frame(df)

  checkmate::assert_character(
    oxides,
    any.missing = FALSE,
    all.missing = FALSE
  )

  # Check if all requested oxides are in df
  missing <- setdiff(oxides, names(df))
  if (length(missing) > 0) {
    stop(
      "The following oxides are not present in df: ",
      paste(missing, collapse = ", ")
    )
  }

  # subset conversion table
  conversion_table <- conversion_oxides[conversion_oxides$Oxide %in% oxides &
                                          !is.na(conversion_oxides$OxideToElement), ]

  if (!all(oxides %in% conversion_table$Oxide)) {
    stop(
      "Conversion factors for one or more oxides are not available. ",
      "See 'ASTR::conversion_oxides' for a list of available oxides.\n\n",
      "See instructions in the 'Details' section of the function documentation to add oxides to the list."
    )
  }

  # convert
  element_percent <- df

  element_percent <- t(
    t(element_percent[oxides]) * conversion_table$OxideToElement[match(oxides, conversion_table$Oxide)]
  )

  element_percent <- as.data.frame(element_percent)

  colnames(element_percent) <- conversion_table$Element[match(oxides, conversion_table$Oxide)]

  # make column names syntactically valid
  colnames(element_percent) <- make.names(colnames(element_percent), unique = TRUE)

  # Sum duplicate elements (e.g., Fe from FeO + Fe2O3)
  element_percent <- sum_duplicates(element_percent)

  # Normalise if requested
  if (normalise) {
    element_percent <- normalise_rows(element_percent)
  }

  # Add element columns to output
  df <- cbind(df, element_percent)

  if (drop) {
    df[oxides] <- NULL
  }

  return(df)
}

#' Interactive oxide selection
#'
#' Interactively compiles list of oxides from user input.
#'
#' @param elements A character vector with chemical symbols of elements
#'
#' @returns named vector with all oxides for the supplied list of elements
#'
#' @keywords internal
#'
interactive_oxide_select <- function(elements) {
  message("Starting interactive selection of oxides")

  oxides <- stats::setNames(elements, elements)

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
#' @param df A data frame
#'
#' @keywords internal
#' @importFrom magrittr %>%
#' @importFrom dplyr rowwise mutate ungroup c_across
#' @importFrom tidyselect starts_with
#'
sum_duplicates <- function(df) {
  if (ncol(df) == 0) {
    return(df)
  }

  # get duplicated column names, even if they were made unique by R
  col_names <- sub("\\.+[[:digit:]]+", "", colnames(df))
  col_names <- unique(col_names[duplicated(col_names)])

  if (length(col_names) == 0) {
    return(df)
  } # No duplicates

  for (i in col_names) {
    df <- df %>%
      dplyr::rowwise() %>%
      dplyr::mutate({{ i }} := sum(dplyr::c_across(tidyselect::starts_with(i))), .keep = "unused") %>%
      dplyr::ungroup()
  }

  return(df)
}

#' Normalise rows to 100%
#'
#' @param df A matrix or data frame
#'
#' Normalises values in a vector to 100%
#'
#' @keywords internal
normalise_rows <- function(df) {

  if (ncol(df) == 0) {
    return(df)
  }

  row_sums <- rowSums(df, na.rm = TRUE)
  row_sums[row_sums == 0] <- NA_real_

  # Normalise and return as percentages
  result <- df / row_sums * 100

  return(result)
}
