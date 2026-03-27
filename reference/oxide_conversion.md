# Oxide conversion functions

Convert between element and oxide weight percent ("oxide%") compositions
using pre-compiled conversion factors.

## Usage

``` r
element_to_oxide(
  df,
  elements = colnames(get_unit_columns(df, "wtP")),
  oxide_preference,
  which_concentrations = c("all", "major", "minor", "no_trace"),
  normalise = FALSE,
  drop = FALSE
)

oxide_to_element(
  df,
  oxides = colnames(get_unit_columns(df, "wtP")),
  normalise = FALSE,
  drop = FALSE
)
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
  See *Details* for further information.

- which_concentrations:

  Character string that determines by concentration which of the
  `elements` or `oxides` are converted. Allowed values are:

  - `all` (convert all elements; the default)

  - `major` (convert elements with concentrations \>= 1 wt%)

  - `minor` (convert elements with concentrations between 0.1 and 1
    wt%).

  - `no_trace` (convert elements with concentrations \>=0.1 wt%)

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

If the dataset includes already an element and its oxide, the conversion
leaves the values of the respective oxide or element unaffected. The
functions convert only values in *wt%*. If concentrations are present in
another concentration unit (e.g. *ppm*, *µg/kg*), run
[`unify_concentration_unit(df, "wtP")`](https://archaeothommy.github.io/ASTR/reference/ASTR.md)
first to convert all concentrations to *wt%*. If the input is an
[`ASTR object`](https://archaeothommy.github.io/ASTR/reference/ASTR.md),
the functions convert only elements or oxides with the respective other
type being automatically excluded, even though the unit for both is
*wt%*. To convert oxides into *at%* and vice versa, convert to *wt%*
first.

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
library(magrittr)

# Example data frame with element weight percents
df <- data.frame(ID = "Sample1", Si = 45, Fe = 50, Cr = 5)

# Select elements by oxide_preference
element_to_oxide(df, elements = c("Si", "Fe", "Cr"), oxide_preference = "oxidising")
#>        ID Si Fe Cr     SiO2   Fe2O3     CrO3
#> 1 Sample1 45 50  5 96.26789 71.4867 9.615451
element_to_oxide(df, elements = c("Fe", "Cr"), oxide_preference = c(Fe = "FeO", Cr = "Cr2O3"))
#>        ID Si Fe Cr      FeO    Cr2O3
#> 1 Sample1 45 50  5 64.32447 7.307726
if (FALSE) { # \dontrun{
element_to_oxide(df, elements = c("Si", "Fe", "Cr"), oxide_preference = "ask")
} # }

# Conversions are reversible
oxides <- element_to_oxide(
  df,
  elements = names(df[-1]),
  oxide_preference = "oxidising",
  drop = TRUE
)
elements <- oxide_to_element(
  oxides,
  oxides = names(oxides[-1]),
  drop = TRUE
)
all.equal(df, elements)
#> [1] TRUE

# Loss of information by using 'which_concentration' to convert a subset when 'drop = TRUE'
df2 <- data.frame(ID = "feldspar", Na = 8.77, Al = 10.29, Si = 32.13, Ba = 0.3, Sr = 0.05)
element_to_oxide(
  df2,
  elements =  names(df2[-1]),
  which_concentration = "major",
  oxide_preference = "reducing",
  drop = TRUE
)
#>         ID     Na2O      AlO     SiO2 BaO SrO
#> 1 feldspar 11.82157 16.39146 68.73527  NA  NA

# Conversion from oxide to element summarises columns converting to the same element
df3 <- data.frame(Fe2O3 = 20, FeO = 20, Cr2O3 = 15, CrO2 = 15, CuO = 20, Cu2O = 20)
oxide_to_element(df3, oxides = names(df3), drop = TRUE)
#>        Fe       Cr       Cu
#> 1 29.5348 19.54877 33.74117

# Use with ASTR objects
# Create ASTR object
test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your ASTR object>).

# Convert columns from oxide to wt%
arch_wtP <- element_to_oxide(arch, oxide_preference = "oxidising")

# To convert all applicable concentrations, unify units first:
arch_all <- unify_concentration_unit(arch, "wtP") %>%
  element_to_oxide(oxide_preference = "oxidising")
```
