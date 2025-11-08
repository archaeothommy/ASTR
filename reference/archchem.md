# **archchem**

A tabular data format for chemical analysis datasets in archaeology,
including contextual information, numerical elemental, and isotopic
data. Columns are assigned units (using
[set_units](https://r-quantities.github.io/units/reference/units.html))
and categories (in an attribute `archchem_class`) based on the column
name. The following functions allow to create objects of class
`archchem`, and to interact with them.

- **as_archchem**: Transforms an R `data.frame` to an object of class
  `archchem`.

- **read_archchem**: Reads data from a file (.csv, .xls, .xlsx) into an
  object of class `archchem`.

- **validate**: Performs additional validation on `archchem` and returns
  a `data.frame` as a workable list of potential issues.

- **get\_...\_columns**: Subsets `archchem` tables to columns of a
  certain category (or `archchem_class`), e.g. only contextual data
  columns.

- **remove_units**: Removes unit vector types from the analytical
  columns in an `archchem` table and replaces them with simple numeric
  columns of type `double`.

- **unify_concentration_unit**: Unifies the unit of each concentration
  column, e.g. to either % or ppm (or any SI unit) to avoid mixing units
  in derived analyses.

As `archchem` is derived from `tibble` it is directly compatible with
the data manipulation tools in the tidyverse.

## Usage

``` r
as_archchem(
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

validate(x, quiet = TRUE, ...)

read_archchem(
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

# S3 method for class 'archchem'
format(x, ...)

# S3 method for class 'archchem'
print(x, ...)

get_contextual_columns(x, ...)

get_analytical_columns(x, ...)

get_isotope_columns(x, ...)

get_element_columns(x, ...)

get_ratio_columns(x, ...)

get_concentration_columns(x, ...)

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
  additional properties of archchem tables. Defaults to TRUE

- ...:

  Additional arguments passed to the respective import functions. See
  their documentation for details:

  - [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
    for file formats `.xlsx` or `.xls`

  - [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)
    for all other file formats.

- x:

  an object of class archchem

- quiet:

  should warnings be printed? Defaults to TRUE

- path:

  path to the file that should be read

- delim:

  A character string with the separator for tabular data. Must be
  provided for all file types except `.xlsx` or `.xls`. Default to `,`.
  Use `\t` for tab-separated data.

- unit:

  string with a unit definition that can be understood by
  [set_units](https://r-quantities.github.io/units/reference/units.html),
  e.g. "%", "kg", or "m/s^2"

## Value

Returns an object of class `archchem`, which is a tibble-derived object.

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

# reading an archchem table directly from a file
test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
arch <- read_archchem(test_file, id_column = "Sample", context = 1:7)
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your archchem object>).

# turning a data.frame to an archchem table
test_df <- readr::read_csv(test_file)
#> Rows: 14 Columns: 53
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (12): Sample, Lab no., Site, method_comp, P2O5_wt%, As_wt%, LOI_wt%, Te_...
#> dbl (41): latitude, longitude, Type, 143Nd/144Nd, d65Cu, d65Cu_err2SD, Na2O_...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
arch <- as_archchem(test_df, id_column = "Sample", context = 1:7)
#> Warning: Issue when transforming column "P2O5_wt%" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "LOI_wt%" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "U_ppm" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "Co_ppm" to numeric values: NAs introduced by coercion
#> Warning: Issue when transforming column "Se_ppm" to numeric values: NAs introduced by coercion
#> Warning: 39 missing values across 12 analytical columns
#> Warning: See the full list of validation output with: ASTR::validate(<your archchem object>).

# validating an archchem table
validate(arch)
#> # A tibble: 12 × 3
#>    column      count warning       
#>    <chr>       <int> <chr>         
#>  1 143Nd/144Nd     7 missing values
#>  2 P2O5_wt%        1 missing values
#>  3 S_at%           1 missing values
#>  4 CaO_wt%         1 missing values
#>  5 TiO2_wt%        3 missing values
#>  6 As_wt%          1 missing values
#>  7 LOI_wt%         5 missing values
#>  8 Te_ppm          2 missing values
#>  9 Bi_ppm          2 missing values
#> 10 U_ppm           4 missing values
#> 11 Co_ppm          2 missing values
#> 12 Se_ppm         10 missing values

# extracting subsets of columns
conc <- get_concentration_columns(arch) # see also other get_..._columns functions

# unit-aware arithmetics on archchem columns thanks to the units package
conc$Sb_ppm + conc$Ag_ppb # works
#> Units: [ppm]
#>  [1]  370.50  210.20  256.21  400.35  410.40  453.25  701.12  231.43  107.30
#> [10] 3312.42   95.14   79.61  610.10  390.10
#> attr(,"archchem_class")
#> [1] "archchem_concentration"
if (FALSE) conc$Sb_ppm + conc$`Sn_µg/ml` # \dontrun{} # fails with: cannot convert µg/ml into ppm

# converting units
conc$Sb_ppb <- units::set_units(arch$Sb_ppm, "ppb") %>%
  magrittr::set_attr("archchem_class", "archchem_concentration")

# removing all units from archchem tables
remove_units(arch)
#> archchem table
#> Analytical columns: 143Nd/144Nd, d65Cu, d65Cu_err2SD, Na2O_wt%, BaO_wt%, Pb_wt%, MgO_wt%, Al2O3_wt%, SiO2_wt%, SiO2_errSD%, P2O5_wt%, S_at%, CaO_wt%, TiO2_wt%, MnO_wt%, FeOtot_wt%, FeOtot_err2SD, ZnO_%, K2O_wt%, Cu_wt%, As_wt%, LOI_wt%, Ag_ppb, Sn_µg/ml, Sb_ppm, Te_ppm, Bi_ppm, U_ppm, V_ppm, Cr_ppm, Co_ppm, Ni_ppm, Sr_ppm, Se_ppm, FeOtot/SiO2, (Na2O+K2O)/SiO2, 206Pb/204Pb, 206Pb/204Pb_err2SD, 207Pb/204Pb, 207Pb/204Pb_err2SD, 208Pb/204Pb, 208Pb/204Pb_err2SD, 207Pb/206Pb, 207Pb/206Pb_err2SD, 208Pb/206Pb, 208Pb/206Pb_err2SD
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
#> #   `Na2O_wt%` <dbl>, `BaO_wt%` <dbl>, `Pb_wt%` <dbl>, `MgO_wt%` <dbl>,
#> #   `Al2O3_wt%` <dbl>, `SiO2_wt%` <dbl>, `SiO2_errSD%` <dbl>, `P2O5_wt%` <dbl>,
#> #   `S_at%` <dbl>, `CaO_wt%` <dbl>, `TiO2_wt%` <dbl>, `MnO_wt%` <dbl>,
#> #   `FeOtot_wt%` <dbl>, FeOtot_err2SD <dbl>, `ZnO_%` <dbl>, `K2O_wt%` <dbl>,
#> #   `Cu_wt%` <dbl>, `As_wt%` <dbl>, `LOI_wt%` <dbl>, Ag_ppb <dbl>,
#> #   `Sn_µg/ml` <dbl>, Sb_ppm <dbl>, Te_ppm <dbl>, Bi_ppm <dbl>, U_ppm <dbl>, …

# applying tidyverse data manipulation on archchem tables
arch %>%
  dplyr::group_by(Site) %>%
  dplyr::summarise(mean_Na2O = mean(`Na2O_wt%`))
#> # A tibble: 13 × 2
#>    Site                    mean_Na2O
#>    <chr>                         [%]
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
  dplyr::select(-`Sn_µg/ml`, -`Sb_ppm`) %>%
  dplyr::filter(`Na2O_wt%` > units::set_units(1, "%"))

# unify all concentration units
unify_concentration_unit(conc_subset, "ppm")
#> archchem table
#> Analytical columns: Na2O_wt%, BaO_wt%, Pb_wt%, MgO_wt%, Al2O3_wt%, SiO2_wt%, P2O5_wt%, S_at%, CaO_wt%, TiO2_wt%, MnO_wt%, FeOtot_wt%, ZnO_%, K2O_wt%, Cu_wt%, As_wt%, LOI_wt%, Ag_ppb, Te_ppm, Bi_ppm, U_ppm, V_ppm, Cr_ppm, Co_ppm, Ni_ppm, Sr_ppm, Se_ppm, Sb_ppb 
#> # A data frame: 14 × 29
#>    ID       `Na2O_wt%` `BaO_wt%` `Pb_wt%` `MgO_wt%` `Al2O3_wt%` `SiO2_wt%`
#>    <chr>         [ppm]     [ppm]    [ppm]     [ppm]       [ppm]      [ppm]
#>  1 TR-001        31000       700    63400      7700       39200     316300
#>  2 TR-002_1      22000       700    35200      5500       34600     290600
#>  3 TR-002_2      50000       540    36000      3300       58700     305000
#>  4 TR-003        69000       400    50700      7600       43300     257300
#>  5 TR-004        30000       300    91500      5200       41700     435000
#>  6 TR-005        41000       700   126100      5800       35800     338300
#>  7 TR-006.1      34000       500   126800      6400       56000     338100
#>  8 TR-006.2      18000       400    53100      5900       44700     263900
#>  9 TR-006.3      51000       900    23600      5300       37300     211800
#> 10 smn348        41000      3400   474900      7000       62700     317300
#> 11 smn349        34000       400    25300      4600       29100     169100
#> 12 smn350        45000       700    15600      5800       36000     284900
#> 13 smn351        32000       400    36400      8800       52400     380400
#> 14 8896          37000       600    75100      8400       39700     316700
#> # ℹ 22 more variables: `P2O5_wt%` [ppm], `S_at%` [ppm], `CaO_wt%` [ppm],
#> #   `TiO2_wt%` [ppm], `MnO_wt%` [ppm], `FeOtot_wt%` [ppm], `ZnO_%` [ppm],
#> #   `K2O_wt%` [ppm], `Cu_wt%` [ppm], `As_wt%` [ppm], `LOI_wt%` [ppm],
#> #   Ag_ppb [ppm], Te_ppm [ppm], Bi_ppm [ppm], U_ppm [ppm], V_ppm [ppm],
#> #   Cr_ppm [ppm], Co_ppm [ppm], Ni_ppm [ppm], Sr_ppm [ppm], Se_ppm [ppm],
#> #   Sb_ppb [ppm]
# note that the column names are inaccurate now
```
