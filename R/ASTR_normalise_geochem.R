#' Geochemical normalisation of data
#'
#' Normalises selected elemental concentrations to a reference composition such
#' as chondrite or MORB.
#'
#' See [references_geochem] for the supported reference compositions.
#' Normalisation to other reference compositions is possible by adding them as
#' named vectors, see examples. They will not be stored permanently in the
#' package and must be exported and reloaded (or their definition included in
#' the script). If you would like to include a new reference composition in
#' ASTR, please reach out to the package maintainers or create a pull request in
#' the [package's GitHub repo](https://github.com/archaeothommy/ASTR) with the
#' values to be included and a literature reference.
#'
#' The function converts all elements in the dataframe for which a reference
#' composition is available. For [ASTR objects][ASTR], unit conversion is
#' handled by the function. For all other objects, the user must ensure that
#' values and reference composition have the same unit.
#'
#' @param df A data frame in wide format.
#' @param reference Character string with the normalisation. See Details for
#'   further information.
#'
#' @return If `df` is an [ASTR object][ASTR], the output is an object of the
#'   same type including the ID column, the contextual columns, the
#'   compositional data that was normalised, and the normalised values of the
#'   respective elements. In all other cases, the data frame provided as input
#'   with columns added for the calculated age model parameters.
#'
#'   The used reference composition is indicated in the column names of the
#'   output by the value of `reference`.
#'
#' @examples
#' df <- data.frame(
#'   Sample = c("A","B"),
#'   La = c(10,5),
#'   Ce = c(20,8)
#' )
#'
#' normalise_geochem(
#'   df,
#'   elements = c("La","Ce"),
#'   reference = "chondrite"
#' )
#'
#' For ASTR objects, units and oxides are automatically converted
#' test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
#' arch <- read_ASTR(test_file, id_column = "Sample", context = 1:7)
#'
#' arch_norm <- normalise_geochem(arch, "chondrite")
#'
#' # adding reference composition for 31X 7835.8A of the CHARM Set
#' references_geochem$"31X 7835.8A" <- units::set_units(
#'   value = "%",
#'   x = c(P = 0.122, Mn = 0.093, Fe = 0.1, Co = 0.313, Ni = 0.158, Cu = 69.93,
#'   Zn = 24.83, As = 0.143, Ag = 0.463, Cd = 0.087, Sn = 0.516, Sb = 0.115,
#'   Pb = 3.15, Bi = 0.112
#'   )
#' )
#'
#' references_geochem$"31X 7835.8A"
#'
#' @export
#'
normalise_geochem <- function(df, reference = names(references_geochem)) {

  reference <- match.arg(reference)

  # Basic checks
  checkmate::assert_data_frame(df)

  elements <- intersect(colnames(df), names(references_geochem[[reference]]))

  if (length(elements) == 0) {
    stop("Dataset does not include any element of the reference data.")
  }

  # Normalisation
  df_norm <- as.data.frame(
    mapply(function(x) {
      t(t(df[[x]]) / references_geochem[[reference]][x])
    },
    elements
    )
  )

  # rename column names
  colnames(df_norm) <- paste0(elements, "_", reference)

  if (inherits(df, "ASTR")) {
    df_norm <- cbind(df["ID"], df_norm)

    df_norm <- suppressWarnings(
      as_ASTR(
        df_norm,
        context = colnames(df_norm)[-1]
      )
    )

    df_norm <- cbind(get_contextual_columns(df), df[elements], df_norm[-1])
    df_norm <- preserve_ASTR_attrs(df_norm, df)

  } else {
    df_norm <- cbind(df, df_norm)
  }

  return(df_norm)
}
