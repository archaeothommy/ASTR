# List to be checked against, should be outsourced in separate file for easier maintenance

elements <- c(
  # sorted according to alphabet
  "Ac", "Ag", "Al", "Am", "Ar", "As", "At", "Au", "B", "Ba", "Be", "Bh", "Bi",
  "Bk", "Br", "C", "Ca", "Cd", "Ce", "Cf", "Cl", "Cm", "Co", "Cr", "Cs", "Cu",
  "Ds", "Db", "Dy", "Er", "Es", "Eu", "F", "Fe", "Fm", "Fr", "Ga", "Gd", "Ge",
  "H", "He", "Hf", "Hg", "Ho", "Hs", "I", "In", "Ir", "K", "Kr", "La", "Li",
  "Lr", "Lu", "Md", "Mg", "Mn", "Mo", "Mt", "N", "Na", "Nb", "Nd", "Ne", "Ni",
  "No", "Np", "O", "Os", "P", "Pa", "Pb", "Pd", "Pm", "Po", "Pr", "Pt", "Pu",
  "Ra", "Rb", "Re", "Rf", "Rg", "Rh", "Rn", "Ru", "S", "Sb", "Sc", "Se", "Sg",
  "Si", "Sm", "Sn", "Sr", "Ta", "Tb", "Tc", "Te", "Th", "Ti", "Tl", "Tm", "U",
  "V", "W", "Xe", "Y", "Yb", "Zn", "Zr"
)

oxides <- c(
  # retrieved from https://www.wikidoc.org/index.php/Oxide,
  # sorted according to alphabet
  "Ag2O", "AgO", "Al2O3", "AlO", "As2O3", "As2O5", "B2O3", "BaO", "BeO",
  "Bi2O3", "C2O", "CaO", "CdO", "CeO2", "Cl2O", "Cl2O7", "ClO2", "CO", "CO2",
  "CO3", "CoO", "Cr2O3", "CrO2", "CrO3", "Cu2O", "CuO", "Er2O3", "Fe2O3",
  "FeO", "Ga2O3", "Gd2O3", "GeO2", "H2O", "HfO2", "HgO", "Ho2O3", "In2O3",
  "K2O", "La2O3", "Li2O", "Lu2O3", "MgO", "Mn2O7", "MnO2", "MoO3", "N2O3",
  "N2O4", "N2O5", "Na2O", "Ni2O3", "Ni2O5", "NiO", "NO", "NO2", "O4", "OF2",
  "OsO4", "P2O5", "P4O6", "PbO", "PbO2", "PdO", "Pm2O3", "PuO2", "Rb2O",
  "Re2O7", "ReO3", "Rh2O3", "RuO2", "RuO4", "Sb2O3", "Sb2O5", "Sc2O3", "SeO2",
  "SeO3", "SiO2", "Sm2O3", "SnO", "SnO2", "SO", "SO2", "SO3", "SrO", "Ta2O5",
  "Tb2O3", "TeO2", "TeO3", "ThO2", "Ti2O3", "TiO", "TiO2", "Tl2O", "Tl2O3",
  "Tm2O3", "UO2", "UO3", "V2O3", "V2O5", "VO", "VO2", "W2O3", "WO2", "WO3",
  "XeO3", "XeO4", "Y2O3", "Yb2O3", "ZnO", "ZrO2"
)

