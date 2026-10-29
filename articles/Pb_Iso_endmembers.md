# Determination of lead isotope endmembers

## Introduction

Lead isotope analysis is a widely employed technique for determining the
provenance of ancient artefacts by comparing the lead (Pb) isotope
ratios of an artefact with those of known ore deposits. However, a
significant limitation of this method arises from the complexity of
ancient metallurgy. It is improbable that all metal at a given
archaeological site originated from a single ore source, and the
historical practice of recycling and mixing metals further complicates
analysis. Consequently, when metals from two distinct ore sources are
combined, the resulting Pb isotope ratios deviate from those of the
original sources. This phenomenon is graphically represented as a
“mixing line,” which plots the isotopic composition of the mixed metal
between the two or more parent ore sources (Stos-Gale 2001).

To mitigate the complexities introduced by metal mixing, (Eshel et al.
2019) proposed a methodology utilizing “endmembers” from a sample group.
Endmembers are defined as samples that lie at the extremes of a mixing
line and are presumed to represent unmixed metals with the most direct
relationship to their parent ore sources. In cases where two primary ore
sources are involved in the metal mixture, this approach allows for the
clear distinction of three groups: the two end-member groups, which
correspond to the unmixed parent materials, and a third group
representing the samples that are a result of the mixing process between
the two.

While defining endmembers as distinct groups is not always precise, it
is preferable to analysing individual data points separately because it
provides a more structured and meaningful interpretation of isotopic
variability (Eshel et al. 2019). Then, assuming that each endmember
reflect a single ore deposit or mining district, provenance is suggested
based on the cluster with the highest probability, considering all
results (Shnyr et al. 2026).

## Use of `pb_iso_endmembers()`

A major challenge for reproducibility has been the visual identification
of endmember clusters. To address this, (Albarede et al. 2024) proposed
a method using principal component analysis (PCA) on ²⁰⁴Pb normalized
data to determine the number of endmembers in a sample set. This
approach maps the maximum and minimum values of the principal component
to the isotope vectors.

Trends in the three dimensional space of ²⁰⁶Pb/²⁰⁴Pb, ²⁰⁷Pb/²⁰⁴Pb, and
²⁰⁸Pb/²⁰⁴Pb are determined by the principal component analysis scores of
each vector $`\vec{p}_{i}`$ as $`[c_1, c_2, c_3]`$ using the
`stat::prcomp()` function. The collection of vectors is considered to
represent mixing between two endmembers, $`c_a`$ and $`c_b`$, when
$`c_1`$ explains 95% of the variance of the group, where:

``` math
    (c_{a} = \min c_{1}) \mapsto \vec{p_{a}} \;and\; 
    (c_{b} = \max c_{1}) \mapsto \vec{p_{b}}
```

