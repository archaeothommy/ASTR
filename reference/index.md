# Package index

## ASTR objects

Functions for creating and handling ASTR objects.

- [`as_ASTR()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`read_ASTR()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`validate()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`format(`*`<ASTR>`*`)`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`print(`*`<ASTR>`*`)`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_contextual_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_analytical_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_isotope_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_element_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_ratio_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_concentration_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_error_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`get_unit_columns()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`remove_units()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  [`unify_concentration_unit()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  : ASTR Schema implementation

- [`rel_to_abs()`](https://archaeothommy.github.io/ASTR/reference/error_conversion.md)
  [`abs_to_rel()`](https://archaeothommy.github.io/ASTR/reference/error_conversion.md)
  : Convert between relative and absolute analytical uncertainties

- [`bdl_strategy_none()`](https://archaeothommy.github.io/ASTR/reference/bdl_strategies.md)
  [`bdl_strategy_default()`](https://archaeothommy.github.io/ASTR/reference/bdl_strategies.md)
  [`bdl_strategy_negative()`](https://archaeothommy.github.io/ASTR/reference/bdl_strategies.md)
  :

  Strategies to replace "below detection limit" values in
  [`as_ASTR()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md),
  and
  [`read_ASTR()`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
  with the `bdl_strategy` argument

## Data subsetting

Pre-compiled lists for easier subsetting of data

- [`isotopes_data`](https://archaeothommy.github.io/ASTR/reference/isotopes_data.md)
  : Isotopes
- [`elements_data`](https://archaeothommy.github.io/ASTR/reference/elements_data.md)
  : Chemical elements
- [`oxides_data`](https://archaeothommy.github.io/ASTR/reference/oxides_data.md)
  : Oxides
- [`special_oxide_states`](https://archaeothommy.github.io/ASTR/reference/special_oxide_states.md)
  : Special oxide states

## Unit conversions

Functions and data tables for conversions between untis not covered in
{units}

- [`wt_to_at()`](https://archaeothommy.github.io/ASTR/reference/atomic_conversion.md)
  [`at_to_wt()`](https://archaeothommy.github.io/ASTR/reference/atomic_conversion.md)
  : Conversion between wt% and at%
- [`element_to_oxide()`](https://archaeothommy.github.io/ASTR/reference/oxide_conversion.md)
  [`oxide_to_element()`](https://archaeothommy.github.io/ASTR/reference/oxide_conversion.md)
  : Oxide conversion functions
- [`conversion_oxides`](https://archaeothommy.github.io/ASTR/reference/conversion_oxides.md)
  : Conversion factors from oxides to elements

## Calculations, Classifications, Statistics

Functions for data transformation

- [`copper_alloy_bb()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_bb.md)
  : Copper alloy classification according to Bayley & Butcher (2004)
- [`copper_alloy_pollard()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_pollard.md)
  : Copper alloy classification according to Pollard et al. (2015).
- [`copper_group_bray()`](https://archaeothommy.github.io/ASTR/reference/copper_group_bray.md)
  : Copper classification according to Bray et al. (2015)
- [`pb_iso_age_model()`](https://archaeothommy.github.io/ASTR/reference/age_models.md)
  [`stacey_kramers_1975()`](https://archaeothommy.github.io/ASTR/reference/age_models.md)
  [`cumming_richards_1975()`](https://archaeothommy.github.io/ASTR/reference/age_models.md)
  [`albarede_juteau_1984()`](https://archaeothommy.github.io/ASTR/reference/age_models.md)
  : Calculate lead isotope age models
- [`amalia()`](https://archaeothommy.github.io/ASTR/reference/amalia.md)
  : AMALIA algorithm for matching of sample and reference lead isotope
  data
- [`pointcloud_distribution()`](https://archaeothommy.github.io/ASTR/reference/pointcloud_distribution.md)
  : Comparing isotope samples to reference data in 3D space

## Visualisation

Functions for plotting data

- [`geom_kde2d()`](https://archaeothommy.github.io/ASTR/reference/geom_kde2d.md)
  : Draw 2D kernel density estimate polygons by quantiles
- [`geom_sk_lines()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md)
  [`geom_sk_labels()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md)
  : Lead Evolution Geom for Stacey & Kramers (1975)

## Data

Datasets included in the package

- [`ArgentinaDatabase`](https://archaeothommy.github.io/ASTR/reference/ArgentinaDatabase.md)
  : Lead isotope data from Argentina
- [`GlobaLID_ASTR`](https://archaeothommy.github.io/ASTR/reference/GlobaLID_ASTR.md)
  : GlobaLID lead isotope database
- [`tel_dor`](https://archaeothommy.github.io/ASTR/reference/tel_dor.md)
  : LIA points of silver hoard from Tell Dor (Israel)

## Machine Learning & Provenance Analsis

ML classifier training, and proveanceing of samples using eucldian
distance and ML probalities.

- [`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md)
  : Create reference data object for LIA endmember distance and
  probability estimation functions. Data preprocessing and cleaning
  ensure the reliability and accuracy of provenance analysis. This step
  results in the removal of all NA values from the selected isotope
  tables and groups. The step should also exclude groups with a low
  number samples (in the case of Shnyr et al. (2026), this was 5).
- [`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md)
  : Train XGBoost model
- [`pb_iso_prov_predict()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_predict.md)
  : Predict isotope provenance
- [`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md)
  [`euc_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md)
  [`mf_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md)
  : Euclidean distance for Pb isotope ratios to ore sources
- [`pb_iso_endmembers()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_endmembers.md)
  : Find endmembers from a list of lead isotope data points.
