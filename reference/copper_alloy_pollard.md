# Copper alloy classification according to Pollard et al. (2015).

Classification of copper alloy artefacts following the system proposed
in Pollard et al. (2015) based Sn, Zn, and Pb concentrations in wt%.

## Usage

``` r
copper_alloy_pollard(
  df,
  elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
  id_sample = "ID",
  group_as_symbol = FALSE
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with column names of Sn, Zn, and Pb.

- id_sample:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

- group_as_symbol:

  logical. If `FALSE`, the default, copper groups are reported as their
  label. Otherwise, copper groups are reported by their symbol.

## Value

The original data frame with the added column `copper_alloy_Pollard`.

## References

Pollard, A. M., Bray, P., Gosden, C., Wilson, A., and Hamerow, H.
(2015). Characterising copper-based metals in Britain in the first
millennium AD: a preliminary quantification of metal flow and recycling.
Antiquity 89(345), pp. 697-713. <https://doi.org/10.15184/aqy.2015.20>

## Examples

``` r
sample_df <- data.frame(
  ID = 1:8,
  Sn = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
  Zn = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
  Pb = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
)
copper_alloy_pollard(sample_df)
#>   ID  Sn  Zn  Pb copper_alloy_pollard
#> 1  1 0.5 0.5 0.5               Copper
#> 2  2 0.5 0.5 5.0        Leaded copper
#> 3  3 5.0 0.5 0.5               Bronze
#> 4  4 5.0 0.5 5.0        Leaded bronze
#> 5  5 0.5 5.0 0.5                Brass
#> 6  6 5.0 5.0 0.5             Gunmetal
#> 7  7 5.0 0.5 5.0        Leaded bronze
#> 8  8 5.0 5.0 5.0      Leaded gunmetal
```
