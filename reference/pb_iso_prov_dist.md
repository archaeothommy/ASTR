# Euclidean distance for Pb isotope ratios to ore sources

Calculates the Euclidean distance of each isotope sample to a reference
data set and gives the closest regions to the groups. Mass fractionation
follows the procedure outlined in Albarede et al. (2024).

## Usage

``` r
pb_iso_prov_dist(x, ...)

# S3 method for class 'ASTR'
pb_iso_prov_dist(
  x,
  ref,
  ref_group,
  dist_type = c("ed", "mf", "all"),
  n = 1,
  s = 0.001,
  ...
)

euc_dist(x, ...)

# S3 method for class 'ASTR'
euc_dist(x, ref, ref_group, n = 1, ...)

mf_dist(x, ...)

# S3 method for class 'ASTR'
mf_dist(x, ref, ref_group, n = 1, s = 0.001, ...)
```

## Arguments

- x:

  ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope
  ratios for analysis.

- ...:

  Additional parameters.

- ref:

  ASTR object containing 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb isotope
  ratios as a provenance reference.

- ref_group:

  Name of the column containing isotope groups as a character string.

- dist_type:

  Distance type to use, simple Euclidean (`"ed"`), mass-fractionation
  corrected (`"mfd"`), or both (`"all"`)

- n:

  Length of result output, default value is `1`.

- s:

  Mass fractionation factor, default value is `0.001`.

## Value

ASTR object of matched x, reference, and corresponding distance values.

## References

Albarede, F., Davis, G., Blichert-Toft, J., Gentelli, L., Gitler, H.,
Pinto, M., and Telouk, P. (2024) A new algorithm for using Pb isotopes
to determine the provenance of bullion in ancient Greek coinage. Journal
of Archaeological Science 163, 105919.
<https://doi.org/10.1016/j.jas.2023.105919>

## See also

