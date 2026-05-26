# Spidergram internal data

# Element groups

# REE retrieved from https://en.wikipedia.org/wiki/Rare-earth_element,
# HFSE retrieved from https://link.springer.com/rwe/10.1007/1-4020-4496-8_101
# LILE retrieved from https://link.springer.com/rwe/10.1007/1-4020-4496-8_104

standard_groups <- list(
  REE = c(
    "La", "Ce", "Pr", "Nd", "Sm", "Eu", "Gd", "Tb", "Dy",
    "Ho", "Er", "Tm", "Yb", "Lu"
  ),
  HFSE = c("Nb", "Ta", "Zr", "Hf", "Ti"),
  LILE = c("Rb", "Ba", "K", "Sr", "Cs")
)

# Geochemical reference compositions
# units: ppm
references_geochem <- list(
  chondrite = units::set_units(
    value = "mg/kg",
    x = c(
      Cs = 0.188, TI = 0.14, Rb = 2.32, Ba = 2.41, W = 0.095, Th = 0.029,
      U = 0.008, Nb = 0.246, Ta = 0.014, K = 545, La = 0.237, Ce = 0.612,
      Pb = 2.47, Pr = 0.095, Mo = 0.92, Sr = 7.26, P = 1220, Nd = 0.467,
      F = 60.7, Sm = 0.153, Zr = 3.87, Hf = 0.1066, Eu = 0.058, Sn = 1.72,
      Sb = 0.16, Ti = 445, Gd = 0.2055, Tb = 0.0374, Dy = 0.254, Li = 1.57,
      Y = 1.57, Ho = 0.0566, Er = 0.1655, Tm = 0.0255, Yb = 0.17, Lu = 0.0254
    )
  ),
  PM = units::set_units(
    value = "mg/kg",
    x = c(
      Cs = 0.032, TI = 0.005, Rb = 0.635, Ba = 6.989, W = 0.02, Th = 0.085,
      U = 0.021, Nb = 0.713, Ta = 0.041, K = 250, La = 0.687, Ce = 1.775,
      Pb = 0.185, Pr = 0.276, Mo = 0.063, Sr = 21.1, P = 95, Nd = 1.354, F = 26,
      Sm = 0.444, Zr = 11.2, Hf = 0.309, Eu = 0.168, Sn = 0.17, Sb = 0.005,
      Ti = 1300, Gd = 0.596, Tb = 0.108, Dy = 0.737, Li = 1.6, Y = 4.55,
      Ho = 0.164, Er = 0.48, Tm = 0.074, Yb = 0.493, Lu = 0.074
    )
  ),
  NMORB = units::set_units(
    value = "mg/kg",
    x = c(
      Cs = 0.007, TI = 0.0014, Rb = 0.56, Ba = 6.3, W = 0.01, Th = 0.12,
      U = 0.047, Nb = 2.33, Ta = 0.132, K = 600, La = 2.5, Ce = 7.5, Pb = 0.3,
      Pr = 1.32, Mo = 0.31, Sr = 90, P = 510, Nd = 7.3, F = 210, Sm = 2.63,
      Zr = 74, Hf = 2.05, Eu = 1.02, Sn = 1.1, Sb = 0.01, Ti = 7600, Gd = 3.68,
      Tb = 0.67, Dy = 4.55, Li = 4.3, Y = 28, Ho = 1.01, Er = 2.97, Tm = 0.456,
      Yb = 3.05, Lu = 0.455
    )
  ),
  EMORB = units::set_units(
    value = "mg/kg",
    x = c(
      Cs = 0.063, TI = 0.013, Rb = 5.04, Ba = 57, W = 0.092, Th = 0.6, U = 0.18,
      Nb = 8.3, Ta = 0.47, K = 2100, La = 6.3, Ce = 15, Pb = 0.6, Pr = 2.05,
      Mo = 0.47, Sr = 155, P = 620, Nd = 9, F = 250, Sm = 2.6, Zr = 73,
      Hf = 2.03, Eu = 0.91, Sn = 0.8, Sb = 0.01, Ti = 6000, Gd = 2.97, Tb = 0.53,
      Dy = 3.55, Li = 3.5, Y = 22, Ho = 0.79, Er = 2.31, Tm = 0.356, Yb = 2.37,
      Lu = 0.354
    )
  ),
  OIB = units::set_units(
    value = "mg/kg",
    x = c(
      Cs = 0.387, TI = 0.077, Rb = 31, Ba = 350, W = 0.56, Th = 4, U = 1.02,
      Nb = 48, Ta = 2.7, K = 12000, La = 37, Ce = 80, Pb = 3.2, Pr = 9.7,
      Mo = 2.4, Sr = 660, P = 2700, Nd = 38.5, F = 1150, Sm = 10, Zr = 280,
      Hf = 7.8, Eu = 3, Sn = 2.7, Sb = 0.03, Ti = 17200, Gd = 7.62, Tb = 1.05,
      Dy = 5.6, Li = 5.6, Y = 29, Ho = 1.06, Er = 2.62, Tm = 0.35, Yb = 2.16,
      Lu = 0.3
    )
  )
)

# Save as internal data
usethis::use_data(standard_groups,
  references_geochem,
  internal = FALSE,
  overwrite = TRUE
)