This is achieved using the
[`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html) function, which
is incorporated into the
[`pb_iso_endmembers()`](https://archaeothommy.github.io/ASTR/reference/pb_iso_endmembers.md)
function. In addition, the PCA values are subjected to the Shapiro and
Wilk normality using the
[`stats::shapiro.test()`](https://rdrr.io/r/stats/shapiro.test.html)
function. If PC2 and PC3 are not normally distributed, the function
generates a message informing the user that PC2 and PC3 may not be
attributed to random noise.

The ASTR object containing the Pb isotope ratios ²⁰⁶Pb/²⁰⁴Pb,
²⁰⁷Pb/²⁰⁴Pb, and ²⁰⁸Pb/²⁰⁴Pb is appended with an `end_membr` column
identifying each sample as either belonging to an endmember group or the
mixing group.

``` r

pb_iso_endmembers(tel_dor)
#> Warning in .calc_pb_iso_endmembers(x, iso_cols = .pb_iso_cols(), tolerance =
#> tolerance, : PC2 or PC3 are not normally distributed. This may indicate that
#> the variation is not random noise.
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
```

However, this method is limited as it only identifies two points, which
are unlikely to fully represent all endmembers. While $`\vec{p_{a}}`$
and $`\vec{p_{b}}`$ represent the most distinct ends of the set,
additional endmembers can be identified using $`\vec{p_i}`$.

Samples from the same ore body usually share the same geological age and
consequently align along a single isochron. While the two-stage model
(Stacey and Kramers 1975) provides an imperfect representation of
isotopic age, the true distribution of samples from an endmember set
follows the slope of the geochron. Therefore, a more accurate definition
of endmembers involves identifying them as a set of vectors that lie
near a line parallel to the geochron, passing through the principal
vector mapped to either the minimum or maximum values of the first
principal component of the entire data set. This refined method enables
the identification of a comprehensive set of samples that constitute an
endmember group.

A vector $`\vec{e_i}`$, as defined above, is considered an endmember if
it lies within a tolerance of $`\varepsilon`$ from the line
$`\overline{p_i}`$ which passes through $`\vec{p_i}`$ parallel to the
geochron in the Cartesian plane of
$`\left(\frac{^{206}\text{Pb}}{^{204}\text{Pb}},\frac{^{207}\text{Pb}}{^{204}\text{Pb}}\right)`$

``` math
f(\vec{e}, \vec{p}) = |e_2 - (p_1 - (S\times p_2))| < \varepsilon
```

where $`S`$ is the slope of the geochron. The values for $`\varepsilon`$
was chosen as 0.01 by default. This value was manually set for optimal
results based on trial and error, and can be further refined based on
the data.

In addition to $`\varepsilon`$, endmember points may be further
constrained by clamping their distance from the principal point using
the Euclidean distance. This may be required if two distant ores sources
share the same geochron.

``` math
f(\vec{e}, \vec{p}) = ||\vec{e} - \vec{p}|| < d
```

where $`d`$ is the Euclidean distance. The default parameter is chosen
to be `Inf`, as in most cases this clamping may not be required.

``` r

# Example with no clamping
no_clamp <- pb_iso_endmembers(tel_dor)
#> Warning in .calc_pb_iso_endmembers(x, iso_cols = .pb_iso_cols(), tolerance =
#> tolerance, : PC2 or PC3 are not normally distributed. This may indicate that
#> the variation is not random noise.
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

# Example with clamping
clamp <- pb_iso_endmembers(tel_dor, clamp = c(Inf, 0.1))
#> Warning in .calc_pb_iso_endmembers(x, iso_cols = .pb_iso_cols(), tolerance =
#> tolerance, : PC2 or PC3 are not normally distributed. This may indicate that
#> the variation is not random noise.
#> Warning in .calc_pb_iso_endmembers(x, iso_cols = .pb_iso_cols(), tolerance =
#> tolerance, : Endmember group has less than two points. The likelihood of a
#> point being an endmember is low.
clamp[clamp$end_membr == "group2", ]
#> ASTR table
#> Analytical columns: 206Pb/204Pb, 207Pb/204Pb, 208Pb/204Pb
#> Contextual columns: end_membr 
#> # A data frame: 1 × 5
#>      ID `206Pb/204Pb` `207Pb/204Pb` `208Pb/204Pb` end_membr
#>   <int>         <dbl>         <dbl>         <dbl> <chr>    
#> 1    10          19.0          15.7          39.4 group2
```

This results in the creation of two sets of endmembers, $`E_a`$ and
$`E_b`$, where:

``` math
    E_i = \left\{\vec{p_i}, \vec{e_i^1},\ldots, \vec{e_i^n}\right\}
```

In the function output $`E`$ is represented as group1 and group2.

However, if $`|E_i| < 2`$, then it is difficult to consider only
$`\vec{p_i} \in E_i`$ as an endmember, and so $`p_i`$ is considered only
a possible endmember. When this happens, the package informs the user
with a message.

## Reference

Albarede, Francis, Gillan Davis, Liesel Gentelli, et al. 2024. “Bullion
Mixtures in Silver Coinage from Ancient Greece and Egypt.” *Journal of
Archaeological Science* 162 (February): 105918.
<https://doi.org/10.1016/j.jas.2023.105918>.

Eshel, T, Y. Erel, N. Yahalom-Mack, O. Tirosh, and A. Gilboa. 2019.
“Lead Isotopes in Silver Reveal Earliest Phoenician Quest for Metals in
the West Mediterranean.” *Proceedings of the National Academy of
Sciences* 116 (13): 6007–12. <https://doi.org/10.1073/pnas.1817951116>.

Shnyr, Evgeny, Tsvi Kuflik, Karan Desai, and Tzilla Eshel. 2026.
“Determining the Origins of Phoenician Silver: Exploring the Potential
of Machine Learning for Lead Isotope Analysis.” *Journal of
Archaeological Science* 188 (April): 106–499.
<https://doi.org/10.1016/j.jas.2026.106499>.

Stacey, J. S., and J. D. Kramers. 1975. “Approximation of Terrestrial
Lead Isotope Evolution by a Two-Stage Model.” *Earth and Planetary
Science Letters* 26 (2): 207–21.
<https://doi.org/10.1016/0012-821X(75)90088-6>.

Stos-Gale, Zofia Anna. 2001. “The Impact of the Natural Sciences on
Studies of Hacksilber and Early Silver Coinage.” *Hacksilber to Coinage:
New Insights into the Monetary History of the Near East and Greece*,
53–76.
