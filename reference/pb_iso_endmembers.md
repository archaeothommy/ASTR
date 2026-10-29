# Find endmembers from a list of lead isotope data points.

Finds endmembers from a set of lead isotope data using principal
component analysis and the geochron slope according to the two-stage
model by Stacy and Kramers (1975), following the process outlined in
Shnyr et al. (2026).

## Usage

``` r
pb_iso_endmembers(x, ...)

# S3 method for class 'ASTR'
pb_iso_endmembers(
  x,
  tolerance = c(0.01, 0.01),
  clamp = c(Inf, Inf),
  geo_slope = 0.626208,
  ...
)
```

## Arguments

- x:

  ASTR object containing 206Pb/204Pb, 207Pb/204Pb, and 208Pb/204Pb
  isotope ratios.

- ...:

  Additional parameters

- tolerance:

  Vector of length two, with corresponding tolerance values for group 1
  and group 2 for points considered to lie on the respective geochron
  lines, default is `c(0.01, 0.01)`.

- clamp:

  Limit filter for points away from the principal component end based on
  Euclidean distance, default is `c(Inf, Inf)`.

- geo_slope:

  Whole number value of geo-chron slope, Default value is `0.626208`

## Value

An [ASTR object](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
with additional class attribute `ASTR_Pbiso_endmembr`. The output
extends the input table in `x` with a column `end_membr`, which stores
the estimated endmember groups.

Endmember groups consist of group1, group2, and groupmix. groupmix
represents the values along the mixing line.

## References

Shnyr, E., Kuflik, T., Desai, K., and Eshel, T. (2026) Determining the
origins of Phoenician silver: Exploring the potential of machine
learning for lead isotope analysis. Journal of Archaeological Science
188, pp. 106–499. <https://doi.org/10.1016/j.jas.2026.106499>

Stacey, J. S., & Kramers, J. D. (1975). Approximation of Terrestrial
Lead Isotope Evolution by a Two-Stage Model. Earth and Planetry Science
Letters, 26, 207–221.

## See also

Other Pb isotope functions:
[`age_models`](https://archaeothommy.github.io/ASTR/reference/age_models.md),
[`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md),
[`geom_sk_lines()`](https://archaeothommy.github.io/ASTR/reference/geom_sk_lines.md),
[`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md),
[`pb_iso_prov_predict()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_predict.md),
[`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md),
[`tel_dor`](https://archaeothommy.github.io/ASTR/reference/tel_dor.md)

## Examples

``` r
# example code
pb_iso_endmembers(tel_dor)
#> Warning: PC2 or PC3 are not normally distributed. This may indicate that the variation is not random noise.
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: end_membr 
#> # A data frame: 32 × 5
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` end_membr
#>    <int>         <dbl>         <dbl>         <dbl> <chr>    
#>  1     1          19.0          15.7          39.0 group2   
#>  2     2          19.0          15.7          39.0 group2   
#>  3     3          19.0          15.7          39.1 group2   
#>  4     4          19.0          15.7          39.0 group2   
#>  5     5          19.0          15.7          39.0 group2   
#>  6     6          17.9          15.6          38.0 group1   
#>  7     7          17.9          15.6          38.0 groupmix 
#>  8     8          17.9          15.6          38.0 group1   
#>  9     9          17.9          15.6          38.0 group1   
#> 10    10          19.0          15.7          39.4 group2   
#> # ℹ 22 more rows

# No clamping
no_clamp <- pb_iso_endmembers(tel_dor)
#> Warning: PC2 or PC3 are not normally distributed. This may indicate that the variation is not random noise.
no_clamp[no_clamp$end_membr == "group2", ]
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: end_membr 
#> # A data frame: 12 × 5
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` end_membr
#>    <int>         <dbl>         <dbl>         <dbl> <chr>    
#>  1     1          19.0          15.7          39.0 group2   
#>  2     2          19.0          15.7          39.0 group2   
#>  3     3          19.0          15.7          39.1 group2   
#>  4     4          19.0          15.7          39.0 group2   
#>  5     5          19.0          15.7          39.0 group2   
#>  6    10          19.0          15.7          39.4 group2   
#>  7    24          18.9          15.7          38.9 group2   
#>  8    26          19.0          15.7          39.1 group2   
#>  9    27          19.0          15.7          39.1 group2   
#> 10    29          19.0          15.7          39.0 group2   
#> 11    30          19.0          15.7          39.0 group2   
#> 12    31          19.0          15.7          39.0 group2   

# Clamping reduces the group size by distance from the principal endmember
clamp <- pb_iso_endmembers(tel_dor, clamp = c(Inf, 0.1))
#> Warning: PC2 or PC3 are not normally distributed. This may indicate that the variation is not random noise.
#> Warning: Endmember group has less than two points. The likelihood of a point being an endmember is low.
clamp[clamp$end_membr == "group2", ]
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: end_membr 
#> # A data frame: 1 × 5
#>      ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` end_membr
#>   <int>         <dbl>         <dbl>         <dbl> <chr>    
#> 1    10          19.0          15.7          39.4 group2   

# Reducing tolerance values narrows the grouping around the geochron
pb_iso_endmembers(tel_dor, tolerance = c(0.001, 0.001))
#> Warning: PC2 or PC3 are not normally distributed. This may indicate that the variation is not random noise.
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: end_membr 
#> # A data frame: 32 × 5
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` end_membr
#>    <int>         <dbl>         <dbl>         <dbl> <chr>    
#>  1     1          19.0          15.7          39.0 group2   
#>  2     2          19.0          15.7          39.0 groupmix 
#>  3     3          19.0          15.7          39.1 groupmix 
#>  4     4          19.0          15.7          39.0 groupmix 
#>  5     5          19.0          15.7          39.0 group2   
#>  6     6          17.9          15.6          38.0 group1   
#>  7     7          17.9          15.6          38.0 groupmix 
#>  8     8          17.9          15.6          38.0 groupmix 
#>  9     9          17.9          15.6          38.0 group1   
#> 10    10          19.0          15.7          39.4 group2   
#> # ℹ 22 more rows
```
