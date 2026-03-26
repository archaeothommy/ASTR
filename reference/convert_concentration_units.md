# Convert units

The function is intended to provide "on-the-fly" unit conversions inside
functions that require values in a certain unit. It converts ALL values
in the units of the values intended to be converted to ensure that e.g.
normalisation is not performed on subsets.

## Usage

``` r
convert_concentration_units(df, values, unit_to, ...)
```

## Arguments

- df:

  ASTR object

- values:

  Character vector with column names of the values to be converted.

- unit_to:

  The unit the values should be converted to

- ...:

  Additional values passed to the conversion functions. This is
  primarily intended for conversion into oxides because this function
  takes a mandatory parameter that does not has a default value.

## Details

It is written in a way that only the converted values of the input are
processed further and that except for them, columns of the unconverted
ASTR object are made available to the user through the function calling
this unit conversion. Use the respective conversion functions for
proper, user-facing unit conversions.
