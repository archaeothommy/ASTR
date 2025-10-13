#### column type constructor mechanism ####

# define the correct constructor function for an archchem column
# based on some clever parsing of the column name
# SI-unit column types are defined with the units package
# https://cran.r-project.org/web/packages/units/index.html
# (so the udunits library)
colnames_to_constructor <- function(x) {
  purrr::map(
    colnames(x),
    function(colname) {
      # use while for hacky switch statement
      while (TRUE) {
        # ratios
        if (is_isotope_ratio_colname(colname) || is_elemental_ratio_colname(colname)) {
          # create a partial constructor function,
          # where the unit is already set
          construct_unit <- purrr::partial(
            units::set_units,
            value = "1", # dimensionless unit, unscaled
            mode = "standard"
          ) |>
            # compose it with a function to
            # make the input numeric
            # (this will be called first)
            purrr::compose(as.numeric)
          # return constructor function ready to be applied
          return(construct_unit)
          break
        }
        # delta/epsilon ratios
        if (is_isotope_delta_epsilon(colname)) {
          delta_epsilon <- extract_delta_epsilon_string(colname)
          construct_unit <- purrr::partial(
            units::set_units,
            value = "%",
            mode = "standard"
          ) |>
            purrr::compose(\(x) {
              if (delta_epsilon == "d") {
                x/10 # per mille -> percent
              } else if (delta_epsilon == "e") {
                x/100 # parts per 10000 -> percent
              }
            }) |>
            purrr::compose(as.numeric)
          return(construct_unit)
          break
        }
        # concentrations
        if (is_concentration_colname(colname)) {
          # get unit from column name
          unit_from_col <- extract_unit_string(colname)
          # handle special cases
          unit_from_col_modified <- dplyr::case_match(
            unit_from_col,
            c("at%", "wt%") ~ "%",
            .default = unit_from_col
          )
          # apply unit
          construct_unit <- purrr::partial(
            units::set_units,
            value = unit_from_col_modified,
            mode = "standard"
          ) |>
            purrr::compose(as.numeric)
          return(construct_unit)
          break
        }
        # everything not recognized by the parser:
        # guess the column type
        return(readr::parse_guess)
        break
      }
    }
  )
}

#### regex validators ####

is_isotope_ratio_colname <- function(colname) {
  grepl(isotope_ratio(), colname, perl = TRUE)
}
is_isotope_delta_epsilon <- function(colname) {
  grepl(isotope_delta_epsilon(), colname, perl = TRUE)
}
is_elemental_ratio_colname <- function(colname) {
  grepl(elemental_ratio(), colname, perl = TRUE)
}
is_concentration_colname <- function(colname) {
  grepl(concentrations(), colname, perl = TRUE)
}
extract_unit_string <- function(colname) {
  pos <- regexpr("(?<=_).*", colname, perl = TRUE)
  regmatches(colname, pos)
}
extract_delta_epsilon_string <- function(colname) {
  substr(colname, 1, 1)
}

#### regex patterns ####

# collate vectors to string with | to indicate OR in regex
isotopes_list <- \() { paste0(isotopes, collapse = "|") }
elements_list <- \() { paste0(elements, collapse = "|") }
oxides_list <- \() { paste0(oxides, collapse = "|") }
ox_elem_list <- \() paste0(oxides_list(), "|", elements_list())
ox_elem_iso_list <- \() paste0(ox_elem_list(), "|", isotopes_list())

# define regex pattern for isotope ratio:
# any isotope followed by a / and another isotope, e.g. 206Pb/204Pb
isotope_ratio <- \() paste0("(", isotopes_list(), ")/(", isotopes_list(), ")")

# define regex pattern for delta and espilon notation:
# letter d OR e followed by any isotope
isotope_delta_epsilon <- \() {
  paste0(
    "(", paste0(c("d", "e"), collapse = "|"),
    ")(", isotopes_list(), ")"
  )
}

# define regex pattern for element ratios:
# any combination of two elements or oxides connected by + , - or / that may or
# may not be enclosed in parentheses followed by a / and any combination of two
# elements or oxides connected by +, -, or / that may or may not be enclosed in
# parentheses, e.g. Sb/As, SiO2/Feo, (Al2O3+SiO2)/(K2O-Na20), (Feo/Mno)/(SiO2)
elemental_ratio <- \() {
  paste0(
    "\\(?(", ox_elem_list(), ")([\\+-/](",
    ox_elem_list(), "))?\\)?/\\(?(",
    ox_elem_list(), ")([\\+-/](",
    ox_elem_list(), "))?\\)?"
  )
}

# define regex pattern for concentrations:
# any combination of one or more elements, isotopes, or oxides connected by
# + or - and followed by an underscore that may or may be enclosed in
# parentheses, e.g. Sb_, Feo+SiO2_, (Al2O3+SiO2)_
# The underscore enforces that concentrations always have a unit and prevents
# partial matching in elemental ratios
concentrations <- \() {
  paste0(
    "^\\(?(",
    ox_elem_iso_list(), ")(?!/)((\\+|-)(",
    ox_elem_iso_list(), "))*\\)?_"
  )
}
