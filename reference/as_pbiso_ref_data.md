# Create reference data object for LIA endmember distance and probability estimation functions. Data preprocessing and cleaning ensure the reliability and accuracy of provenance analysis. This step results in the removal of all NA values from the selected isotope tables and groups. The step should also exclude groups with a low number samples (in the case of Shnyr et al. (2026), this was 5).

Create reference data object for LIA endmember distance and probability
estimation functions. Data preprocessing and cleaning ensure the
reliability and accuracy of provenance analysis. This step results in
the removal of all NA values from the selected isotope tables and
groups. The step should also exclude groups with a low number samples
(in the case of Shnyr et al. (2026), this was 5).

## Usage

``` r
as_pbiso_ref_data(x, ...)

# S3 method for class 'ASTR'
as_pbiso_ref_data(x, group, min_groupsize = 5L, ...)
```

## Arguments

- x:

  ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope
  ratios.

- ...:

  Additional parameters

- group:

  Name of the column containing isotope groups as character string.

- min_groupsize:

  Integer value for the minimum number of samples in a group, default
  value is `5L`.

## Value

`ASTR_Pbiso_ref_data` object with isotope groupings and isotope columns
of 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb.

## See also

Other Pb isotope functions:
[`age_models`](https://archaeothommy.github.io/ASTR/reference/age_models.md),
[`geom_sk_lines()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md),
[`pb_iso_endmembers()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_endmembers.md),
[`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md),
[`pb_iso_prov_predict()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_predict.md),
[`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md),
[`tel_dor`](https://archaeothommy.github.io/ASTR/reference/tel_dor.md)

## Examples

``` r
as_pbiso_ref_data(GlobaLID_ASTR,
                  names(GlobaLID_ASTR)[[2]],
                  min_groupsize = 5)
#> ASTR table
#> Analytical columns: 207Pb/204Pb, 208Pb/204Pb
#> NULL 
#> # A data frame: 5,784 × 4
#>    `Political province/region` `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb`
#>    <chr>                               <dbl>         <dbl>         <dbl>
#>  1 Catamarca                            18.7          15.6          38.7
#>  2 Catamarca                            18.8          15.6          38.8
#>  3 Catamarca                            18.8          15.7          38.8
#>  4 Catamarca                            18.8          15.7          38.9
#>  5 Catamarca                            18.7          15.6          38.8
#>  6 Catamarca                            18.7          15.6          38.8
#>  7 Catamarca                            18.7          15.6          38.7
#>  8 Catamarca                            18.7          15.6          38.7
#>  9 Catamarca                            18.7          15.6          38.7
#> 10 Catamarca                            18.8          15.6          38.8
#> # ℹ 5,774 more rows
```
