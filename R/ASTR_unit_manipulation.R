#' @rdname ASTR
#' @export
remove_units <- function(x, ...) {
  UseMethod("remove_units")
}
#' @export
remove_units.ASTR <- function(x, recover_unit_names = FALSE, ...) {
  # rename columns: recover units in column names
  if (recover_unit_names) {
    x <- dplyr::rename_with(
      x,
      function(column_names) {
        unit_names <- purrr::map_chr(
          column_names,
          function(column_name) {
            # render individual units
            unit <- units(x[[column_name]])
            rendered_unit <- as.character(unit, neg_power = FALSE, prod_sep = "*")
            # handle special cases
            dplyr::recode_values(
              rendered_unit,
              "atP" ~ "at%",
              "wtP" ~ "wt%",
              "count/s" ~ "cps",
              default = rendered_unit
            )
          }
        )
        paste0(column_names, "_", unit_names)
      },
      tidyselect::where(function(y) {
        class(y) == "units" && !is_ASTR_class(y, "ASTR_error")
      })
    )
  }
  # drop units
  dplyr::mutate(
    x,
    dplyr::across(
      tidyselect::where(function(y) {
        class(y) == "units"
      }),
      units::drop_units
    )
  )
}

#' @rdname ASTR
#' @param unit string with a unit definition that can be understood by
#' \link[units]{set_units}, e.g. "%", "kg", or "m/s^2"
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  UseMethod("unify_concentration_unit")
}
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  dplyr::mutate(
    x,
    dplyr::across(
      tidyselect::where(function(y) {
        class(y) == "units" &&
          units::ud_are_convertible(units::deparse_unit(y), "%")
      }),
      function(z) units::set_units(z, unit, mode = "standard")
    )
  )
}

#' Convert units
#'
#' The function is intended to provide "on-the-fly" unit conversions inside
#' functions that require values in a certain unit. It converts ALL values in
#' the units of the values intended to be converted to ensure that e.g.
#' normalisation is not performed on subsets.
#'
#' It is written in a way that only the converted values of the input are
#' processed further and that except for them, columns of the unconverted ASTR
#' object are made available to the user through the function calling this unit
#' conversion. Use the respective conversion functions for proper, user-facing
#' unit conversions.
#'
#' @param df ASTR object
#' @param values Character vector with column names of the values to be
#'   converted.
#' @param unit_to The unit the values should be converted to
#' @param ... Additional values passed to the conversion functions. This is
#'   primarily intended for conversion into oxides because this function takes a
#'   mandatory parameter that does not has a default value.
#'
#' @keywords internal
convert_concentration_units <- function(df, values, unit_to, ...) {
  checkmate::assert_class(df, "ASTR")

  # exclude mixed oxides and elements
  type <- intersect(values, elements_data) # length 0 = only oxides

  if (!length(type) %in% c(0, length(values))) {
    stop("Unit conversion failed: Values include oxides and elements. Please convert one into another manually first.")
  }

  # unify concentrations: SI unit or unitless -> target unit; atP or oxP -> wtP as common base
  df <- unify_concentration_unit(
    df,
    unit = ifelse(unit_to %in% c("oxP", "atP"), "wtP", unit_to)
  )

  # get units of required values
  unit_from <- sapply(df[values], function(x) units::deparse_unit(x))
  unit_from <- unique(unit_from)

  # check if all values are in the same unit
  if (length(unit_from) > 1) {
    stop(
      "Unit conversion failed: Units cannot be converted into each other: ",
      paste0(unique(unit_from), collapse = ", ")
    )
  }

  # if handling only oxides: make sure values are in wt%, identify them
  if (length(type) == 0) {
    unit_from <- "oxP"
  }

  # determine type of conversion (to-from) and convert columns accordingly
  to_from <- paste0(unit_from, unit_to)

  switch(to_from,
    atPwtP = {
      df <- at_to_wt(df, ...)
    },
    wtPatP = {
      df <- wt_to_at(df, ...)
    },
    wtPoxP = {
      df <- element_to_oxide(df, ...)
    },
    oxPwtP = {
      df <- oxide_to_element(df, ...)
    },
    atPoxP = {
      cols <- colnames(get_unit_columns(df, "atP"))

      df <- at_to_wt(df)
      df <- element_to_oxide(df, elements = cols, ...)
    },
    oxPatP = {
      cols <- intersect(
        colnames(get_unit_columns(df, "wtP")),
        oxides_data
      )
      cols <- conversion_oxides[conversion_oxides[["Oxide"]] %in% cols, ][["Element"]]

      df <- oxide_to_element(df, ...)
      df <- wt_to_at(df, elements = cols, ...)
    }
  )

  return(df)
}
