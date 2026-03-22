#' Conversion between wt% and at%
#'
#' Convert chemical compositions between weight percent (*wt%*) and atomic
#' percent (*at%*). Results are always normalised to 100%.
#'
#' The column names of the elements to be converted must be equivalent to their
#' chemical symbols. The functions convert only values in *wt%* or *at%*. If
#' concentrations are present in another concentration unit (e.g. *ppm*,
#' *µg/kg*), run [`unify_concentration_unit(df,
#' "wtP")`][unify_concentration_unit()] first to convert all concentrations to
#' *wt%*. If `df` is an [`ASTR object`](ASTR), only elements will be converted
#' to *at%*, and oxides in *wt%* are automatically excluded. To convert oxides
#' into *at%* and vice versa, convert to *wt%* first.
#'
#' @param df Data frame with compositional data.
#' @param elements character vector with the chemical symbols of the elements
#'   that should be converted. Default are all columns in an [`ASTR
#'   object`](ASTR) in the unit to be converted. See *Details* for further
#'   information
#' @param drop If `TRUE`, the default, columns with unconverted values are
#'   dropped. If false, columns with unconverted values are kept and a suffix
#'   added to the column names of the converted values.
#'   * `_at` for conversions to atomic percent
#'   * `_wt` for conversions to weight percent.
#'
#' @return The original data frame with the converted concentrations normalised
#'   to 100%.
#'
#' @export
#' @name atomic_conversion
#'
#' @examples
#'
#' library(magrittr)
#'
#' # Convert weight percent to atomic percent and to weight percent
#' df <- data.frame(ID = 1, Si = 46.74, O = 53.26)  # SiO2 composition
#' at <- wt_to_at(df, elements = c("Si", "O"))
#' at_to_wt(at, elements = c("Si", "O"))
#'
#' # preserve columns with unconverted values
#' wt_to_at(df, elements = c("Si", "O"), drop = FALSE)
#'
#' # Use with ASTR objects
#' # Create ASTR object
#' test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
#' arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#'
#' # Convert columns in wt% to at%
#' arch_atP <- wt_to_at(arch)
#'
#' # To convert all applicable concentrations, unify units first:
#' arch_all <- unify_concentration_unit(arch, "wtP") %>%
#'   wt_to_at()
#'
#' # Elements already present in the converted unit are ignored.
#' rowSums(get_unit_columns(arch_all, "atP"), na.rm = TRUE) > 100
#'
wt_to_at <- function(df, elements = colnames(get_unit_columns(df, "wtP")), drop = TRUE) {

  # Validate inputs
  checkmate::assert_data_frame(df)

  # if ASTR object, include only columns with elements
  if (inherits(df, "ASTR")) {
    elements <- intersect(elements, elements_data)
  }

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # Check if all elements are valid chemical elements
  invalid_elements <- setdiff(elements, elements_data)
  if (length(invalid_elements) > 0) {
    stop("The following elements are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  moles <- t(t(df[elements]) / conversion_oxides$AtomicWeight[match(elements, conversion_oxides$Element)])

  total <- rowSums(moles, na.rm = TRUE)
  total[total == 0] <- NA_real_
  at_percent <- moles / total * 100

  df_old <- df

  if (drop) {
    # Replace original columns with atomic percent
    df[elements] <- at_percent
  } else {
    # Add new columns with suffix
    colnames(at_percent) <- paste0(elements, "_atP")
    df[colnames(at_percent)] <- at_percent
  }

  if (inherits(df_old, "ASTR")) {
    df <- preserve_ASTR_attrs(df, df_old)
    df[colnames(at_percent)] <- sapply(
      df[colnames(at_percent)],
      function(x) units::set_units(x, "atP"), simplify = FALSE
    )
  }

  return(df)
}

#' @rdname atomic_conversion
#' @export
at_to_wt <- function(df, elements = colnames(get_unit_columns(df, "atP")), drop = TRUE) {

  # Validate inputs
  checkmate::assert_data_frame(df)

  # if ASTR object, include only columns with elements
  if (inherits(df, "ASTR")) {
    elements <- intersect(elements, elements_data)
  }

  # Check if all requested elements are in df
  missing_from_df <- setdiff(elements, names(df))
  if (length(missing_from_df) > 0) {
    stop("The following elements are not present in df: ",
         paste(missing_from_df, collapse = ", "))
  }

  # Check if all elements are valid chemical elements
  invalid_elements <- setdiff(elements, elements_data)
  if (length(invalid_elements) > 0) {
    stop("The following elements are not valid chemical elements: ",
         paste(invalid_elements, collapse = ", "))
  }

  weight <- t(t(df[elements]) * conversion_oxides$AtomicWeight[match(elements, conversion_oxides$Element)])

  total <- rowSums(weight, na.rm = TRUE)
  total[total == 0] <- NA_real_
  wt_percent <- weight / total * 100

  df_old <- df

  if (drop) {
    # Replace original columns with atomic percent
    df[elements] <- wt_percent
  } else {
    # Add new columns with suffix
    colnames(wt_percent) <- paste0(elements, "_wtP")
    df[colnames(wt_percent)] <- wt_percent
  }

  if (inherits(df_old, "ASTR")) {
    df <- preserve_ASTR_attrs(df, df_old)
    df[colnames(wt_percent)] <- sapply(
      df[colnames(wt_percent)],
      function(x) units::set_units(x, "wtP"), simplify = FALSE
    )
  }

  return(df)
}
