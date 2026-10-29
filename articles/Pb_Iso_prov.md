# Lead isotope provenance functions

## Introduction

Provenance studies using lead isotope analysis use three ratios of the
four naturally occurring lead isotopes. These are: `206Pb/204Pb`,
`207Pb/204Pb`, `208Pb/204Pb`.

The isotopic compositions in LIA are initially represented in a three
dimensional coordinate system (Albarede, Davis, Gentelli, et al. 2024).

However, current approaches to lead isotope analysis, such as amalia(),
rely heavily on visual inspection or simple distance-based metrics,
methods that struggle to capture the complex structure and overlaps
within large isotopic datasets. As a result, provenance interpretations
often differ substantially between researchers, even when studying the
same assemblages. By contrast, an algorithmic framework provides a
systematic, data-driven alternative that detects patterns, reduces
overlaps, and minimizes subjective interpretation. This shift not only
improves reproducibility but also opens the door to identifying
previously unrecognised ore sources (Shnyr et al. 2026).

The lead isotope provenance functions follow the [ASTR
schema](https://archaeothommy.github.io/ASTR/articles/VG.ASTRschema.0.0.2.md)
and only accept ASTR objects. Working with ASTR objects is described
[here](https://archaeothommy.github.io/ASTR/articles/ASTR.showcase.md)

For the purposes of demonstration, lead isotope data from the Tel Dor
silver hoards will be used as sample data (Shnyr et al. 2026), and a
modified [GlobaLID database](https://globalid.dmt-lb.de/), containing
lead isotope ratios grouped by the Political province/region variable,
will be used as reference data.

``` r

tel_dor
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> NULL 
#> # A data frame: 32 × 4
#>       ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb`
#>    <int>         <dbl>         <dbl>         <dbl>
#>  1     1          19.0          15.7          39.0
#>  2     2          19.0          15.7          39.0
#>  3     3          19.0          15.7          39.1
#>  4     4          19.0          15.7          39.0
#>  5     5          19.0          15.7          39.0
#>  6     6          17.9          15.6          38.0
#>  7     7          17.9          15.6          38.0
#>  8     8          17.9          15.6          38.0
#>  9     9          17.9          15.6          38.0
#> 10    10          19.0          15.7          39.4
#> # ℹ 22 more rows
```

``` r

GlobaLID_ASTR
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: Political province/region 
#> # A data frame: 5,935 × 5
#>    ID           Political province/r…¹ `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb`
#>    <chr>        <chr>                          <dbl>         <dbl>         <dbl>
#>  1 Catamarca_1  Catamarca                       18.7          15.6          38.7
#>  2 Catamarca_2  Catamarca                       18.8          15.6          38.8
#>  3 Catamarca_3  Catamarca                       18.8          15.7          38.8
#>  4 Catamarca_4  Catamarca                       18.8          15.7          38.9
#>  5 Catamarca_5  Catamarca                       18.7          15.6          38.8
#>  6 Catamarca_6  Catamarca                       18.7          15.6          38.8
#>  7 Catamarca_7  Catamarca                       18.7          15.6          38.7
#>  8 Catamarca_8  Catamarca                       18.7          15.6          38.7
#>  9 Catamarca_9  Catamarca                       18.7          15.6          38.7
#> 10 Catamarca_10 Catamarca                       18.8          15.6          38.8
#> # ℹ 5,925 more rows
#> # ℹ abbreviated name: ¹​`Political province/region`
```

## Provenance functions

There are two main methods which can be used for provenance analysis.
The first is the standard Euclidean distance function, with an added
mass fractionation correction (Albarede, Davis, Gentelli, et al. 2024),
and the second is a machine learning method, where a pre-trained extreme
gradient boosting (XGBoost) model is used to obtain provenance
probabilities (Shnyr et al. 2026). In both cases, sample and reference
data are provided as ASTR objects.

### Creating reference data object

Before using the functions, the reference data must be transformed into
an `ASTR_Pbiso_ref_data` object. This can be achieved using the
[`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md)
function, which removes all variables except the `ASTR_context`
designated as the grouping variable and the lead isotope ratios. The
reference dataset can sometimes contain groups with too few samples for
reliable analysis. It is therefore advisable to exclude these groups
from the reference dataset. The `min_groupsize` argument can be used to
set an integer cutoff value. Only groups containing at least
`min_groupsize` samples will be retained.

``` r

GlobalLID_ASTR_ref <- as_pbiso_ref_data(GlobaLID_ASTR, group = "Political province/region", min_groupsize = 5L)
GlobalLID_ASTR_ref
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

### Standard Euclidean distance

The standard model for estimating three dimensional distances for lead
isotope values involves measuring the Euclidean distance between two
vectors, $`\vec{x}`$ and $`\vec{x'}`$. This calculation follows the
established formula:

``` math
d(\vec{x}, \vec{x'}) = \sqrt{\sum_{i=1}^{n} (x_i - x'_i)^2}
```

This is the method used by the function
[`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md)
when the `dist_type` value is set to `"ed"`, which stands for ‘Euclidean
distance’.

According to Albarede, Davis, Blichert-Toft, et al. (2024), the standard
method fails to account for statistical errors. These errors are
addressed by weighting the data with the full covariance matrix $`W`$ of
the NIST 981 lead isotope reference material. The adjusted distance is
calculated as:

``` math
d = \sqrt{(x - x')^T W^{-1} (x - x')}
```
.

In this formula, $`T`$ denotes the transpose of the vector.

``` r

euc_dist(tel_dor, GlobalLID_ASTR_ref, n = 1)
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`,
#> `208Pb/204Pb`)`
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
```

### Algorithm accounting for mass dependent fractionation

Recently, Albarede, Davis, Gentelli, et al. (2024) introduced a Pb
isotope provenance algorithm that significantly improves the correction
of mass-dependent fractionation, a long standing challenge in lead
isotope analysis.

The methodology utilizes the distance $`d_i`$ between an artefact and
the mass-dependent fractionation line passing through ore $`i`$. This is
implemented by setting `dist_type` to `"mfd"`. Provided that lead
isotope ratios differ by less than one decimal point, the respective
fractionation lines are considered parallel.

The distance $`d_i`$ is computed using the vector
$`\vec{\Delta X_i} = (\vec{x}_i - \vec{x}_0)`$, where $`\vec{x}_0`$
represents the artefact and $`\vec{x}_i`$ represents the ore.The
artefact is represented as:

``` math
\vec{x}_0=\left[\left(^{206}Pb/^{204}Pb\right)_0,\left(^{207}Pb/^{204}Pb\right)_0,\left(^{208}Pb/^{204}Pb\right)_0\right]
```

The ore is represented as:

``` math
\vec{x}_i=\left[\left(^{206}Pb/^{204}Pb\right)_i,\left(^{207}Pb/^{204}Pb\right)_i,\left(^{208}Pb/^{204}Pb\right)_i\right]
```

The mass-dependent fractionation line is defined by the vector
$`\vec{v}`$:

``` math
\vec{v}=\left[2\left(^{206}Pb/^{204}Pb\right)_0,3\left(^{207}Pb/^{204}Pb\right)_0,4\left(^{208}Pb/^{204}Pb\right)_0\right]
```

The digits in $`\vec{v}`$ correspond to the atomic mass differences of
the isotopes. With $`\vec{n} = \vec{v}/||\vec{v}||`$ as the unit vector,
the distance $`d_i`$ is calculated using the cross-product:

``` math
d_i = ||\vec{\Delta X_i} \times \vec{n}||
```

The fractionation factor $`f_i`$ is computed as a dot product:

``` math
f_i = \vec{\Delta X_i} \cdot \vec{n}
```

To obtain a dimensionless distance, the error matrix $`W`$ is defined
as:

``` math
W=
\begin{bmatrix}
2x^*_x & 0 & 0\\
0 & 3x^*_y & 0\\
0 & 0 & 4x^*_z\\
\end{bmatrix}
\begin{bmatrix}
1 & 0.96 & 0.94\\
0.96 & 1 & 0.96\\
0.94 & 0.96 & 1
\end{bmatrix}
\begin{bmatrix}
2x^*_x & 0 & 0\\
0 & 3x^*_y & 0\\
0 & 0 & 4x^*_z\\
\end{bmatrix}
```

The outer matrices are diagonal standard deviation matrices for common
lead, with a fractionation factor $`s`$ of 0.001. Squared distances
$`d^2`$ are normalised to the two dimensional shadow of $`W`$
perpendicular to $`\vec{n}`$. This requires Gram Schmidt
orthogonalisation to find perpendicular vectors. Since $`W`$ is derived
from reference materials, this metric is not a formal Mahalanobis
distance. Normalised squared distances follow a chi squared distribution
with two degrees of freedom. Consequently, ores with $`d^2`$ values
exceeding 5.99 are rejected at the 95% confidence level.

``` r

mf_dist(tel_dor, GlobalLID_ASTR_ref, n = 1, s = 0.001)
#> Joining with `by = join_by(ID, `206Pb/204Pb`, `207Pb/204Pb`,
#> `208Pb/204Pb`)`
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
```

The
[`pb_iso_prov_dist()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_prov_dist.md)
provides a wrapper for them and allows to calculate all age models
simultaneously. All distance functions use the
[`as_pbiso_ref_data()`](https://archaeothommy.github.io/ASTR/reference/as_pbiso_ref_data.md)
function, regular `ASTR objects` to lead isotope reference data.

``` r

pb_iso_prov_dist(tel_dor, GlobaLID_ASTR, ref_group = "Political province/region",
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

### Machine learning model

Models trained using
[`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md)
go through a data processing pipeline as outlined by (Shnyr et al.
2026):

- Outlier identification
- SMOTE data imputation
- XGBoost Classification and model training.

#### Outlier identification

Outlier identification and elimination are achieved using the DBSCAN
(Density Based Spatial Clustering of Applications with Noise) algorithm,
which can identify outliers and subgroup patterns within regions.

DBSCAN facilitates the removal of outliers and the formation of clusters
within lead isotopic data, reducing potential overlaps between regions.

The neighbourhood radius ($`\epsilon`$) determines the appropriate value
for clustering. This is controlled by the `.eps` argument.

To ensure reliability, only samples above a certain number should be
clustered. This is controlled by the `.minSize` argument.

#### SMOTE data imputation

SMOTE (Synthetic Minority Over sampling Technique) is a methodology that
creates synthetic data points for the minority class through
interpolation.

Using SMOTE enables ML models to better identify patterns in the data,
potentially leading to more accurate predictions.

The k neighbour parameter in the SMOTE algorithm controls how many
nearby data points are considered when generating synthetic samples for
minority classes. A smaller k neighbour value focuses on closer
neighbours, while a larger value includes a broader range of neighbours,
affecting the diversity of synthetic samples (Chawla et al. 2002).

#### XGBoost classification and model training

The XGBoost algorithm was applied to train a binary classification model
using the three isotopic ratios as input features and the resulting
regional cluster names, previously derived from DBSCAN, as target
labels.

This iterative process involved encoding the data, applying SMOTE, and
training the XGBoost model for each cluster. The final model is a list
of individual XGBoost models that can effectively distinguish between
target and non target classes, leveraging the refined dataset for
reliable predictions.

``` r

ml_model <- pb_iso_train_data(GlobalLID_ASTR_ref)
```

#### Machine learning based provenance prediction

Providing the sample data `ASTR` object with the model created
using[`pb_iso_train_data()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_train_data.md)
produces a new `ASTR` object containing the provenance probabilities for
the given reference data groups.

``` r

pb_iso_prov_predict(tel_dor, model_list = ml_model, .top = 1)
```

## Reference

Albarede, Francis, Gillan Davis, Janne Blichert-Toft, et al. 2024. “A
New Algorithm for Using Pb Isotopes to Determine the Provenance of
Bullion in Ancient Greek Coinage.” *Journal of Archaeological Science*
163 (March): 105919. <https://doi.org/10.1016/j.jas.2023.105919>.

Albarede, Francis, Gillan Davis, Liesel Gentelli, et al. 2024. “Bullion
Mixtures in Silver Coinage from Ancient Greece and Egypt.” *Journal of
Archaeological Science* 162 (February): 105918.
<https://doi.org/10.1016/j.jas.2023.105918>.

Chawla, N. V., K. W. Bowyer, L. O. Hall, and W. P. Kegelmeyer. 2002.
“SMOTE: Synthetic Minority Over-sampling Technique.” *Journal of
Artificial Intelligence Research* 16 (June): 321–57.
<https://doi.org/10.1613/jair.953>.

Shnyr, Evgeny, Tsvi Kuflik, Karan Desai, and Tzilla Eshel. 2026.
“Determining the Origins of Phoenician Silver: Exploring the Potential
of Machine Learning for Lead Isotope Analysis.” *Journal of
Archaeological Science* 188 (April): 106–499.
<https://doi.org/10.1016/j.jas.2026.106499>.
