# Copper alloy classification according to Pollard et al. (2015).

Classification of copper alloy artefacts following the system proposed
in Pollard et al. (2015) based Sn, Zn, and Pb concentrations in wt%.

## Usage

``` r
copper_alloy_pollard(
  df,
  elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
  id_column = "ID",
  group_as_symbol = FALSE,
  ...
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with column names of Sn, Zn, and Pb.

- id_column:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

- group_as_symbol:

  logical. If `FALSE`, the default, copper groups are reported as their
  label. Otherwise, copper groups are reported by their symbol.

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

Pollard, A. M., Bray, P., Gosden, C., Wilson, A., and Hamerow, H.
(2015). Characterising copper-based metals in Britain in the first
millennium AD: a preliminary quantification of metal flow and recycling.
Antiquity 89(345), pp. 697-713. <https://doi.org/10.15184/aqy.2015.20>

## See also

Other copper alloy classifications:
[`copper_alloy_bb()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_bb.md),
[`copper_group_bray()`](https://archaeothommy.github.io/ASTR/reference/copper_group_bray.md)

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

# For ASTR objects, units and oxides are automatically converted
sample_df <- as_ASTR(
  data.frame(
    ID = 1:8,
    SnO_wtP = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
    ZnO_wtP = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
    PbO_wtP = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
  )
)
copper_alloy_pollard(sample_df, elements = c(Sn = "SnO", Zn = "ZnO", Pb = "PbO"))
#> ASTR table
#> Analytical columns: Sn, Zn, Pb
#> Contextual columns: copper_alloy_pollard 
#> # A data frame: 8 × 5
#>      ID    Sn    Zn    Pb copper_alloy_pollard
#>   <int> [wtP] [wtP] [wtP] <chr>               
#> 1     1 0.441 0.402 0.464 Copper              
#> 2     2 0.441 0.402 4.64  Leaded copper       
#> 3     3 4.41  0.402 0.464 Bronze              
#> 4     4 4.41  0.402 4.64  Leaded bronze       
#> 5     5 0.441 4.02  0.464 Brass               
#> 6     6 4.41  4.02  0.464 Gunmetal            
#> 7     7 4.41  0.402 4.64  Leaded bronze       
#> 8     8 4.41  4.02  4.64  Leaded gunmetal     
```
