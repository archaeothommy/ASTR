# Copper alloy classification according to Bayley & Butcher (2004)

Classification of copper alloy artefacts according to Bayley & Butcher
(2004) based on Zn, Sn, and Pb concentrations in wt%. Classification
uses specific thresholds and ratios to define alloy types.

## Usage

``` r
copper_alloy_bb(
  df,
  elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
  id_column = "ID",
  ...
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with column names of Sn, Zn, and Pb
  concentrations.

- id_column:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

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

Bayley, J. and Butcher, S. (2004). Roman brooches in Britain: a
technological and typological study based on the Richborough Collection.
London: Society of Antiquaries of London.
<https://doi.org/10.26530/20.500.12657/50365>

## See also

Other copper alloy classifications:
[`copper_alloy_pollard()`](https://archaeothommy.github.io/ASTR/reference/copper_alloy_pollard.md),
[`copper_group_bray()`](https://archaeothommy.github.io/ASTR/reference/copper_group_bray.md)

## Examples

``` r
sample_df <- data.frame(
  ID = 1:5,
  Sn = c(5, 1, 4, 0.5, 2),
  Zn = c(12, 20, 6, 2, 10),
  Pb = c(1, 0.5, 5, 9, 12)
)
copper_alloy_bb(sample_df)
#>   ID  Sn Zn   Pb   copper_alloy_bb
#> 1  1 5.0 12  1.0          Gunmetal
#> 2  2 1.0 20  0.5             Brass
#> 3  3 4.0  6  5.0 (Leaded) Gunmetal
#> 4  4 0.5  2  9.0     Leaded Copper
#> 5  5 2.0 10 12.0      Leaded Brass

# For ASTR objects, units and oxides are automatically converted
sample_df <- as_ASTR(
  data.frame(
    ID = 1:8,
    SnO_wtP = c(0.5, 0.5, 5, 5, 0.5, 5, 5, 5),
    ZnO_wtP = c(0.5, 0.5, 0.5, 0.5, 5, 5, 0.5, 5),
    PbO_wtP = c(0.5, 5, 0.5, 5, 0.5, 0.5, 5, 5)
  )
)
copper_alloy_bb(sample_df, elements = c(Sn = "SnO", Zn = "ZnO", Pb = "PbO"))
#> ASTR table
#> Analytical columns: Sn, Zn, Pb
#> Contextual columns: copper_alloy_bb 
#> # A data frame: 8 × 5
#>      ID    Sn    Zn    Pb copper_alloy_bb  
#>   <int> [wtP] [wtP] [wtP] <chr>            
#> 1     1 0.441 0.402 0.464 Copper           
#> 2     2 0.441 0.402 4.64  (Leaded) Copper  
#> 3     3 4.41  0.402 0.464 Bronze           
#> 4     4 4.41  0.402 4.64  (Leaded) Bronze  
#> 5     5 0.441 4.02  0.464 Copper/brass     
#> 6     6 4.41  4.02  0.464 Gunmetal         
#> 7     7 4.41  0.402 4.64  (Leaded) Bronze  
#> 8     8 4.41  4.02  4.64  (Leaded) Gunmetal
```
