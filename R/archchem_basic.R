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
#' @param drop_columns ...
#'
#' @return Returns a data structure `archchem`  which is a tibble derived-object
#'
#' The function prints a short summary about the dataset, including a list of
#' all context columns and analytical data columns.
#'
#' @details The data files can be fairly freeform, i.e. no specified elements,
#' oxides, or isotopic ratios are required and no exact order of these needs to
#' be adhered to. Analyses can contain as many analytical columns as necessary.
#'
#' The column that contains the unique samples identification is specified using
#' the `ID` argument. If the dataset contains duplicate ids, the following warning
#' will return:
#' Detected multiple data rows with the same ‘ID’. They will be renamed
#' consecutively using the following convention: `_1`,`_2`, ... `_n`
#'
#' Metadata contained within the dataset must be specified using the `context`
#' argument. If any column in the dataframe is not specified as context and not
#' recognised as an analytical column, this will result in the error:
#' Column name <colname> could not be parsed. Either analytical columns do not
#' conform to ASTR conventions or contextual columns are not specified as such.
#'
#' Below detection limit notation (i.e. ‘b.d.’, ‘bd’, ‘b.d.l.’, ‘bdl’, ‘<LOD’,
#' or ‘<..’) for element and oxide concentrations is specified using the `bdl`
#' argument. One or more notations can be used as is appropriate for the dataset,
#' and can be notations not included in the list above. The argument
#' `bdl_strategy` is used to specify the value for handling detection limits.
#' This is to facilitate the different handling needs of the detection limit for
#' future statistical applications, as opposed to automatically assigning such
#' values as ‘NA’.
#'
#' Missing values (NA) are allowed anywhere in the data file body, and those
#' found in an analytical data column will be replaced by `NA` automatically.
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
  drop_columns = FALSE,
  ...
) {
  # input checks
  checkmate::assert_data_frame(df)
  checkmate::assert_names(colnames(df), must.include = id_column)
  # prepare context column list
  if (!inherits(context, "character")) {
    context <- colnames(df)[context]
  }
  context <- append(context, id_column)
  # add ID column to context for the following operation
  df <- df %>%
    dplyr::mutate(ID = .data[[id_column]]) %>%
    dplyr::relocate("ID", .before = 1)
  # handle ID duplicates
  if (length(unique(df$ID)) != nrow(df)) {
    warning("Detected multiple data rows with the same ID. They will be renamed ",
            "consecutively using the following convention: _1, _2, ... _n")
  }
  df <- df %>%
    dplyr::group_by(.data[["ID"]]) %>%
    dplyr::mutate(
      ID = dplyr::case_when(
        dplyr::n() > 1 ~ paste0(.data[["ID"]], "_", as.character(dplyr::row_number())),
        .default = .data[["ID"]]
      )
    ) %>%
    dplyr::ungroup()
  # determine and apply column types
  constructors <- colnames_to_constructors(
    df, context, bdl, bdl_strategy, guess_context_type, na, drop_columns
  )
  df <- purrr::map2(df, constructors, function(col, f) f(col)) %>%
    purrr::discard(is.null)
  # turn into tibble-derived object
  df <- tibble::new_tibble(df, nrow = nrow(df), class = "archchem")
  return(df)
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
  },
  drop_columns = FALSE
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
    guess_context_type = guess_context_type, na = na,
    drop_columns = drop_columns
  )
}

#' @param x an object of class archchem
#' @rdname archchem
#' @export
format.archchem <- function(x, ...) {
  out_str <- list()
  # compile information
  out_str$title <- "\033[1marchchem table\033[22m"
  # analytical columns
  x_analytical <- colnames(get_analytical_columns(x))
  out_str$analytical_columns <- paste(
    "Analytical columns:",
    add_color(paste(x_analytical[-1], collapse = ", "), 32)
  )
  # contextual columns
  x_context <- colnames(get_contextual_columns(x))
  out_str$contextual_columns <- paste(
    "Contextual columns:",
    add_color(paste(x_context[-1], collapse = ", "), 35)
  )
  # merge information
  return_value <- paste(out_str, collapse = "\n", sep = "")
  invisible(return_value)
}

# see colours: for(col in 29:47){ cat(paste0("\033[0;", col, "m", "test" ,"\033[0m","\n"))}
add_color <- function(x, col) {
  paste0("\033[0;", col, "m", x, "\033[0m")
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