isotopes <- c(
  # all naturally occurring isotopes, retrieved from https://www.ciaaw.org/isotopic-abundances.htm
  # sorted according to chemical element and isotope number
  "1H", "2H", "3He", "4He", "6Li", "7Li", "9Be", "10B", "11B", "12C", "13C",
  "14N", "15N", "16O", "17O", "18O", "19F", "20Ne", "21Ne", "22Ne", "23Na",
  "24Mg", "25Mg", "26Mg", "27Al", "28Si", "29Si", "30Si", "31P", "32S", "33S",
  "34S", "36S", "35Cl", "37Cl", "36Ar", "38Ar", "40Ar", "39K", "40K", "41K",
  "40Ca", "42Ca", "43Ca", "44Ca", "46Ca", "48Ca", "45Sc", "46Ti", "47Ti",
  "48Ti", "49Ti", "50Ti", "50V", "51V", "50Cr", "52Cr", "53Cr", "54Cr", "55Mn",
  "54Fe", "56Fe", "57Fe", "58Fe", "59Co", "58Ni", "60Ni", "61Ni", "62Ni",
  "64Ni", "63Cu", "65Cu", "64Zn", "66Zn", "67Zn", "68Zn", "70Zn", "69Ga",
  "71Ga", "70Ge", "72Ge", "73Ge", "74Ge", "76Ge", "75As", "74Se", "76Se",
  "77Se", "78Se", "80Se", "82Se", "79Br", "81Br", "78Kr", "80Kr", "82Kr",
  "83Kr", "84Kr", "86Kr", "85Rb", "87Rb", "84Sr", "86Sr", "87Sr", "88Sr",
  "89Y", "90Zr", "91Zr", "92Zr", "94Zr", "96Zr", "93Nb", "92Mo", "94Mo",
  "95Mo", "96Mo", "97Mo", "98Mo", "100Mo", "96Ru", "98Ru", "99Ru", "100Ru",
  "101Ru", "102Ru", "104Ru", "103Rh", "102Pd", "104Pd", "105Pd", "106Pd",
  "108Pd", "110Pd", "107Ag", "109Ag", "106Cd", "108Cd", "110Cd", "111Cd",
  "112Cd", "113Cd", "114Cd", "116Cd", "113In", "115In", "112Sn", "114Sn",
  "115Sn", "116Sn", "117Sn", "118Sn", "119Sn", "120Sn", "122Sn", "124Sn",
  "121Sb", "123Sb", "120Te", "122Te", "123Te", "124Te", "125Te", "126Te",
  "128Te", "130Te", "127I", "124Xe", "126Xe", "128Xe", "129Xe", "130Xe",
  "131Xe", "132Xe", "134Xe", "136Xe", "133Cs", "130Ba", "132Ba", "134Ba",
  "135Ba", "136Ba", "137Ba", "138Ba", "138La", "139La", "136Ce", "138Ce",
  "140Ce", "142Ce", "141Pr", "142Nd", "143Nd", "144Nd", "145Nd", "146Nd",
  "148Nd", "150Nd", "144Sm", "147Sm", "148Sm", "149Sm", "150Sm", "152Sm",
  "154Sm", "151Eu", "153Eu", "152Gd", "154Gd", "155Gd", "156Gd", "157Gd",
  "158Gd", "160Gd", "159Tb", "156Dy", "158Dy", "160Dy", "161Dy", "162Dy",
  "163Dy", "164Dy", "165Ho", "162Er", "164Er", "166Er", "167Er", "168Er",
  "170Er", "169Tm", "168Yb", "170Yb", "171Yb", "172Yb", "173Yb", "174Yb",
  "176Yb", "175Lu", "176Lu", "174Hf", "176Hf", "177Hf", "178Hf", "179Hf",
  "180Hf", "180Ta", "181Ta", "180W", "182W", "183W", "184W", "186W", "185Re",
  "187Re", "184Os", "186Os", "187Os", "188Os", "189Os", "190Os", "192Os",
  "191Ir", "193Ir", "190Pt", "192Pt", "194Pt", "195Pt", "196Pt", "198Pt",
  "197Au", "196Hg", "198Hg", "199Hg", "200Hg", "201Hg", "202Hg", "204Hg",
  "203Tl", "205Tl", "204Pb", "206Pb", "207Pb", "208Pb", "209Bi", "230Th",
  "232Th", "231Pa", "234U", "235U", "238U"
)

units <- c(
  # This is mostly to check for potential typos in units, not for hard matching
  "ppm", "ppb", "%", "at%", "wt%", "µg/kg", "ug/kg"
)

#### Define regex patters ####

# collate vectors to string with | to indicate OR in regex
isotopes_list <- paste0(isotopes, collapse = "|")
elements_list <- paste0(elements, collapse = "|")
oxides_list <- paste0(oxides, collapse = "|")
ox_elem_list <- paste0(oxides_list, "|", elements_list)
ox_elem_iso_list <- paste0(ox_elem_list, "|", isotopes_list)

