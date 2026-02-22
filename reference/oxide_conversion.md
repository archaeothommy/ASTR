# Oxide conversion functions

Convert between element and oxide weight percent (oxide%) compositions
using pre-compiled conversion factors.

## Usage

``` r
element_to_oxide(
  df,
  elements,
  oxide_preference,
  which_concentrations = c("all", "major", "minor", "no_trace"),
  normalise = FALSE,
  drop = FALSE
)

oxide_to_element(df, oxides, normalise = FALSE, drop = FALSE)
```

## Arguments

- df:

  Data frame with compositional data.

- elements, oxides:

  Character vector with the chemical symbols of the elements or oxides
  that should be converted.

- oxide_preference:

  String that controls which oxide should be used if an element forms
  more than one oxide. Allowed values are: `reducing`, `oxidising`,
  `ask`, or a named vector mapping the specific oxide to its element.
  See details for further information.

- which_concentrations:

  Character string that determines by concentration which of the
  `elements` or `oxides` are converted. Allowed values are:

  - `all` (convert all elements or oxides; the default)

  - `major` (convert elements or oxides with concentrations \>= 1 wt%)

  - `minor` (convert elements or concentrations between 0.1 and 1 wt%).

  - `no_trace` (convert elements or oxides with concentration \>=0.1
    wt%)

- normalise:

  If `TRUE`, converted concentrations will be normalised to 100%.
  Default to `FALSE`.

- drop:

  If `FALSE`, the default, columns with unconverted values are kept. If
  `TRUE`, columns with unconverted values are dropped. Dropping column
  could result in loss of information as this will also drop columns
  with values excluded from conversion by the parameter
  `which_concentrations`.

## Value

The original data frame with the converted concentrations

## Details

If the dataset includes already an element and its respective oxide, the
conversion leaves the column of the respective oxide or element
unaffected.

In `element_to_oxide()`, the parameter `oxide_preference` controls the
behaviour of the function if the element forms more than one oxide:

- `oxidising`: Use the oxide with the highest oxidation state of the
  element (e.g., `Fe2O3`)

- `reducing`: Use the oxide with the lowest oxidation state of the
  element (e.g., `FeO`)

- `ask`: The user is asked for each element which oxide should be used.

- named vector: A named vector mapping the oxides to be used to the
  elements (e.g., `c(Fe = "FeO", Cu = "Cu2O")`)

In `oxide_to_element()`, conversions from different oxides to the same
element (e.g., Fe₂O₃ and FeO to Fe) result in one column for the element
with the sum of all converted values of the respective element.

Conversion factors are pre-compiled for a wide range of oxides.
consequently, conversion is restricted to the oxides on this list. If
you encounter an oxide that is currently not included, please reach out
to the package maintainers or create a pull request in the [package's
GitHub repo](https://github.com/archaeothommy/ASTR) to add it.

## Examples

``` r
# Example data frame with element weight percents
df <- data.frame(ID = "Sample1", Si = 45, Fe = 50, Al = 5)

# Select elements by oxide_preference
element_to_oxide(df, elements = c("Si", "Fe", "Al"), oxide_preference = "oxidising")
#>        ID Si Fe Al     SiO2   Fe2O3    Al2O3
#> 1 Sample1 45 50  5 96.26789 71.4867 9.447131
element_to_oxide(df, elements = c("Fe", "Al"), oxide_preference = c(Fe = "FeO", Al = "Al2O3"))
#>        ID Si Fe Al     FeO    Al2O3
#> 1 Sample1 45 50  5 71.4867 9.447131
if (FALSE) { # \dontrun{
element_to_oxide(df, elements = c("Si", "Fe", "Al"), oxide_preference = "ask")
} # }

# Loss of information when converting a subset 'which_concentration' and 'drop = TRUE'
df2 <- data.frame(ID = "feldspar", Na = 8.77, Al = 10.29, Si = 32.13, Ba = 0.3, Sr = 0.05)
element_to_oxide(
  df2,
  elements =  names(df2[-1]),
  which_concentration = "major",
  oxide_preference = "reducing",
  drop = TRUE
)
#>         ID     Na2O     AlO     SiO2 BaO SrO
#> 1 feldspar 11.82157 19.4422 68.73527  NA  NA

# Conversions are reversible
oxides <- element_to_oxide(
  df,
  elements = names(df[-1]),
  oxide_preference = "oxidising",
  drop = TRUE,
  normalise = TRUE
)
elements <- oxide_to_element(
  oxides,
  oxides = names(oxides[-1]),
  drop = TRUE,
  normalise = TRUE
)
all.equal(df, elements)
#> [1] TRUE

# Conversion from oxide to element summarises columns converting to the same element
df3 <- data.frame(Fe2O3 = 20, FeO = 20, Cr2O3 = 15, CrO2 = 15, CuO = 20, Cu2O = 20)
oxide_to_element(df3, oxides = names(df3), drop = TRUE)
#>        Fe       Cr       Cu
#> 1 29.5348 19.54877 33.74117
```
