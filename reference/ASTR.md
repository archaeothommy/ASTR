# ASTR Schema implementation

A tabular data format for chemical analysis datasets in archaeology,
including contextual information, numerical elemental, and isotopic
data. Columns are assigned units (using
[set_units](https://r-quantities.github.io/units/reference/units.html))
and categories (in an attribute `ASTR_class`) based on the column name.
The following functions allow to create objects of class `ASTR`, and to
interact with them.

- **as_ASTR**: Transforms an R `data.frame` to an object of class
  `ASTR`.

- **read_ASTR**: Reads data from a file (.csv, .xls, .xlsx) into an
  object of class `ASTR`.

- **validate**: Performs additional validation on `ASTR` and returns a
  `data.frame` as a workable list of potential issues.

- **get\_...\_columns**: Subsets `ASTR` tables to columns of a certain
  category (or `ASTR_class`), e.g. only contextual data columns.

- **remove_units**: Removes unit vector types from the analytical
  columns in an `ASTR` table and replaces them with simple numeric
  columns of type `double`.

- **unify_concentration_unit**: Unifies the unit of each concentration
  column, e.g. to either % or ppm (or any SI unit) to avoid mixing units
  in derived analyses.

As `ASTR` is derived from `tibble` it is directly compatible with the
data manipulation tools in the tidyverse.

## Usage

``` r
as_ASTR(
  df,
  id_column = "ID",
  context = c(),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() NA_character_,
  guess_context_type = TRUE,
  na = c("", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.", "#DIV/0!", "#VALUE!",
    "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"),
  drop_columns = FALSE,
  validate = TRUE,
  ...
)

read_ASTR(
  path,
  id_column = "ID",
  context = c(),
  delim = ",",
  guess_context_type = TRUE,
  na = c("", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.", "#DIV/0!", "#VALUE!",
    "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() NA_character_,
  drop_columns = FALSE,
  validate = TRUE,
  ...
)

validate(x, quiet = TRUE, ...)

# S3 method for class 'ASTR'
format(x, ...)

# S3 method for class 'ASTR'
print(x, ...)

get_contextual_columns(x, ...)

get_analytical_columns(x, ...)

get_isotope_columns(x, ...)

get_element_columns(x, ...)

get_ratio_columns(x, ...)

get_concentration_columns(x, ...)

get_unit_columns(x, units, ...)

remove_units(x, ...)

unify_concentration_unit(x, unit, ...)
```

## Arguments

- df:

  a data.frame containing the input table

- id_column:

  name of the ID column. Defaults to "ID"

- context:

  columns that provide contextual (non-measurement) information; may be
  column names, integer positions, or a logical inclusion vector

- bdl:

  strings representing “below detection limit” values. By default, the
  following are recognized: "b.d.", "bd", "b.d.l.", "bdl", "\<LOD", "\<"

- bdl_strategy:

  function used to replace BDL strings. Defaults to a static function
  returning NA

- guess_context_type:

  should appropriate data types for contextual columns be guessed
  automatically? Defaults to TRUE

- na:

  character vector of strings to be interpret as missing values. By
  default, the following are recognized: "", "n/a", "NA", "N.A.", "N/A",
  "na", "-", "n.d.", "n.a.", "#DIV/0!", "#VALUE!", "#REF!", "#NAME?",
  "#NUM!", "#N/A", "#NULL!"

- drop_columns:

  should columns that are neither marked as contextual in `context`, nor
  automatically identified as analytical from the column name, be
  dropped to proceed with the reading? Defaults to FALSE

- validate:

  should the post-reading input validation be run, which checks for
  additional properties of ASTR tables. Defaults to TRUE

- ...:

  Additional arguments passed to the respective import functions. See
  their documentation for details:

  - [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
    for file formats `.xlsx` or `.xls`

  - [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)
    for all other file formats.

- path:

  path to the file that should be read

- delim:

  A character string with the separator for tabular data. Must be
  provided for all file types except `.xlsx` or `.xls`. Default to `,`.
  Use `\t` for tab-separated data.

- x:

  an object of class ASTR

- quiet:

  should warnings be printed? Defaults to TRUE

- units:

  A character vector with units to be selected.

- unit:

  string with a unit definition that can be understood by
  [set_units](https://r-quantities.github.io/units/reference/units.html),
  e.g. "%", "kg", or "m/s^2"

## Value

Returns an object of class `ASTR`, which is a tibble-derived object.

## Details

The input data files can be fairly freeform, i.e. no specified elements,
oxides, or isotopic ratios are required and no exact order of these
needs to be adhered to. Analyses can contain as many analytical columns
as necessary.

The column that contains the unique samples identifier must be specified
using the `ID` argument. If the dataset contains duplicate ids they will
be renamed consecutively using the following convention: `_1`,`_2`, ...
`_n`.

Metadata contained within the dataset must be marked using the `context`
argument. If any column in the dataframe is not specified as context and
not recognised as an analytical column, this will result in an error.

Below detection limit notation (i.e. ‘b.d.’, ‘bd’, ‘b.d.l.’, ‘bdl’,
‘\<LOD’, or ‘\<..’) for element and oxide concentrations is specified
using the `bdl` argument. One or more notations can be used as is
appropriate for the dataset, and can be notations not included in the
list above. The argument `bdl_strategy` is used to specify the value for
handling detection limits. This is to facilitate the different handling
needs of the detection limit for future statistical applications, as
opposed to automatically assigning such values as ‘NA’.

Missing values are allowed anywhere in the data file body, and will be
replaced by `NA` automatically.

## Examples

``` r
library(magrittr)

# reading an ASTR table directly from a file
test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your ASTR object>).

# turning a data.frame to an ASTR table
test_df <- readr::read_csv(test_file)
#> Rows: 14 Columns: 53
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (12): Sample, Lab no., Site, method_comp, P2O5_wt%, As_wt%, LOI_wt%, Te_...
#> dbl (41): latitude, longitude, Type, 143Nd/144Nd, d65Cu, d65Cu_err2SD, Na2O_...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
arch <- as_ASTR(test_df, id_column = "Sample", context = 1:7)
#> Warning: Issue when transforming column "P2O5_wt%" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "LOI_wt%" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "U_ppm" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "Co_ppm" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "Se_ppm" to numeric values: NAs introduced by coercion
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your ASTR object>).

# validating an ASTR table
validate(arch)
#> # A tibble: 12 × 3
#>    column      count warning       
#>    <chr>       <int> <chr>         
#>  1 143Nd/144Nd     7 missing values
#>  2 P2O5            1 missing values
#>  3 S               1 missing values
#>  4 CaO             1 missing values
#>  5 TiO2            3 missing values
#>  6 As              1 missing values
#>  7 LOI             5 missing values
#>  8 Te              2 missing values
#>  9 Bi              2 missing values
#> 10 U               4 missing values
#> 11 Co              2 missing values
#> 12 Se             10 missing values

# extracting subsets of columns
conc <- get_concentration_columns(arch) # see also other get_..._columns functions

# unit-aware arithmetics on ASTR columns thanks to the units package
conc$Sb + conc$Ag # works
#> Units: [mg/kg]
#>  [1]  370.50  210.20  256.21  400.35  410.40  453.25  701.12  231.43  107.30
#> [10] 3312.42   95.14   79.61  610.10  390.10
#> attr(,"ASTR_class")
#> [1] "ASTR_concentration"
if (FALSE) conc$Sb + conc$Sn # \dontrun{} # fails with: cannot convert µg/ml into ppm

# converting units
conc$Sb <- units::set_units(arch$Sb, "ppb") %>%
  magrittr::set_attr("ASTR_class", "ASTR_concentration")

# removing all units from ASTR tables
remove_units(arch)
#> ASTR table
#> Analytical columns: 143Nd/144Nd, d65Cu, d65Cu_err2SD, Na2O, BaO, Pb, MgO, Al2O3, SiO2, SiO2_errSD%, P2O5, S, CaO, TiO2, MnO, FeOtot, FeOtot_err2SD, ZnO, K2O, Cu, As, LOI, Ag, Sn, Sb, Te, Bi, U, V, Cr, Co, Ni, Sr, Se, FeOtot/SiO2, (Na2O+K2O)/SiO2, 206Pb/204Pb, 206Pb/204Pb_err2SD, 207Pb/204Pb, 207Pb/204Pb_err2SD, 208Pb/204Pb, 208Pb/204Pb_err2SD, 207Pb/206Pb, 207Pb/206Pb_err2SD, 208Pb/206Pb, 208Pb/206Pb_err2SD
#> Contextual columns: Sample, Lab no., Site, latitude, longitude, Type, method_comp 
#> # A data frame: 14 × 54
#>    ID       Sample   `Lab no.` Site         latitude longitude  Type method_comp
#>    <chr>    <chr>    <chr>     <chr>           <dbl>     <dbl> <dbl> <chr>      
#>  1 TR-001   TR-001   3421/19   Bochum           51.5      7.22     1 ICP-MS     
#>  2 TR-002_1 TR-002_1 3423/19   Oviedo           43.4     -5.84     2 ICP-MS     
#>  3 TR-002_2 TR-002_2 3435/19   Oviedo           43.4     -5.84     2 ICP-MS     
#>  4 TR-003   TR-003   3422/19   佛山             23.0    113.       3 ICP-MS     
#>  5 TR-004   TR-004   3429/19   Băiuț            43.2     23.1      4 ICP-MS     
#>  6 TR-005   TR-005   3430/19   Şuior            41.4     24.9      5 ICP-MS     
#>  7 TR-006.1 TR-006.1 3431/19   Blagodat         41.5     25.5      5 ICP-MS     
#>  8 TR-006.2 TR-006.2 3432/19   Pezinok          45.9     15.9      1 ICP-MS     
#>  9 TR-006.3 TR-006.3 3433/19   Free State …     50.4      7.65     4 ICP-MS     
#> 10 smn348   smn348   3424/19   Aggenys          51.0      8.03     3 ICP-MS     
#> 11 smn349   smn349   3425/19   Chiprovtsi       50.7      6.41     3 ICP-MS     
#> 12 smn350   smn350   3426/19   Krusov Dol;…     40.7     24.6      5 ICP-MS     
#> 13 smn351   smn351   3427/19   Masua            37.7     24.0      1 ICP-MS     
#> 14 8896     8896     3428/19   Σπαρτη           37.1     22.4      1 ICP-MS     
#> # ℹ 46 more variables: `143Nd/144Nd` <dbl>, d65Cu <dbl>, d65Cu_err2SD <dbl>,
#> #   Na2O <dbl>, BaO <dbl>, Pb <dbl>, MgO <dbl>, Al2O3 <dbl>, SiO2 <dbl>,
#> #   `SiO2_errSD%` <dbl>, P2O5 <dbl>, S <dbl>, CaO <dbl>, TiO2 <dbl>, MnO <dbl>,
#> #   FeOtot <dbl>, FeOtot_err2SD <dbl>, ZnO <dbl>, K2O <dbl>, Cu <dbl>,
#> #   As <dbl>, LOI <dbl>, Ag <dbl>, Sn <dbl>, Sb <dbl>, Te <dbl>, Bi <dbl>,
#> #   U <dbl>, V <dbl>, Cr <dbl>, Co <dbl>, Ni <dbl>, Sr <dbl>, Se <dbl>,
#> #   `FeOtot/SiO2` <dbl>, `(Na2O+K2O)/SiO2` <dbl>, `206Pb/204Pb` <dbl>, …

# applying tidyverse data manipulation on ASTR tables
arch %>%
  dplyr::group_by(Site) %>%
  dplyr::summarise(mean_Na2O = mean(Na2O))
#> # A tibble: 13 × 2
#>    Site                    mean_Na2O
#>    <chr>                       [wtP]
#>  1 Aggenys                       4.1
#>  2 Blagodat                      3.4
#>  3 Bochum                        3.1
#>  4 Băiuț                         3  
#>  5 Chiprovtsi                    3.4
#>  6 Free State Geduld Mines       5.1
#>  7 Krusov Dol; Krushev Dol       4.5
#>  8 Masua                         3.2
#>  9 Oviedo                        3.6
#> 10 Pezinok                       1.8
#> 11 Şuior                         4.1
#> 12 Σπαρτη                        3.7
#> 13 佛山                          6.9
conc_subset <- conc %>%
  dplyr::select(-Sn, -Sb) %>%
  dplyr::filter(Na2O > units::set_units(4, "wtP"))

# unify all concentration units
unify_concentration_unit(conc_subset, "ppb")
#> ASTR table
#> Analytical columns: Na2O, BaO, Pb, MgO, Al2O3, SiO2, P2O5, S, CaO, TiO2, MnO, FeOtot, ZnO, K2O, Cu, As, LOI, Ag, Te, Bi, U, V, Cr, Co, Ni, Sr, Se 
#> # A data frame: 6 × 28
#>   ID         Na2O    BaO     Pb    MgO  Al2O3   SiO2   P2O5     S    CaO    TiO2
#>   <chr>     [ppb]  [ppb]  [ppb]  [ppb]  [ppb]  [ppb]  [ppb] [atP]  [ppb]   [ppb]
#> 1 TR-002_2 5   e7 5.40e5 3.60e7 3.30e6 5.87e7 3.05e8 1.10e6  3.68 2   e7 5500000
#> 2 TR-003   6.90e7 4   e5 5.07e7 7.6 e6 4.33e7 2.57e8 2.3 e6  2.76 3.91e7 2700000
#> 3 TR-005   4.1 e7 7   e5 1.26e8 5.80e6 3.58e7 3.38e8 2.90e6  0.61 2.06e7 1800000
#> 4 TR-006.3 5.10e7 9   e5 2.36e7 5.3 e6 3.73e7 2.12e8 2.40e6  3.93 4.08e7 1500000
#> 5 smn348   4.1 e7 3.4 e6 4.75e8 7   e6 6.27e7 3.17e8 2.8 e6  0.21 7.14e7      NA
#> 6 smn350   4.50e7 7   e5 1.56e7 5.80e6 3.60e7 2.85e8 1.9 e6  1.95 1.39e7 1700000
#> # ℹ 17 more variables: MnO [ppb], FeOtot [ppb], ZnO [ppb], K2O [ppb], Cu [ppb],
#> #   As [ppb], LOI [ppb], Ag [ppb], Te [ppb], Bi [ppb], U [ppb], V [ppb],
#> #   Cr [ppb], Co [ppb], Ni [ppb], Sr [ppb], Se [ppb]
```
