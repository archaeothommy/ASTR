# Copper alloy classification according to Bayley & Butcher (2004)

Classification of copper alloy artefacts according to Bayley & Butcher
(2004) based on Zn, Sn, and Pb concentrations in wt%. Concentrations
must be given in wt%. Classification uses specific thresholds and ratios
to define alloy types.

## Usage

``` r
copper_alloy_bb(
  df,
  elements = c(Sn = "Sn", Zn = "Zn", Pb = "Pb"),
  id_sample = "ID"
)
```

## Arguments

- df:

  data frame with the data to be classified.

- elements:

  named character vector with column names of Zn, Sn, and Pb
  concentrations.

- id_sample:

  name of the column in `df` with the identifiers of each row. Default
  to `ID`.

## Value

Original data frame with added column `copper_alloy_bb`.

## References

Bayley, J. and Butcher, S. (2004). Roman brooches in Britain: a
technological and typological study based on the Richborough Collection.
London: Society of Antiquaries of London.
<https://doi.org/10.26530/20.500.12657/50365>

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
```