# define regex pattern for isotope ratio:
# any isotope followed by a / and another isotope, e.g. 206Pb/204Pb
isotope_ratio <- paste0("(", isotopes_list, ")/(", isotopes_list, ")")

# define regex pattern for delta and espilon notation:
# letter d OR e followed by any isotope
isotope_notation <- paste0(
  "(", paste0(c("d", "e"), collapse = "|"),
  ")(", isotopes_list, ")"
)

# define regex pattern for element ratios:
# any combination of two elements or oxides connected by + , - or / that may or
# may not be enclosed in parentheses followed by a / and any combination of two
# elements or oxides connected by +, -, or / that may or may not be enclosed in
# parentheses, e.g. Sb/As, SiO2/Feo, (Al2O3+SiO2)/(K2O-Na20), (Feo/Mno)/(SiO2)
elemental_ratio <- paste0(
  "\\(?(", ox_elem_list, ")([\\+-/](",
  ox_elem_list, "))?\\)?/\\(?(",
  ox_elem_list, ")([\\+-/](",
  ox_elem_list, "))?\\)?"
)

# define regex pattern for concentrations:
# any combination of one or more elements, isotopes, or oxides connected by
# + or - and followed by an underscore that may or may be enclosed in
# parentheses, e.g. Sb_, Feo+SiO2_, (Al2O3+SiO2)_
# The underscore enforces that concentrations always have a unit and prevents
# partial matching in elemental ratios
concentrations <- paste0(
  "^\\(?(",
  ox_elem_iso_list, ")(?!/)((\\+|-)(",
  ox_elem_iso_list, "))*\\)?_"
)

# https://github.com/r-lib/rex
library(rex)
rex_mode()

#### parser building blocks ####

element <- group(
  or(
    c(
      "Ac", "Ag", "Al", "Am", "Ar", "As", "At", "Au", "B", "Ba", "Be", "Bh", "Bi",
      "Bk", "Br", "C", "Ca", "Cd", "Ce", "Cf", "Cl", "Cm", "Co", "Cr", "Cs", "Cu",
      "Ds", "Db", "Dy", "Er", "Es", "Eu", "F", "Fe", "Fm", "Fr", "Ga", "Gd", "Ge",
      "H", "He", "Hf", "Hg", "Ho", "Hs", "I", "In", "Ir", "K", "Kr", "La", "Li",
      "Lr", "Lu", "Md", "Mg", "Mn", "Mo", "Mt", "N", "Na", "Nb", "Nd", "Ne", "Ni",
      "No", "Np", "O", "Os", "P", "Pa", "Pb", "Pd", "Pm", "Po", "Pr", "Pt", "Pu",
      "Ra", "Rb", "Re", "Rf", "Rg", "Rh", "Rn", "Ru", "S", "Sb", "Sc", "Se", "Sg",
      "Si", "Sm", "Sn", "Sr", "Ta", "Tb", "Tc", "Te", "Th", "Ti", "Tl", "Tm", "U",
      "V", "W", "Xe", "Y", "Yb", "Zn", "Zr"
    )
  )
)

rex::re_matches("Zn", rex(element))
rex::re_matches("M", rex(element))

isotope <- group(
  between(range("0","9"), low = 1, high = 3),
  element
)

rex::re_matches("12Zn", rex(isotope))
rex::re_matches("Zn", rex(isotope))

molecule <- group(
  one_or_more(element, between(range("0","9"), low = 0, high = 3))
)

rex::re_matches("Al2O3", rex(molecule))
rex::re_matches("SiO2", rex(molecule))
rex::re_matches("3", rex(molecule))

single_chemical_entity <- group(
  molecule %or% element %or% isotope
)

chemical_entity <- group(
  group( # summation
    single_chemical_entity,
    escape("+"),
    single_chemical_entity
  ) %or%
    single_chemical_entity
)

rex::re_matches("SiO2+Al2O3", rex(chemical_entity))
rex::re_matches("SiO2", rex(chemical_entity))

chemical_unit <- group(
  or(
    c("ppm", "ppt", escape("%"))
  )
)

#### high level parsers ####

ratio <- group(
  start,
  chemical_entity,
  escape("/"),
  chemical_entity,
  end
)

