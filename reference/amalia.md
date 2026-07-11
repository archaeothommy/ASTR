# AMALIA algorithm for matching of sample and reference lead isotope data

Implements the AMALIA (A Matching Algorithm for Lead Isotope Analyses)
algorithm as described in Rodríguez et al. (2023). For each sample, the
algorithm identifies analytically identical reference data by comparing
lead isotope ratios within their combined analytical uncertainties
across three independent isotope ratio dimensions.

## Usage

``` r
amalia(
  df,
  ref,
  ratios_204 = c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb"),
  ratios_206 = c("204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb"),
  error_204 = c("206Pb/204Pb_err2SD", "207Pb/204Pb_err2SD", "208Pb/204Pb_err2SD"),
  error_206 = c("204Pb/206Pb_err2SD", "207Pb/206Pb_err2SD", "208Pb/206Pb_err2SD"),
  id_sample = "ID",
  id_ref = "ID",
  triplet = c("204Pb", "206Pb", "both")
)
```

## Arguments

- df:

  Data frame with sample data including isotope ratios, their analytical
  errors and an ID column.

- ref:

  Data frame with reference data including isotope ratios, their
  analytical errors and an ID column. Must have the same column names as
  `df`.

- ratios_204:

  Character vector of length 3 with column names of the 204Pb-normalised
  isotope ratios. Must be identical in `df` and `ref`. Default to
  `c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb")`.

- ratios_206:

  Character vector of length 3 with column names of the 206Pb-normalised
  isotope ratios. Must be identical in `df` and `ref`. Only used when
  `triplet = "206"` or `triplet = "both"`. Default to
  `c("206Pb/204Pb", "207Pb/206Pb", "208Pb/206Pb")`.

- error_204:

  Character vector of length 3 with column names of the analytical
  uncertainty in 2SD for the 204Pb-normalised ratios. Must be identical
  in both `df` and `ref`. Default to
  `c("206Pb/204Pb_err2SD", "207Pb/204Pb_err2SD", "208Pb/204Pb_err2SD")`.

- error_206:

  Character vector of length 3 with column names of the analytical
  uncertainty (2SD) for the 206Pb-normalised ratios. Must be identical
  in both `df` and `ref`. Only used when `triplet = "206"` or
  `triplet = "both"`. Default to
  `c("206Pb/204Pb_err2SD", "207Pb/206Pb_err2SD", "208Pb/206Pb_err2SD")`.

- id_sample:

  String with the column name of the sample IDs in `df`. Default is
  `"ID"`.

- id_ref:

  String with the column name of the reference groups in `ref`. Default
  is `"ID"`.

- triplet:

  Character string specifying which isotope ratio triplet to use for
  matching. One of `"204"` (206/204, 207/204, 208/204), `"206"`
  (206/204, 207/206, 208/206), or `"both"` (a match must pass both
  triplets simultaneously, following Rodríguez et al. 2023). Default is
  `"204"`.

## Value

A list of three elements:

- `summary_matches`: Data frame with with the number of reference data
  matches per sample.

- `matches`: Data frame with every sample-reference pair that passed the
  AMALIA matching criteria.

- `unmatched`: Character vector with the IDs of samples with no matches
  in the reference data.

## Details

For each sample-reference pair, the function checks whether the absolute
difference between their isotope ratios is smaller than or equal to the
combined analytical uncertainty (sum of both 2SD errors) for all three
ratios in the selected triplet simultaneously.

When `triplet = "both"`, only pairs that pass in both the 204Pb and
206Pb triplet spaces are returned, following the strict application
recommended by Rodríguez et al. (2023).

## References

Rodríguez, J., Sinner, A.G., Martínez-Chico, D. and Santos Zalduegui,
J.F. (2023). AMALIA, A Matching Algorithm for Lead Isotope Analyses:
Formulation and proof of concept at the Roman foundry of Fuente Spitz
(Jaén, Spain). Journal of Archaeological Science: Reports 51, 104192.
<https://doi.org/10.1016/j.jasrep.2023.104192>

## Examples

``` r
df <- data.frame(
  ID = c("Art1", "Art2", "Art3"),
  `206Pb/204Pb` = c(18.244, 18.419, 18.050),
  `207Pb/204Pb` = c(15.634, 15.658, 15.620),
  `208Pb/204Pb` = c(38.407, 38.638, 38.157),
  `206Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
  `207Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
  `208Pb/204Pb_err2SD` = c(0.002, 0.002, 0.002),
  `204Pb/206Pb` = c(0.0537, 0.0539, 0.0554),
  `207Pb/206Pb` = c(0.857, 0.850, 0.865),
  `208Pb/206Pb` = c(2.105, 2.098, 2.114),
  `204Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
  `207Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
  `208Pb/206Pb_err2SD` = c(0.00004, 0.00004, 0.00004),
  check.names = FALSE
)

ref <- data.frame(
  ID = c("Ore_A", "Ore_B", "Ore_C"),
  `206Pb/204Pb` = c(18.242, 18.500, 18.048),
  `207Pb/204Pb` = c(15.633, 15.700, 15.619),
  `208Pb/204Pb` = c(38.405, 38.800, 38.155),
  `206Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
  `207Pb/204Pb_err2SD` = c(0.001, 0.001, 0.001),
  `208Pb/204Pb_err2SD` = c(0.002, 0.002, 0.002),
  `204Pb/206Pb` = c(0.0543, 0.0543, 0.0543),
  `207Pb/206Pb` = c(0.857, 0.850, 0.865),
  `208Pb/206Pb` = c(2.105, 2.098, 2.114),
  `204Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
  `207Pb/206Pb_err2SD` = c(0.00001, 0.00001, 0.00001),
  `208Pb/206Pb_err2SD` = c(0.00004, 0.00004, 0.00004),
  check.names = FALSE
)

amalia(df, ref)
#> 2 sample(s) without matches: Art2, Art3
#> $summary_matches
#>   sample_id n_matches
#> 1      Art1         1
#> 2      Art2         0
#> 3      Art3         0
#> 
#> $matches
#>   sample_id ref_id
#> 1      Art1  Ore_A
#> 
#> $unmatched
#> [1] "Art2" "Art3"
#> 
```
