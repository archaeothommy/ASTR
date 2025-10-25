#### column type constructor mechanism ####

# define the correct constructor function for an archchem column
# based on some clever parsing of the column name
# SI-unit column types are defined with the units package
# https://cran.r-project.org/web/packages/units/index.html
# (so the udunits library)
colnames_to_constructors <- function(
  x,
  context,
  bdl, bdl_strategy,
  guess_context_type, na,
  drop_columns
) {
  purrr::imap(
    colnames(x),
    function(colname, idx) {
      # use while for hacky switch statement
      while (TRUE) {
        # ID column
        if (colname == "ID") {
          return(
            function(x) {
              x <- add_archchem_class(x, "archchem_id")
              return(x)
            }
          )
          break
        }
        # contextual columns
        if (idx %in% context || colname %in% context) {
          return(
            function(x) {
              if (guess_context_type && is.character(x)) {
                x <- readr::parse_guess(x, na = na)
              }
              x <- add_archchem_class(x, "archchem_context")
              return(x)
            }
          )
          break
        }
        # error columns
        if (is_err(colname)) {
          return(
            function(x) {
              x <- apply_bdl_strategy(x, colname, bdl, bdl_strategy)
              x <- as_numeric_info(x, colname)
              x <- add_archchem_class(x, c("archchem_error"))
            }
          )
        }
        # ratios
        if (is_isotope_ratio(colname)) {
          return(
            function(x) {
              x <- as_numeric_info(x, colname)
              x <- add_archchem_class(x, c("archchem_isotope", "archchem_ratio"))
              return(x)
            }
          )
          break
        }
        if (is_isotope_delta_epsilon(colname)) {
          # delta_epsilon <- extract_delta_epsilon_string(colname)
          return(
            function(x) {
              # if (delta_epsilon == "d") {
              #   x / 10 # per mille -> percent
              # } else if (delta_epsilon == "e") {
              #   x / 100 # parts per 10000 -> percent
              # }
              x <- as_numeric_info(x, colname)
              x <- add_archchem_class(x, c("archchem_isotope", "archchem_ratio"))
              return(x)
            }
          )
          break
        }
        if (is_elemental_ratio(colname)) {
          return(
            function(x) {
              x <- as_numeric_info(x, colname)
              x <- add_archchem_class(x, c("archchem_element", "archchem_ratio"))
              return(x)
            }
          )
          break
        }
        # concentrations
        if (is_concentration(colname)) {
          unit_from_col <- extract_unit_string(colname)
          # handle special cases
          unit_from_col <- dplyr::case_match(
            unit_from_col,
            c("at%", "wt%") ~ "%",
            c("cps") ~ "count/s",
            .default = unit_from_col
          )
          return(
            function(x) {
              x <- apply_bdl_strategy(x, colname, bdl, bdl_strategy)
              x <- as_numeric_info(x, colname)
              x <- units::set_units(x, value = unit_from_col, mode = "standard")
              x <- add_archchem_class(x, c("archchem_concentration"))
              return(x)
            }
          )
          break
        }
        # handle everything not recognized by the parser:
        m <- paste0(
          "Column name \"",
          colname,
          "\" could not be parsed. ",
          "Either analytical columns do not conform to ASTR conventions or ",
          "contextual columns are not specified as such."
        )
        if (drop_columns) {
          warning(m)
          return(function(x) {
            NULL
          })
        } else {
          stop(m)
        }
      }
    }
  )
}

add_archchem_class <- function(x, class) {
  attr(x, "archchem_class") <- class
  return(x)
}

as_numeric_info <- function(x, colname) {
  withCallingHandlers(
    y <- as.numeric(x),
    warning = function(w) {
      message <- conditionMessage(w)
      warning(
        paste0(
          "Issue when transforming column \"", colname, "\" to numeric values: "
        ),
        message,
        call. = FALSE
      )
      tryInvokeRestart("muffleWarning")
    })
  return(y)
}

# colname only an argument in case we want to implement more specific handling
# eventually
apply_bdl_strategy <- function(x, colname, bdl, bdl_strategy) {
  bdl_values <- which(grepl(paste(bdl, collapse = "|"), x, perl = FALSE))
  x[bdl_values] <- bdl_strategy()
  return(x)
}

#### regex validators ####

is_err <- function(colname) {
  grepl(err(), colname, perl = TRUE)
}
is_isotope_ratio <- function(colname) {
  grepl(isotope_ratio(), colname, perl = TRUE)
}
is_isotope_delta_epsilon <- function(colname) {
  grepl(isotope_delta_epsilon(), colname, perl = TRUE)
}
is_elemental_ratio <- function(colname) {
  grepl(elemental_ratio(), colname, perl = TRUE)
}
is_concentration <- function(colname) {
  grepl(concentration(), colname, perl = TRUE)
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
isotopes_list <- function() {
  paste0(isotopes, collapse = "|")
}
elements_list <- function() {
  paste0(elements, collapse = "|")
}
oxides_list <- function() {
  all_oxide_like_states <- c(oxides, special_oxide_states)
  paste0(all_oxide_like_states, collapse = "|")
}
ox_elem_list <- function() paste0(oxides_list(), "|", elements_list())
ox_elem_iso_list <- function() paste0(ox_elem_list(), "|", isotopes_list())

# special_type_list <- function() {
#   paste0(c(
#     "wt%", "at%", "w/w%"
#     #"ppm", "ppb", "ppt", "%", ,
#     #"\u2030" # for the per-mille symbol
#   ), collapse = "|")
# }

# define regex pattern for isotope ratio:
# any isotope followed by a / and another isotope, e.g. 206Pb/204Pb
isotope_ratio <- function() {
  paste0("(", isotopes_list(), ")/(", isotopes_list(), ")")
}

# define regex pattern for delta and espilon notation:
# letter d OR e followed by any isotope
isotope_delta_epsilon <- function() {
  paste0(
    "(", paste0(c("d", "e"), collapse = "|"),
    ")(", isotopes_list(), ")"
  )
}

# error states
err <- function() {
  paste0(c(
    err_2sd(), err_sd(),
    err_2sd_percent(), err_sd_percent(),
    err_2se(), err_se()
  ), collapse = "|")
}
err_2sd <- function() "\\_err2SD"
err_sd <- function() "\\_errSD"
err_2sd_percent <- function() "\\_err2SD%"
err_sd_percent <- function() "\\_errSD%"
err_2se <- function() "\\_err2SE"
err_se <- function() "\\_errSE"

# define regex pattern for element ratios:
# any combination of two elements or oxides connected by + , - or / that may or
# may not be enclosed in parentheses followed by a / and any combination of two
# elements or oxides connected by +, -, or / that may or may not be enclosed in
# parentheses, e.g. Sb/As, SiO2/Feo, (Al2O3+SiO2)/(K2O-Na20), (Feo/Mno)/(SiO2)
elemental_ratio <- function() {
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
concentration <- function() {
  paste0(
    "^\\(?(",
    ox_elem_iso_list(), ")(?!/)((\\+|-)(",
    ox_elem_iso_list(), "))*\\)?_"
  )
}
