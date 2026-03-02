# Spidergram internal data

# Element groups

# REE retrieved from https://en.wikipedia.org/wiki/Rare-earth_element,
# HFSE & LILE retrieved from https://en.wikipedia.org/wiki/Incompatible_element

element_groups <- list(
  REE = c("La", "Ce", "Pr", "Nd", "Sm", "Eu", "Gd", "Tb", "Dy",
          "Ho", "Er", "Tm", "Yb", "Lu"),
  HFSE = c("Nb", "Ta", "Zr", "Hf", "Ti", "Th", "U"),
  LILE = c("Rb", "Ba", "K", "Sr", "Cs")
)

# Normalisation standards

# Source: Sun, S.-s. & McDonough, W.F. (1989). Chemical and isotopic systematics
#         of oceanic basalts. Geological Society, London, Special Publications 42,
#         313-345. Table 1, page 318. MORB values are NMORB.

spider_references <- list(
  chondrite = c(
    La = 0.237, Ce = 0.612, Pr = 0.095, Nd = 0.467, Sm = 0.153,
    Eu = 0.058, Gd = 0.2055, Tb = 0.0374, Dy = 0.2540, Ho = 0.0566,
    Er = 0.1655, Tm = 0.0255, Yb = 0.170, Lu = 0.0254
  ),

  MORB = c(
    La = 2.50, Ce = 7.50, Pr = 1.32, Nd = 7.30, Sm = 2.63,
    Eu = 1.02, Gd = 3.68, Tb = 0.67, Dy = 4.55, Ho = 1.01,
    Er = 2.97, Tm = 0.456, Yb = 3.05, Lu = 0.455
  )
)

# Save as internal data
usethis::use_data(element_groups, spider_references,
                  internal = TRUE,
                  overwrite = TRUE)

# Units: ppm
