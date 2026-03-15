#' @rdname archchem
#' @export
remove_units <- function(x, ...) {
  UseMethod("remove_units")
}
#' @export
remove_units.archchem <- function(x, recover_unit_names = FALSE, ...) {
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
            dplyr::case_match(
              rendered_unit,
              "atP" ~ "at%",
              "wtP" ~ "wt%",
              "count/s" ~ "cps",
              .default = rendered_unit
            )
          }
        )
        paste0(column_names, "_", unit_names)
      },
      tidyselect::where(function(y) {
        class(y) == "units" && !is_archchem_class(y, "archchem_error")
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

#' @rdname archchem
#' @param unit string with a unit definition that can be understood by
#' \link[units]{set_units}, e.g. "%", "kg", or "m/s^2"
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  UseMethod("unify_concentration_unit")
}
#' @export
unify_concentration_unit <- function(x, unit, ...) {
  switch(unit,
    # Conversion to atP
    atP = {
      # identify all oxides and present, convert to wt%

      # convert all other concentrations to wt%

      # convert to at%

    },
    # Conversion to oxP
    oxP = {
      # identify all elements that are not oxides and convert to wt%

      # convert all elements to ox%

    },
    # conversion to all other units
    {
      # something here to convert from atP and oxP to wt% first

      dplyr::mutate(
        x,
        dplyr::across(
          tidyselect::where(function(y) {
            class(y) == "units" &&
              units::ud_are_convertible(units::deparse_unit(y), "mg/kg")
          }),
          function(z) units::set_units(z, unit, mode = "standard")
        )
      )
    }
  )
}

# units_to_convert <- unlist(
#   sapply(df[elements], function(x) class(x) == "units" & units(x)[1] != unit)
# )
# df_convert <- cbind(df$ID, subset(df[elements], select = units_to_convert))
