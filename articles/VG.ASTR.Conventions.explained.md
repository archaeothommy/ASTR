# Data conventions explained

This vignette explains the data conventions that ASTR follows.

## Units

ASTR does not accept isotope, element, or oxide compositions without
explicitly defined units. This design choice is intentional: units carry
essential contextual information that determines how data can be
transformed, compared, and interpreted. Missing or ambiguous units can
lead to subtle but significant errors in downstream calculations, such
as inappropriate normalization, invalid aggregations, or meaningless
statistical analyses.

## Measurement uncertainty

ASTR explicitly handles measurement uncertainty for all analytical data.
Measurement uncertainty is a parameter encompassing the dispersion of
analytical data both random and systematically. It provides a
quantitative estimate of the quality of the measurement.

- **Random uncertainty**: The standard deviation (SD) denotes the
  dispersion or variability of individual data points around the mean
  value of a statistically normal data set and expresses the precision
  of the individual data within the statistical sample. A small SD means
  that the individual data points are close to the mean value (low
  variability), whereas a high SD means that the individual data points
  are more widely dispersed (high variability). In a normal
  distribution, 1 SD covers the range of approximately 68% of all data;
  2 SD covers the range in which approximately 95% of the data in the
  data set is defined. The ratio is expressed in the so-called
  68-95-99.7 rule.

- **Systematic uncertainty**: The standard error (SE) expresses the
  variability of the means of measurements (statistical samples) in
  relation to multiple repetitions (the statistical population). It
  hence expresses the accuracy of the measurement. The SE becomes
  smaller as the sample size increases, since higher repetition of
  measurements provides more reliable information about the true
  population mean. Confidence intervals are used as for the standard
  deviation. A 2-fold standard error (2SD) defines the range around the
  calculated mean that contains the true population mean with ca. 95 %
  probability.

### Limit of detection and limit of quantification

ASTR allows for the intentional and meaningful handling of limits of
detection/quantification. In each quantitative analysis, a threshold can
be defined, below which a concentration of an analysed element can no
longer be quantified. It is dependent on various influences, such as the
instrument and method used (analytical sensitivity), the instrumental or
baseline noise, the instrument stability, the element measured, matrix
effects, measurement conditions including the laboratory environment
(temperature, humidity), etc.

The limit of detection, usually expressed as `LOD` (or other indicative
notation), is defined as the smallest value that can be reliably
detected.

The limit of quantification (LOQ) is defined as the smallest amount that
can be quantified with acceptable precision.

In
[`archchem()`](https://archaeothommy.github.io/ASTR/reference/archchem.md),
the limit of detection where indicated by a below detection notation is
automatically set to `NA`. Users requesting a more advanced approach by
valuing the `LOD` in the ASTR package, e.g. for plotting functions, are
requested to implement their own lambda function redefining the
`bdl_strategy`.

Substitution methods could be e.g. dropping the left-censored value by
replacing it by `NA` or 0, calculating LOD/2 or LOD/√2, skipping \< of
the left-censored value, or using regression models, enhanced censoring
calculations, or maximum likelihood estimates ([Croghan & Egeghy,
2003](#ref-croghan2003f); [Giskeødegård & Lydersen,
2022](#ref-giske%C3%B8deg%C3%A5rd2022); [Helsel, 2006](#ref-helsel2006))

## Bibliography

Croghan, C., & Egeghy, P. P. (2003). Methods of dealing with values
below the limit of detection using SAS. *Southern SAS User Group*.

Giskeødegård, G. F., & Lydersen, S. (2022). Measurements below the
detection limit. *Tidsskrift for Den norske legeforening*.
<https://doi.org/10.4045/tidsskr.22.0439>

Helsel, D. R. (2006). Fabricating data: How substituting values for
nondetects can ruin results, and what can be done about it.
*Chemosphere*, *65*(11), 2434–2439.
<https://doi.org/10.1016/j.chemosphere.2006.04.051>
