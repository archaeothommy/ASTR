# Calculate lead isotope age models

The functions calculate the age model and their respective mu and kappa
values according to the publications they are named after (see
*References*). `pb_iso_age_model()` provides a wrapper for them and
allows to calculate all age models simultaneously.

## Usage

``` r
pb_iso_age_model(
  df,
  ratio_206_204 = "206Pb/204Pb",
  ratio_207_204 = "207Pb/204Pb",
  ratio_208_204 = "208Pb/204Pb",
  model = c("SK75", "CR75", "AJ84", "all")
)

stacey_kramers_1975(
  df,
  ratio_206_204 = "206Pb/204Pb",
  ratio_207_204 = "207Pb/204Pb",
  ratio_208_204 = "208Pb/204Pb"
)

cumming_richards_1975(
  df,
  ratio_206_204 = "206Pb/204Pb",
  ratio_207_204 = "207Pb/204Pb",
  ratio_208_204 = NULL
)

albarede_juteau_1984(
  df,
  ratio_206_204 = "206Pb/204Pb",
  ratio_207_204 = "207Pb/204Pb",
  ratio_208_204 = "208Pb/204Pb"
)
```

## Arguments

- df:

  The data frame from which the age model should be calculated.

- ratio_206_204:

  Name of the column with the 206Pb/204Pb ratio as character string.
  Default is `206Pb/204Pb`.

- ratio_207_204:

  Name of the column with the 207Pb/204Pb ratio as character string.
  Default is `207Pb/204Pb`.

- ratio_208_204:

  Name of the column with the 208Pb/204Pb ratio as character string.
  Default is `208Pb/204Pb`.

- model:

  Character string with the abbreviation of the model to calculate:

  - `SK75` for Stacey & Kramers (1975)

  - `CR75` for Cumming & Richards (1975)

  - `AJ84` for Albarède & Juteau (1984)

  - `all` for all models at once

## Value

The data frame provided as input with columns added for the model age,
mu, and kappa value(s) of the respective age models. The used model is
indicated in the column names of the output by the abbreviations given
above.

## Details

The implemented age models are:

- Stacey & Kramers (1975): `stacey_kramers_1975()`

- Cumming & Richards (1975): `cumming_richards_1975()`

- Albarède & Juteau (1984): `albarede_juteau_1984()`

The used model is indicated in the column names of the output by the
initials of the author's last names and the publication year (e.
g.`SK75` for Stacey & Kramers 1975).

See the references for the respective publications of the age models.
The function for the age model of Albarède & Juteau (1984) is based on
the MATLAB-script of F. Albarède (version 2020-11-06). The age model
published in Albarède et al. (2012) should not be used according to F.
Albarède and is therefore not implemented. Instead, he recommends to use
the age model published in Albarède & Juteau (1984).

The ratio of 208Pb/204Pb is not necessary for cumming_richards_1975. The
function takes it as argument only to be consistent with the input of
the other age model functions. If provided, it will be ignored.

## References

Albarède, F. and Juteau, M. (1984) Unscrambling the lead model ages.
Geochimica et Cosmochimica Acta 48(1), pp. 207–212.
<https://dx.doi.org/10.1016/0016-7037(84)90364-8>.

Albarède, F., Desaulty, A.-M. and Blichert-Toft, J. (2012) A geological
perspective on the use of Pb isotopes in Archaeometry. Archaeometry 54,
pp. 853–867. <https://doi.org/10.1111/j.1475-4754.2011.00653.x>.

Cumming, G.L. and Richards, J.R. (1975) Ore lead isotope ratios in a
continuously changing earth. Earth and Planetary Science Letters 28(2),
pp. 155–171. <https://dx.doi.org/10.1016/0012-821X(75)90223-X>.

Stacey, J.S. and Kramers, J.D. (1975) Approximation of terrestrial lead
isotope evolution by a two-stage model. Earth and Planetary Science
Letters 26(2), pp. 207–221.
\<https://dx.doi.org/10.1016/0012-821X(75)90088-6\<.

## Examples

``` r
# creating example data
df <- tibble::tibble(
  `206Pb/204Pb` = runif(5, min = 18, max = 18.5),
  `207Pb/204Pb` = runif(5, min = 15, max = 15.5),
  `208Pb/204Pb` = runif(5, min = 2, max = 2.2)
)

# calculate values for all age models
pb_iso_age_model(df, model = "all")
#>   206Pb/204Pb 207Pb/204Pb 208Pb/204Pb model_age_SK75 mu_SK75 kappa_SK75
#> 1    18.30038    15.14488    2.006848       -963.871   7.820    -15.103
#> 2    18.07860    15.36644    2.064077       -109.337   8.745    -16.169
#> 3    18.00370    15.38626    2.080466          2.782   8.843    -16.421
#> 4    18.23320    15.43730    2.039134        -65.723   9.016    -15.861
#> 5    18.24889    15.08747    2.080708      -1112.699   7.600    -15.074
#>   model_age_CR75 mu_CR75 kappa_CR75 model_age_AJ84 mu_AJ84 kappa_AJ84
#> 1        326.633  10.575      3.854       -811.770   7.932    -14.881
#> 2        447.135  10.510      3.860        -30.577   8.772    -15.869
#> 3        489.280  10.488      3.862         76.023   8.862    -16.108
#> 4        355.354  10.559      3.855         -0.593   9.015    -15.565
#> 5        358.829  10.558      3.855       -937.725   7.732    -14.866

# calculate values for a specific age model
pb_iso_age_model(df, model = "SK75")
#>   206Pb/204Pb 207Pb/204Pb 208Pb/204Pb model_age_SK75 mu_SK75 kappa_SK75
#> 1    18.30038    15.14488    2.006848       -963.871   7.820    -15.103
#> 2    18.07860    15.36644    2.064077       -109.337   8.745    -16.169
#> 3    18.00370    15.38626    2.080466          2.782   8.843    -16.421
#> 4    18.23320    15.43730    2.039134        -65.723   9.016    -15.861
#> 5    18.24889    15.08747    2.080708      -1112.699   7.600    -15.074
stacey_kramers_1975(df)
#>   206Pb/204Pb 207Pb/204Pb 208Pb/204Pb model_age_SK75 mu_SK75 kappa_SK75
#> 1    18.30038    15.14488    2.006848       -963.871   7.820    -15.103
#> 2    18.07860    15.36644    2.064077       -109.337   8.745    -16.169
#> 3    18.00370    15.38626    2.080466          2.782   8.843    -16.421
#> 4    18.23320    15.43730    2.039134        -65.723   9.016    -15.861
#> 5    18.24889    15.08747    2.080708      -1112.699   7.600    -15.074
```
