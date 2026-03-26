# Conversion between wt% and at%

Convert chemical compositions between weight percent (*wt%*) and atomic
percent (*at%*). Results are always normalised to 100%.

## Usage

``` r
wt_to_at(df, elements = colnames(get_unit_columns(df, "wtP")), drop = TRUE)

at_to_wt(df, elements = colnames(get_unit_columns(df, "atP")), drop = TRUE)
```

## Arguments

- df:

  Data frame with compositional data.

- elements:

  character vector with the chemical symbols of the elements that should
  be converted. Default are all columns in an
  [`ASTR object`](https://archaeothommy.github.io/ASTR/reference/ASTR)
  in the unit to be converted. See *Details* for further information

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
their chemical symbols. The functions convert only values in *wt%* or
*at%*. If concentrations are present in another concentration unit (e.g.
*ppm*, *µg/kg*), run
[`unify_concentration_unit(df, "wtP")`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
first to convert all concentrations to *wt%*. If `df` is an
[`ASTR object`](https://archaeothommy.github.io/ASTR/reference/ASTR),
only elements will be converted to *at%*, and oxides in *wt%* are
automatically excluded. To convert oxides into *at%* and vice versa,
convert to *wt%* first.

## Examples

``` r
library(magrittr)

# Convert weight percent to atomic percent and to weight percent
df <- data.frame(ID = 1, Si = 46.74, O = 53.26)  # SiO2 composition
at <- wt_to_at(df, elements = c("Si", "O"))
at_to_wt(at, elements = c("Si", "O"))
#>   ID    Si     O
#> 1  1 46.74 53.26

# preserve columns with unconverted values
wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
#>   ID    Si     O   Si_atP    O_atP
#> 1  1 46.74 53.26 33.32926 66.67074

# Use with ASTR objects
# Create ASTR object
test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your ASTR object>).

# Convert columns in wt% to at%
arch_atP <- wt_to_at(arch)

# To convert all applicable concentrations, unify units first:
arch_all <- unify_concentration_unit(arch, "wtP") %>%
  wt_to_at()

# Elements already present in the converted unit are ignored.
rowSums(get_unit_columns(arch_all, "atP")[-1], na.rm = TRUE) > 100
#>  [1]  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
#> [13]  TRUE  TRUE
```
