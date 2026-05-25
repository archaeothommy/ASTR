# Convert between relative and absolute analytical uncertainties

Convert relative to absolute analytical uncertainties and vice versa in
ASTR objects. Work only for objects of class `ASTR`.

## Usage

``` r
rel_to_abs(df)

abs_to_rel(df)
```

## Arguments

- df:

  An ASTR object

## Value

An ASTR object with converted analytical precision columns. The
unchanged input, if it does not contain columns of the respective
analytical precision type

## Examples

``` r
test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your ASTR object>).

arch2 <- abs_to_rel(arch)

arch3 <- rel_to_abs(arch2)

# Conversion is lossless
all.equal(arch$`SiO2_errSD`, arch3$`SiO2_errSD`)
#> [1] TRUE
```
