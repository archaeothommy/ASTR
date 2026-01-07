oxideconversion <- read.csv(
  file = "inst/extdata/oxide_conversion.csv",
  stringsAsFactors = FALSE
)

oxide_conversion <- unique(
  oxideconversion[, c(
    "Element",
    "Oxide",
    "element_to_oxide",
    "oxide_to_element"
  )]
)

atomic_conversion <- unique(
  oxideconversion[, c("Element", "AtomicWeight")]
)

stopifnot(
  all(c("Element", "Oxide") %in% names(oxide_conversion)),
  all(c("Element", "AtomicWeight") %in% names(atomic_conversion))
)

usethis::use_data(
  oxide_conversion,
  atomic_conversion,
  internal = TRUE,
  overwrite = TRUE
)

