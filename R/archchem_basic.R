#' @name archchem
#' @rdname archchem
#'
#' @title \strong{archchem}
#'
#' @description A function to create a data format for chemical analysis datasets
#' in archaeology containing numerical elemental and isotopic data. Loads data
#' from a file (.csv, .xls, .xlsx) or object (dataframe) in R. The data format
#' will contain analytical data as well as corresponding contextual information
#' and metadata (labelled as context).
#'
#' @param df a data.frame containing the input table
#' @param path  File path (including extension) to the file to read
#' @param ... further arguments passed to or from other methods
#' @param id_column name of the ID column present in df (or in the file at path).
#' Defaults to "ID"
#' @param context Columns that provide contextual (non-measurement) information;
#' may be column names, integer positions, or a logical inclusion vector.
#' @param bdl Strings representing “below detection limit” values. By default,
#' the following are recognized: "b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<".
#' @param bdl_strategy Function used to replace BDL strings. Defaults to a
#' function returning NA.
#' @param guess_context_type If TRUE, attempt to infer appropriate classes for
#' context columns.
#' @param na Character vector of strings to be interpret as missing values.
#'
#' @export
as_archchem <- function(
  df, id_column = "ID", context = c(),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() {
    NA_character_
  }, # this only allows static functions, essentially: bdl_replace = "NA"
  # in case more sophisticated handling is desired:
  # bdl_strategy = function(x, colname) { bdl_lookup_table[colname] / sqrt(2) }
  # bdl_lookup_table = c("Fe_%" = 3)
  guess_context_type = TRUE,
  na = c(
    "", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.",
    "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"
  ),
  ...
) {
  # input checks
  checkmate::assert_data_frame(df)
  checkmate::assert_names(colnames(df), must.include = id_column)
  # add ID column to context for the following operation
  if (!inherits(context, "character")) { context <- colnames(df)[context] }
  context <- append(context, id_column)
  # determine and apply column types
  constructors <- colnames_to_constructors(
    df, context, bdl, bdl_strategy, guess_context_type, na
  )
  df <- purrr::map2(df, constructors, function(col, f) f(col))
  # turn into tibble-derived object
  df <- tibble::new_tibble(df, nrow = nrow(df), class = "archchem")
  # create/move ID column
  df <- df %>%
    dplyr::mutate(ID = .data[[id_column]]) %>%
    dplyr::relocate("ID", .before = 1)
  return(df)
}

get_cols_with_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(x) {
      inherits(x, classes)
    }
  ))
}

get_cols_without_class <- function(x, classes) {
  dplyr::select(x, tidyselect::where(
    function(x) {
      !inherits(x, classes)
    }
  ))
}

#' @param path path to the file that should be read
#' @param delim A character string with the separator for tabular data. Use
#'   `\t` for tab-separated data. Must be provided for all file
#'   types except `.xlsx` or `.xls`.
#' @rdname archchem
#' @export
read_archchem <- function(
  path, id_column = "ID", context = c(),
  delim = "\t",
  guess_context_type = TRUE,
  na = c(
    "", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.",
    "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"
  ),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() {
    NA_character_
  }
) {
  ext <- strsplit(basename(path), split = "\\.")[[1]][-1] # extract file format

  if (!(ext %in% c("xlsx", "xls", "csv")) && missing(delim)) {
    stop("Missing argument: delim")
  }

  if (ext %in% c("xlsx", "xls") && !requireNamespace("readxl")) {
    stop("Import of Excel files requires the package `readxl`. Please install it or choose another file format.")
  }

  # read input as character columns only
  input_file <- switch(ext,
    csv = {
      readr::read_csv(
        path,
        col_types = readr::cols(.default = readr::col_character()),
        na = na,
        name_repair = "unique_quiet"
      )
    },
    xlsx = {
      readxl::read_xlsx(
        path,
        col_types = "text",
        na = na
      )
    },
    xls = {
      readxl::read_xls(
        path,
        col_types = "character",
        na = na
      )
    },
    readr::read_delim(
      path,
      delim = delim,
      col_types = readr::cols(.default = readr::col_character()),
      na = na,
      name_repair = "unique_quiet"
    )
  ) %>%
    # remove columns without a header
    dplyr::select(!tidyselect::starts_with("..."))
  # transform to desired data type
  as_archchem(
    input_file,
    id_column = id_column, context = context,
    bdl = bdl, bdl_strategy = bdl_strategy,
    guess_context_type = guess_context_type, na = na
  )
}

#' @param x an object of class archchem
#' @rdname archchem
#' @export
format.archchem <- function(x, ...) {
  out_str <- list()
  # compile information
  out_str$title <- "\033[1marchchem table\033[22m"
  # merge information
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

#' @rdname archchem
#' @export
print.archchem <- function(x, ...) {
  # own format function
  cat(format(x, ...), "\n")
  # add table printed like a tibble
  x %>%
    `class<-`(c("tbl", "tbl_df", "data.frame")) %>%
    print()
}

#' @rdname archchem
#' @export
remove_units <- function(x, ...) {
  UseMethod("remove_units")
}

#' @export
remove_units.default <- function(x, ...) {
  stop("x is not an object of class archchem")
}

#' @export
remove_units.archchem <- function(x, ...) {
  without_units <- dplyr::mutate(
    x,
    dplyr::across(
      tidyselect::where(function(x) {
        class(x) == "units"
      }),
      units::drop_units
    )
  )
  tibble::as_tibble(without_units)
}
