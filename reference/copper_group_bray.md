# Copper classification according to Bray et al. (2015)

Classification of copper artefacts according to Bray et al. (2015) into
one of 16 trace element compositional groups based on As, Sb, Ag, or Ni
being below or above 0.1 wt%. Concentrations must be given in wt%.

## Usage

``` r
copper_group_bray(
  df,
  elements = c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni"),
  id_sample = "ID",
  group_as_number = FALSE
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with the column names of the As, Sb, Ag, and Ni
  concentrations.

- id_sample:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

- group_as_number:

  logical. If `FALSE`, the default, copper groups are reported as their
  label. Otherwise, copper groups are reported by their number.

## Value

The original data frame with the added column `copper_group_bray`.

## References

Bray, P., Cuénod, A., Gosden, C., Hommel, P., Liu, P. and Pollard, A. M.
(2015), Form and flow: the ‘karmic cycle’ of copper. Journal of
Archaeological Science 56, pp. 202-209.
<https://doi.org/10.1016/j.jas.2014.12.013>.

## Examples

``` r
# create dataset
sample_df <- data.frame(
  ID = 1:3,
  As = c(0.2, 0.01, 0.15),
  Sb = c(0.00, 0.2, 0.11),
  Ag = c(0.00, 0.00, 0.12),
  Ni = c(0.00, 0.05, 0.20)
)
# classify copper groups
copper_group_bray(sample_df)
#>   ID   As   Sb   Ag   Ni copper_group_bray
#> 1  1 0.20 0.00 0.00 0.00                As
#> 2  2 0.01 0.20 0.00 0.05                Sb
#> 3  3 0.15 0.11 0.12 0.20       As+Sb+Ag+Ni

# classification with group number as output
copper_group_bray(sample_df, group_as_number = TRUE)
#>   ID   As   Sb   Ag   Ni copper_group_bray
#> 1  1 0.20 0.00 0.00 0.00                 2
#> 2  2 0.01 0.20 0.00 0.05                 3
#> 3  3 0.15 0.11 0.12 0.20                16
```