Other Pb isotope functions:
[`age_models`](https://archaeothommy.github.io/ASTR/reference/age_models.md),
[`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md),
[`geom_sk_lines()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md),
[`pb_iso_endmembers()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_endmembers.md),
[`pb_iso_prov_predict()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_predict.md),
[`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md),
[`tel_dor`](https://archaeothommy.github.io/ASTR/reference/tel_dor.md)

## Examples

``` r
GlobaLID_ASTR_ref <- as_pbiso_ref_data(GlobaLID_ASTR,
                                   names(GlobaLID_ASTR)[[2]],
                                   min_groupsize = 5)

# Euclidean distance
euc_dist(tel_dor, GlobaLID_ASTR_ref, n = 1)
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb, ed_ref_206Pb/204Pb,
#>                     ed_ref_207Pb/204Pb, ed_ref_208Pb/204Pb
#> Contextual columns: ed_dist, ed_ref_Political province/region 
#> # A data frame: 32 × 9
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` ed_dist
#>    <int>         <dbl>         <dbl>         <dbl>   <dbl>
#>  1     1          19.0          15.7          39.0 0.00300
#>  2     2          19.0          15.7          39.0 0.00500
#>  3     3          19.0          15.7          39.1 0.00650
#>  4     4          19.0          15.7          39.0 0.0158 
#>  5     5          19.0          15.7          39.0 0.00927
#>  6     6          17.9          15.6          38.0 0.00539
#>  7     7          17.9          15.6          38.0 0.0103 
#>  8     8          17.9          15.6          38.0 0.00707
#>  9     9          17.9          15.6          38.0 0.00608
#> 10    10          19.0          15.7          39.4 0.0502 
#> # ℹ 22 more rows
#> # ℹ 4 more variables: `ed_ref_Political province/region` <chr>,
#> #   `ed_ref_206Pb/204Pb` <dbl>, `ed_ref_207Pb/204Pb` <dbl>,
#> #   `ed_ref_208Pb/204Pb` <dbl>

# Mass fractionation correction
mf_dist(tel_dor, GlobaLID_ASTR_ref, n = 1, s = 0.001)
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb, mf_ref_206Pb/204Pb,
#>                     mf_ref_207Pb/204Pb, mf_ref_208Pb/204Pb
#> Contextual columns: mf_dist_sq, mf_ref_Political province/region 
#> # A data frame: 32 × 9
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` mf_dist_sq
#>    <int>         <dbl>         <dbl>         <dbl>      <dbl>
#>  1     1          19.0          15.7          39.0     0.0663
#>  2     2          19.0          15.7          39.0     0.164 
#>  3     3          19.0          15.7          39.1     0.0786
#>  4     4          19.0          15.7          39.0     0.0760
#>  5     5          19.0          15.7          39.0     0.0373
#>  6     6          17.9          15.6          38.0     0.0228
#>  7     7          17.9          15.6          38.0     0.192 
#>  8     8          17.9          15.6          38.0     0.228 
#>  9     9          17.9          15.6          38.0     0.0107
#> 10    10          19.0          15.7          39.4     0.952 
#> # ℹ 22 more rows
#> # ℹ 4 more variables: `mf_ref_Political province/region` <chr>,
#> #   `mf_ref_206Pb/204Pb` <dbl>, `mf_ref_207Pb/204Pb` <dbl>,
#> #   `mf_ref_208Pb/204Pb` <dbl>

# Wrapper function where the reference data is of class 'ASTR_Pb_iso_ref_data'
pb_iso_prov_dist(tel_dor,
                 GlobaLID_ASTR,
                 ref_group = names(GlobaLID_ASTR)[[2]],
                 dist_type = "all")
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb, ed_ref_206Pb/204Pb,
#>                     ed_ref_207Pb/204Pb, ed_ref_208Pb/204Pb, mf_ref_206Pb/204Pb,
#>                     mf_ref_207Pb/204Pb, mf_ref_208Pb/204Pb
#> Contextual columns: ed_dist, ed_ref_Political province/region, mf_dist_sq,
#>                     mf_ref_Political province/region 
#> # A data frame: 32 × 14
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` ed_dist
#>    <int>         <dbl>         <dbl>         <dbl>   <dbl>
#>  1     1          19.0          15.7          39.0 0.00300
#>  2     2          19.0          15.7          39.0 0.00500
#>  3     3          19.0          15.7          39.1 0.00650
#>  4     4          19.0          15.7          39.0 0.0158 
#>  5     5          19.0          15.7          39.0 0.00927
#>  6     6          17.9          15.6          38.0 0.00539
#>  7     7          17.9          15.6          38.0 0.0103 
#>  8     8          17.9          15.6          38.0 0.00707
#>  9     9          17.9          15.6          38.0 0.00608
#> 10    10          19.0          15.7          39.4 0.0502 
#> # ℹ 22 more rows
#> # ℹ 9 more variables: `ed_ref_Political province/region` <chr>,
#> #   `ed_ref_206Pb/204Pb` <dbl>, `ed_ref_207Pb/204Pb` <dbl>,
#> #   `ed_ref_208Pb/204Pb` <dbl>, mf_dist_sq <dbl>,
#> #   `mf_ref_Political province/region` <chr>, `mf_ref_206Pb/204Pb` <dbl>,
#> #   `mf_ref_207Pb/204Pb` <dbl>, `mf_ref_208Pb/204Pb` <dbl>

# Wrapper function where reference data is not of class 'ASTR_Pb_iso_ref_data'
pb_iso_prov_dist(tel_dor,
                 GlobaLID_ASTR_ref,
                 dist_type = "all")
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`, `208Pb/204Pb`)`
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb, ed_ref_206Pb/204Pb,
#>                     ed_ref_207Pb/204Pb, ed_ref_208Pb/204Pb, mf_ref_206Pb/204Pb,
#>                     mf_ref_207Pb/204Pb, mf_ref_208Pb/204Pb
#> Contextual columns: ed_dist, ed_ref_Political province/region, mf_dist_sq,
#>                     mf_ref_Political province/region 
#> # A data frame: 32 × 14
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` ed_dist
#>    <int>         <dbl>         <dbl>         <dbl>   <dbl>
#>  1     1          19.0          15.7          39.0 0.00300
#>  2     2          19.0          15.7          39.0 0.00500
#>  3     3          19.0          15.7          39.1 0.00650
#>  4     4          19.0          15.7          39.0 0.0158 
#>  5     5          19.0          15.7          39.0 0.00927
#>  6     6          17.9          15.6          38.0 0.00539
#>  7     7          17.9          15.6          38.0 0.0103 
#>  8     8          17.9          15.6          38.0 0.00707
#>  9     9          17.9          15.6          38.0 0.00608
#> 10    10          19.0          15.7          39.4 0.0502 
#> # ℹ 22 more rows
#> # ℹ 9 more variables: `ed_ref_Political province/region` <chr>,
#> #   `ed_ref_206Pb/204Pb` <dbl>, `ed_ref_207Pb/204Pb` <dbl>,
#> #   `ed_ref_208Pb/204Pb` <dbl>, mf_dist_sq <dbl>,
#> #   `mf_ref_Political province/region` <chr>, `mf_ref_206Pb/204Pb` <dbl>,
#> #   `mf_ref_207Pb/204Pb` <dbl>, `mf_ref_208Pb/204Pb` <dbl>
```
