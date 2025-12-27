
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ASTR (Archaemetric Standards and Tools in R)

<!-- badges: start -->

[![R-CMD-check](https://github.com/archaeothommy/ASTR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/archaeothommy/ASTR/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/ASTR)](https://CRAN.R-project.org/package=ASTR)
[![Codecov test
coverage](https://codecov.io/gh/archaeothommy/ASTR/graph/badge.svg)](https://codecov.io/gh/archaeothommy/ASTR)

<!-- badges: end -->

ASTR defines and implements a community reporting standard for
archaeometric datasets. It also provides easy-to-use functions for
common plots, statistical analyses, data processing, and data
transformation workflows in archaeometry.

## Overview

ASTR aims to increase reproducibility of data processing by facilitating
the use of scripting languages in archeometry in the narrower sense,
i.e., the material scientific investigation of usually inorganic
archaeological materials.

### Community reporting standard

The community reporting standard defines a [set of conventions on the
structure and naming of datasets](vignettes/VG.ASTRschema.0.0.2.Rmd) to
make them interoperable and allow automated handling of the data. Based
on these conventions, ASTR

- Recognises and seamlessly isotopic and chemical data, their units, and
  analytical precision,
- Handles unit conversion on the fly, including non-SI units such as
  *ppm*, *at%*, and *cps* (counts per second) and between oxides and
  elements

### Tools

The collection provides easy-to-use functions for a wide range of tasks
such as

- [ggplot2](https://ggplot2.tidyverse.org/) geoms for standard plots
  (e.g., spidergrams, KDE)
- Material classification (e.g., copper types)
- Data transformation and processing (e.g., calculation of δ-values from
  standard-sample-bracketing measurements)
- Data conversion (e.g., calculation of lead isotope age model
  parameters)
- Statistics (e.g. distribution of data in a pointcloud of reference
  data)
- Normalisation of data to standard compositions (e.g., chondritic
  composition)
- Unit conversion (e.g., at% to wt% and vice versa)

See the full list on the [package
website](https://archaeothommy.github.io/ASTR/index.html).

Functions do not expect datasets according to the community reporting
standard but default values for their input follow its conventions,
making them particularly easy to use.

<!--
### Example
&#10;include here a small example for inputting a example data set and plotting it such as 
&#10;library(ASTR)
library(ggplot2)
&#10;df <- import()
&#10;ggplot(df) + 
 geom_spidergram()
-->

## Installation

You can install the development version of ASTR from
[GitHub](https://github.com/) with:

``` r
 install.packages("pak")
 pak::pak("archaeothommy/ASTR")
```

## Getting started

We recommend reading the following resources to become familiar with the
package:

- Community reporting standard:
  [Conventions](vignettes/VG.ASTRschema.0.0.2.Rmd) and their
  [explanation](vignettes/VG.ASTR.Conventions.explained.Rmd)

## Contributing and Code of Conduct

Please read our [contributor
guide](https://archaeothommy.github.io/ASTR/CONTRIBUTING.html) to learn
how to contribute to ASTR. The ASTR project is released with a
[Contributor Code of
Conduct](https://archaeothommy.github.io/ASTR/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## Acknowledgements and funding

ASTR was initiated in the workshop *Towards an Archaeological Science
Toolbox in R “ASTR”* at the [Lorentz
Center](https://www.lorentzcenter.nl/) in Leiden (The Netherlands). In
addition to the in-kind funding of the Lorentz Center, the workshop
received funding from the Stichting Nederlands Museum voor Anthropologie
en Praehistorie (Foundation for Anthropology and Prehistory in the
Netherlands). The workshop and further development of ASTR received
funding from the Deutsche Forschungsgemeinschaft (DFG, German Research
Foundation) – project 571205551.
