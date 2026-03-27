# Convert units

The function is intended to provide "on-the-fly" unit conversions inside
functions that require values in a certain unit. Use the respective
conversion functions for proper, user-facing unit conversions. It is not
intended to be used by users. It converts *ALL* values in the unit and
convertable units of the values intended to be converted to ensure that
e.g. normalisation is not performed on subsets.

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

Only the converted values of the input are intended to be processed
further and except for them, columns of the unconverted ASTR object
should be made available to the user in the function calling this unit
converter.
