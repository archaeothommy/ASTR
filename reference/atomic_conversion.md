# Conversion between wt% and at%

Convert chemical compositions between weight percent (wt%) and atomic
percent (at%).

## Usage

``` r
wt_to_at(df, elements, drop = TRUE)

at_to_wt(df, elements, drop = TRUE)
```

## Arguments

- df:

  Data frame with compositional data.

- elements:

  character vector with the chemical symbols of the elements that should
  be converted.

- drop:

  If `TRUE`, the default, columns with unconverted values are dropped.
  If false, columns with unconverted values are kept and a suffix added
  to the column names of the converted values.

  - `_at` for conversions to atomic percent

  - `_wt` for conversions to weight percent.

## Value

The original data frame with the converted concentrations normalised to
100%.

## Details

The column names of the elements to be converted must be equivalent to
their chemical symbols. Results are always normalised to 100%.

## Examples

``` r
# Convert weight percent to atomic percent and to weight percent
df <- data.frame(Si = 46.74, O = 53.26)  # SiO2 composition
at <- wt_to_at(df, elements = c("Si", "O"))
at_to_wt(at, elements = c("Si", "O"))
#>      Si     O
#> 1 46.74 53.26

# preserve columns with unconverted values
wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
#>      Si     O    Si_at     O_at
#> 1 46.74 53.26 33.32926 66.67074
```
