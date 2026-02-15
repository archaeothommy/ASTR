# see R/data.R for the documentation of these datasets

#### chemical reference data ####

conversion_oxides <- read.csv(
  file = "data-raw/oxide_conversion.csv",
  na.strings = "",
  stringsAsFactors = FALSE
)

<<<<<<< HEAD
elements_data <- unique(conversion_oxides$Element)

oxides_data <- na.omit(unique(conversion_oxides$Oxide))
=======
oxides <- c(
  # retrieved from https://www.wikidoc.org/index.php/Oxide,
  # sorted according to alphabet
  "Ag2O", "AgO", "Al2O3", "AlO", "As2O3", "As2O5", "Au2O3", "B2O3", "BaO", "BeO",
  "Bi2O3", "C2O", "CaO", "CdO", "CeO2", "Cl2O", "Cl2O7", "ClO2", "CO", "CO2",
  "CO3", "CoO", "Cr2O3", "CrO2", "CrO3", "Cu2O", "CuO", "Er2O3", "Fe2O3",
  "FeO", "Ga2O3", "Gd2O3", "GeO2", "H2O", "HfO2", "HgO", "Ho2O3", "In2O3",
  "K2O", "La2O3", "Li2O", "Lu2O3", "MgO", "Mn2O7", "MnO", "MnO2", "MoO3", "N2O3",
  "N2O4", "N2O5", "Na2O", "Ni2O3", "Ni2O5", "NiO", "NO", "NO2", "O4", "OF2",
  "OsO4", "P2O5", "P4O6", "PbO", "PbO2", "PdO", "Pm2O3", "PuO2", "Rb2O",
  "Re2O7", "ReO3", "Rh2O3", "RuO2", "RuO4", "Sb2O3", "Sb2O5", "Sc2O3", "SeO2",
  "SeO3", "SiO2", "Sm2O3", "SnO", "SnO2", "SO", "SO2", "SO3", "SrO", "Ta2O5",
  "Tb2O3", "TeO2", "TeO3", "ThO2", "Ti2O3", "TiO", "TiO2", "Tl2O", "Tl2O3",
  "Tm2O3", "UO2", "UO3", "V2O3", "V2O5", "VO", "VO2", "W2O3", "WO2", "WO3",
  "XeO3", "XeO4", "Y2O3", "Yb2O3", "ZnO", "ZrO2"
)
>>>>>>> main

special_oxide_states <- c(
  "LOI", # loss of ignition
  "FeOtot", # total iron
  "Fe2O3tot"
)

isotopes_data <- c(
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

usethis::use_data(
  elements_data,
  oxides_data,
  special_oxide_states,
  isotopes_data,
  conversion_oxides,
  overwrite = TRUE, internal = FALSE
)

# units <- c(
#   # This is mostly to check for potential typos in units, not for hard matching
#   "ppm", "ppb", "%", "at%", "wt%", "µg/kg", "ug/kg"
# )
#
# usethis::use_data(isotopes, overwrite = T)

#### archem data input table ####

archchem_example_input <- readr::read_csv("data-raw/test_data_input_good.csv")

usethis::use_data(archchem_example_input,
  overwrite = TRUE
)
