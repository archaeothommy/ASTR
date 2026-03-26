# Copper classification according to Bray et al. (2015)

Classification of copper artefacts according to Bray et al. (2015) into
one of 16 trace element compositional groups based on As, Sb, Ag, or Ni
being below or above 0.1 wt%.

## Usage

``` r
copper_group_bray(
  df,
  elements = c(As = "As", Sb = "Sb", Ag = "Ag", Ni = "Ni"),
  id_column = "ID",
  group_as_number = FALSE,
  ...
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with the column names of the As, Sb, Ag, and Ni
  concentrations.

- id_column:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

- group_as_number:

  logical. If `FALSE`, the default, copper groups are reported as their
  label. Otherwise, copper groups are reported by their number.

- ...:

  Additional arguments for unit conversion, see
  [atomic_conversion](https://archaeothommy.github.io/ASTR/reference/atomic_conversion.md)
  and
  [oxide_conversion](https://archaeothommy.github.io/ASTR/reference/oxide_conversion.md)
  for details.

## Value

If `df` is an [ASTR
object](https://archaeothommy.github.io/ASTR/reference/ASTR.md), the
output is an object of the same type including the ID column, the
contextual columns, the elements used for classification and the alloy
type. In all other cases, the data frame provided as input with the
column for the alloy type.

## References

Bray, P., Cuénod, A., Gosden, C., Hommel, P., Liu, P. and Pollard, A. M.
(2015), Form and flow: the ‘karmic cycle’ of copper. Journal of
Archaeological Science 56, pp. 202-209.
<https://doi.org/10.1016/j.jas.2014.12.013>.

## See also

Other copper alloy classifications:
[`copper_alloy_bb()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_bb.md),
[`copper_alloy_pollard()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_pollard.md)

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

# For ASTR objects, units and oxides are automatically converted
sample_df2 <- as_ASTR(
  data.frame(
    ID = 1:3,
    As2O3_wtP = c(0.2, 0.01, 0.15),
    Sb2O3_wtP = c(0.00, 0.2, 0.11),
    Ag2O_wtP = c(0.00, 0.00, 0.12),
    NiO_wtP = c(0.00, 50, 0.20)
  )
)
copper_group_bray(sample_df2, elements = c(As = "As2O3", Sb = "Sb2O3", Ag = "Ag2O", Ni = "NiO"))
#> ASTR table
#> Analytical columns: As, Sb, Ag, Ni
#> Contextual columns: copper_group_bray 
#> # A data frame: 3 × 6
#>      ID      As     Sb    Ag     Ni copper_group_bray
#>   <int>   [wtP]  [wtP] [wtP]  [wtP] <chr>            
#> 1     1 0.151   0      0      0     As               
#> 2     2 0.00757 0.167  0     39.3   Sb+Ni            
#> 3     3 0.114   0.0919 0.112  0.157 As+Ag+Ni         
```
