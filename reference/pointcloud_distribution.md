# Comparing Isotope Samples to Reference Data in 3D Space

This package compares isotope samples to reference data in 3D space to
identify isotopic consistency and the possibility of mixing between
sources.

## Usage

``` r
pointcloud_distribution(
  df,
  ref,
  isotope_sample = c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb"),
  isotope_ref = isotope_sample,
  id_sample = "ID",
  id_ref = id_sample
)
```

## Arguments

- df:

  Working data, with 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb and ID

- ref:

  Reference data with 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb and Group

- isotope_sample, isotope_ref:

  3 Isotpe snf Sample ID ot Refrence Group, names. Default
  c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "ID").

- id_sample, id_ref:

  colum name with the sample ID and Identifyier for reference groups.
  Default "ID".

## Value

A `list` of three elements:

- in_hull:

  `logical`. A Boolean value indicating the **inclusion** of the working
  data (sample points) within the convex **hull** of the reference data.

- centroids:

  `data.frame`. The coordinates of the **centroids** (mean values) for
  each defined reference group.

- distances:

  `matrix`. A distance **matrix** where rows represent the samples and
  columns represent the reference **centroids**, containing the distance
  of each sample from each centroid.

## Details

Calculates the **Convex Hull** for the complete set of reference points
and all specified **subgroups**. It determines the inclusion or
exclusion of sample **Isotope values** within these hulls.

The function also calculates:

- The **centroid** of each reference subgroup as **mean value** of
  points within each vertex group.

- The **distance** from each sample point to every subgroup centroid.

### Interpretation

Inclusion within a hull suggests the sample is part of the **mixing
group** (main hull) or is highly likely to be the specific **end
member** (subgroup hull). The distance calculation provides a measure of
proximity to these end member centers.

## Examples

``` r
# Creaete Synthetic Data
set.seed(24021999)
iso <- c("206Pb/204Pb","207Pb/204Pb","208Pb/204Pb")
## Create Synthetic Reference data
groups <- LETTERS[1:4]
rand_iso <- \(){c(runif(1, 18.3, 19), runif(1, 15.5, 15.9), runif(1, 37.5, 39))}
list_df <- lapply(groups, \(x){
  ls <- sapply(rand_iso(),  \(g){stats::rnorm(20, g, stats::runif(1, 0.05, 0.1))})
  colnames(ls) <- iso
  ls <- as.data.frame(ls)
  ls$ID <- x
  ls
})
ref <- as.data.frame(do.call(rbind, list_df))
## Create working data
df <- as.data.frame(sapply(rand_iso(),  \(g){rnorm(20, g, 0.1)}))
colnames(df) <- iso
df$ID <- letters[1:20]
rm(list_df, iso, groups, rand_iso)
# Run Pointcloud_distribution
pointcloud_distribution(df, ref, isotope_sample = c("206Pb/204Pb",
"207Pb/204Pb", "208Pb/204Pb"), id_sample = "ID")
#> $in_hull
#>   hull_inout     A     B     C     D
#> a      FALSE FALSE FALSE FALSE FALSE
#> b       TRUE FALSE FALSE FALSE FALSE
#> c       TRUE FALSE FALSE FALSE  TRUE
#> d       TRUE FALSE FALSE FALSE FALSE
#> e      FALSE FALSE FALSE FALSE FALSE
#> f      FALSE FALSE FALSE FALSE FALSE
#> g       TRUE FALSE FALSE FALSE FALSE
#> h       TRUE FALSE FALSE FALSE FALSE
#> i       TRUE FALSE FALSE FALSE  TRUE
#> j      FALSE FALSE FALSE FALSE FALSE
#> k       TRUE FALSE FALSE FALSE FALSE
#> l       TRUE FALSE FALSE FALSE FALSE
#> m       TRUE FALSE FALSE FALSE FALSE
#> n       TRUE FALSE FALSE FALSE FALSE
#> o       TRUE FALSE FALSE FALSE FALSE
#> p       TRUE FALSE FALSE FALSE FALSE
#> q      FALSE FALSE FALSE FALSE FALSE
#> r      FALSE FALSE FALSE FALSE FALSE
#> s       TRUE FALSE FALSE FALSE FALSE
#> t       TRUE FALSE FALSE FALSE FALSE
#> 
#> $centroids
#>   ID 206Pb/204Pb 207Pb/204Pb 208Pb/204Pb
#> 1  A    18.90676    15.63670    38.68651
#> 2  B    18.49755    15.55502    37.49381
#> 3  C    18.73894    15.57353    38.62651
#> 4  D    18.47097    15.58188    38.38394
#> 
#> $distances
#>           A         B         C          D
#> a 0.3467945 1.0100437 0.2557936 0.27944308
#> b 0.5774481 0.7495366 0.4305455 0.19930889
#> c 0.5071899 0.9692208 0.3286081 0.07940771
#> d 0.3930040 1.0215753 0.2334398 0.17040417
#> e 0.3636865 1.0374460 0.2687828 0.28295426
#> f 0.5710444 1.0714041 0.3831217 0.24319115
#> g 0.3687799 1.0232475 0.1855639 0.18551396
#> h 0.5122015 0.8214975 0.3820567 0.16727042
#> i 0.5707212 0.8898764 0.3921051 0.05925920
#> j 0.5694056 0.9690502 0.4517148 0.27574097
#> k 0.4107953 0.8812797 0.2777982 0.19693902
#> l 0.4329620 0.9085274 0.3205349 0.21528808
#> m 0.3588225 0.9118006 0.2644440 0.27353803
#> n 0.3146948 1.0046191 0.2395313 0.30350096
#> o 0.5463120 0.7681217 0.4067310 0.16267856
#> p 0.3810937 1.0223545 0.2278692 0.18371364
#> q 0.4472888 1.0967249 0.3143663 0.26011339
#> r 0.8274133 0.6461316 0.6971180 0.38489301
#> s 0.3634613 1.0412516 0.1787841 0.21774540
#> t 0.1178420 1.1647764 0.1506870 0.43952183
#> 
# cleanup
rm(df, ref)
```