rex::re_matches("Ac/Pb", rex(ratio))
rex::re_matches("Ac/Al2O3", rex(ratio))
rex::re_matches("206Pb/204Pb", rex(ratio))
rex::re_matches("206Pb/204Psb", rex(ratio))

concentration <- group(
  start,
  chemical_entity,
  escape("_"),
  chemical_unit,
  end
)

concentration_ <- group(
  start,
  chemical_entity,
  escape("_"),
  capture(chemical_unit),
  end
)

rex::re_matches("Al2O3_ppm", rex(concentration_))
rex::re_matches("Zn_%", rex(concentration_))
rex::re_matches("12Zn_ppt", rex(concentration_))
rex::re_matches("SiO2+Al2O3_ppt", rex(concentration_))
rex::re_matches("SiO2_Al2O3_ppt", rex(concentration_))

#### validation setup ####

read_archchem <- function(x) {
  # read input as character columns only
  input_file <- readr::read_csv(
    x,
    col_types = readr::cols(.default = readr::col_character()),
    na = c("", "n/a", "NA"),
    name_repair = "unique_quiet"
  ) |>
    # remove columns without a header
    dplyr::select(!tidyselect::starts_with("..."))
  # transform to desired data type
  as.archchem(input_file)
}

as.archchem <- function(x, ...) {
  # input checks
  checkmate::assert_data_frame(x)
  # determine and apply column types
  modify_columns(x) |>
    # turn into tibble-derived object
    tibble::new_tibble(., nrow = nrow(.), class = "archchem")
}

modify_columns <- function(x) {
  # determine column type constructors from column names
  constructors <- colnames_to_constructor(x)
  # apply column type constructors
  purrr::map2(x, constructors, function(col, f) f(col))
}

colnames_to_constructor <- function(x) {
  purrr::map(
    colnames(x),
    function(colname) {
      # use while for hacky switch statement
      while (TRUE) {
        if (rex::re_matches(colname, rex(ratio))) {
          construct_unit <- purrr::partial(
            units::set_units,
            value = "1", # dimensionless unit, unscaled
            mode = "standard"
          ) |>
            purrr::compose(as.numeric)
          return(construct_unit)
          break
        }
        if (rex::re_matches(colname, rex(concentration))) {
          # get unit from column name
          unit_from_col <- rex::re_matches(colname, rex(concentration_))[1, 1]
          # create a partial constructor function,
          # where the unit is already set
          construct_unit <- purrr::partial(
            units::set_units,
            value = unit_from_col,
            mode = "standard"
          ) |>
            # compose it with a function to
            # make the input numeric
            # (this will be called first)
            purrr::compose(as.numeric)
          # return constructor function ready to
          # be applied
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

test <- read_archchem("./tests/testthat/input_format.csv")
test
res <- test$`206Pb/204Pb` + test$`Al2O3_%` + test$`SiO2+Al2O3_ppt` + test$`204Pb_ppm`
sprintf("%.20f", res)

# x <- readr::read_csv("./tests/testthat/input_format.csv")
# ns <- colnames(test)
# ns[[2]] -> n

#### Match columns and extract units into a data.frame

test <- readr::read_csv("./tests/testthat/input_format.csv")

matching <- data.frame(
  col = colnames(test),
  label = NA,
  type = NA,
  unit = NA
)

matching$type <- ifelse(grepl(concentrations, matching$col, perl = TRUE),
  "concentration", matching$type
)
matching$type <- ifelse(grepl(isotope_ratio, matching$col, perl = TRUE) |
  grepl(isotope_notation, matching$col, perl = TRUE),
"isotope", matching$type
)
matching$type <- ifelse(grepl(elemental_ratio, matching$col, perl = TRUE),
  "ratio", matching$type
)
matching$type <- ifelse(is.na(matching$type), "text", matching$type)

matching$unit <- regexpr("(?<=_).*", matching$col, perl = TRUE)
matching$unit <- ifelse(matching$unit != -1, regmatches(matching$col, matching$unit), 1)

matching$label <- regexpr(".*(?=_)", matching$col, perl = TRUE)
matching$label <- ifelse(matching$label != -1, regmatches(matching$col, matching$label), matching$col)
