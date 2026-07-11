# Match all sample-reference pairs against combined analytical uncertainty

Internal function used by
[`amalia()`](https://archaeothommy.github.io/ASTR/reference/amalia.md)
to generate all possible sample-reference combinations and check whether
their isotope ratio differences fall within the combined analytical
uncertainty for all supplied ratios simultaneously.

## Usage

``` r
amalia_match_pairs(df, ref, ratios, errors, id_sample, id_ref)
```

## Arguments

- df:

  Data frame with sample data.

- ref:

  Data frame with reference data.

- ratios:

  Character vector of isotope ratio column names to check.

- errors:

  Character vector of analytical uncertainty column names corresponding
  to `ratios`.

- id_sample:

  String with the column name of the sample IDs in `df`.

- id_ref:

  String with the column name of the reference groups in `ref`.

## Value

A data frame of matched sample-reference pairs. Returns an empty data
frame if no matches are found.
