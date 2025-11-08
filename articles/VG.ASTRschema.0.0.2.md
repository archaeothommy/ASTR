# ASTR schema: Naming conventions

ASTR follows the following naming and data conventions, which are
described in detail in this vignette.

## Data preparation

- All variable names are case sensitive.
- Decimals can only be read when indicated by a decimal point (0.5), as
  opposed to decimal commas (0,5).
- Apostrophes and any other special characters should be avoided in the
  sample/variable names.

## Analytical Data columns naming

All columns that contain element and oxide compositions and analytical
errors, isotopic values, or ratios derived therefrom should be named
using the following conventions.

- Only Latin characters can be supported in the column names, (i.e. δ
  and ε will not be identified).

- The names of oxides and trace elements are self-explanatory
  (e.g. `SiO2` or `Si`). Total iron, if given, should be expressed as:
  `FeOtot` or `Fe2O3tot`. Loss on ignition, where known, should be
  expressed as `LOI`.

- Units for values should follow element or oxide, as `_<unit>`. Units
  supported include *all SI units*, as well as *ppm*, *ppb*, *ppt*, *%*,
  *wt%*, *at%*, *w/w%*, *‰*, *counts*, and *cps*, noted as such.

- Where known, specify *wt%* and *at%* instead of using *%*. For *‘per
  mille’*, use the symbol *‰*.

- For isotopic ratios, use simple forms such as `206Pb/204Pb`,
  `87Sr/86Sr`, `147Sm/144Nd`, `eNd` or `d18O`.

- If you have columns with Pb isotope model calculations in your dataset
  prior to importing data, ensure the names do **not** contain a dash
  (‘-’) or underscore (‘\_’) and specify these columns as context in the
  `read_archem()` function. The function
  [`pb_iso_age_model()`](https://archaeothommy.github.io/ASTR/reference/age_models.md)
  can calculate model ages, µ (²³⁸U/²⁰⁴Pb), and κ (²³²Th/²³⁸U) values
  using the Stacey & Kramers ([1975](#ref-stacey1975)), Cumming &
  Richards ([1975](#ref-cumming1975)), and Albarede & Juteau
  ([1984](#ref-albarede1984)) systems within ASTR.

- The following notations will be automatically identified and replaced
  with `NA`, unless you explicitly define other values in
  `read_archem()`: *‘NA’*, *‘N.A.’*, *‘N/A’*, *‘na’*, *‘n/a’*, *‘-’*,
  and *‘n.d.’*. Values containing common excel error messages
  (*\#DIV/0!*, *\#VALUE!*, *\#REF!*, *\#NAME?*, *\#NUM!*, *\#N/A*, and
  *\#NULL!*) are also replaced by `NA` automatically.

- Analytical precision should be indicated in the column name as:
  `_err2SD`, `_errSD`, `_err2SD%`, `_errSD%`, `_errSE`, `_err2SE`
  without indicating the unit. The unit will be inferred from the
  corresponding composition column. SD, 2SD, SE, and 2SE can be
  expressed in absolute or relative values. We strongly recommend that
  the uncertainty is included in the data table, and properly noted
  following the conventions described.

| Components           | Accepted formats                                                    |
|----------------------|---------------------------------------------------------------------|
| Oxides and elements  | `SiO2` ; `Si`                                                       |
| Total iron           | `FeOtot` ; `Fe2O3tot`                                               |
| Loss on ignition     | `LOI`                                                               |
| Isotopic ratios      | `206Pb/204Pb` ; `87Sr/86Sr` ; `147Sm/144Nd` ; `d18O`                |
| Units for value      | `_wt%` ; `_at%`                                                     |
| Analytical precision | `_err2SD` ; `_errSD` ; `_errSD%` ; `_errSD%` ; `_errSE` ; `_err2SE` |

## References

Albarede, F., & Juteau, M. (1984). Unscrambling the lead model ages.
*Geochimica Et Cosmochimica Acta*, *48*(1), 207–212.
<https://doi.org/10.1016/0016-7037(84)90364-8>

Cumming, G. L., & Richards, J. R. (1975). Ore lead isotope ratios in a
continuously changing earth. *Earth and Planetary Science Letters*,
*28*(2), 155–171. <https://doi.org/10.1016/0012-821X(75)90223-X>

Stacey, J. S., & Kramers, J. D. (1975). Approximation of terrestrial
lead isotope evolution by a two-stage model. *Earth and Planetary
Science Letters*, *26*(2), 207–221.
<https://doi.org/10.1016/0012-821X(75)90088-6>
