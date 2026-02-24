#' @name archchem
#' @rdname archchem
#'
#' @title \strong{archchem}
#'
#' @description A tabular data format for chemical analysis datasets in
#' archaeology, including contextual information, numerical elemental, and
#' isotopic data. Columns are assigned units (using \link[units]{set_units}) and
#' categories (in an attribute `archchem_class`) based on the column name.
#' The following functions allow to create objects of class `archchem`, and to
#' interact with them.
#' \itemize{
#'   \item **as_archchem**: Transforms an R `data.frame` to an object of class
#'   `archchem`.
#'   \item **read_archchem**: Reads data from a file (.csv, .xls, .xlsx) into
#'   an object of class `archchem`.
#'   \item **validate**: Performs additional validation on `archchem` and returns
#'   a `data.frame` as a workable list of potential issues.
#'   \item **get_..._columns**: Subsets `archchem` tables to columns of a certain
#'   category (or `archchem_class`), e.g. only contextual data columns.
#'   \item **remove_units**: Removes unit vector types from the analytical columns
#'   in an `archchem` table and replaces them with simple numeric columns of type
#'   `double`.
#'   \item **unify_concentration_unit**: Unifies the unit of each concentration column,
#'   e.g. to either % or ppm (or any SI unit) to avoid mixing units in derived analyses.
#' }
#' As `archchem` is derived from `tibble` it is directly compatible with the
#' data manipulation tools in the tidyverse.
#'
#' @param df a data.frame containing the input table
#' @param path file path (including extension) to the file to read
#' @param ... further arguments passed to or from other methods
#' @param id_column name of the ID column. Defaults to "ID"
#' @param context columns that provide contextual (non-measurement) information;
#' may be column names, integer positions, or a logical inclusion vector
#' @param bdl strings representing “below detection limit” values. By default,
#' the following are recognized: "b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"
#' @param bdl_strategy function used to replace BDL strings. Defaults to a static
#' function returning NA
#' @param guess_context_type should appropriate data types for contextual columns
#' be guessed automatically? Defaults to TRUE
#' @param na character vector of strings to be interpret as missing values.
#' By default, the following are recognized: "", "n/a", "NA", "N.A.", "N/A", "na",
#' "-", "n.d.", "n.a.", "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A",
#' "#NULL!"
#' @param drop_columns should columns that are neither marked as contextual in
#' `context`, nor automatically identified as analytical from the column name,
#' be dropped to proceed with the reading? Defaults to FALSE
#' @param validate should the post-reading input validation be run, which checks
#' for additional properties of archchem tables. Defaults to TRUE
#'
#' @return Returns an object of class `archchem`, which is a tibble-derived object.
#'
#' @details The input data files can be fairly freeform, i.e. no specified elements,
#' oxides, or isotopic ratios are required and no exact order of these needs to
#' be adhered to. Analyses can contain as many analytical columns as necessary.
#'
#' The column that contains the unique samples identifier must be specified using
#' the `ID` argument. If the dataset contains duplicate ids they will be renamed
#' consecutively using the following convention: `_1`,`_2`, ... `_n`.
#'
#' Metadata contained within the dataset must be marked using the `context`
#' argument. If any column in the dataframe is not specified as context and not
#' recognised as an analytical column, this will result in an error.
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
#' Missing values are allowed anywhere in the data file body, and will be replaced
#' by `NA` automatically.
#'
#' @examples
#' library(magrittr)
#'
#' # reading an archchem table directly from a file
#' test_file <- system.file("extdata", "test_data_input_good.csv", package = "ASTR")
#' arch <- read_archchem(test_file, id_column = "Sample", context = 1:7)
#'
#' # turning a data.frame to an archchem table
#' test_df <- readr::read_csv(test_file)
#' arch <- as_archchem(test_df, id_column = "Sample", context = 1:7)
#'
#' # validating an archchem table
#' validate(arch)
#'
#' # extracting subsets of columns
#' conc <- get_concentration_columns(arch) # see also other get_..._columns functions
#'
#' # unit-aware arithmetics on archchem columns thanks to the units package
#' conc$Sb + conc$Ag # works
#' \dontrun{conc$Sb + conc$Sn} # fails with: cannot convert µg/ml into ppm
#'
#' # converting units
#' conc$Sb <- units::set_units(arch$Sb, "ppb") %>%
#'   magrittr::set_attr("archchem_class", "archchem_concentration")
#'
#' # removing all units from archchem tables
#' remove_units(arch)
#'
#' # applying tidyverse data manipulation on archchem tables
#' arch %>%
#'   dplyr::group_by(Site) %>%
#'   dplyr::summarise(mean_Na2O = mean(Na2O))
#' conc_subset <- conc %>%
#'   dplyr::select(-Sn, -Sb) %>%
#'   dplyr::filter(Na2O > units::set_units(4, "wtP"))
#'
#' # unify all concentration units
#' unify_concentration_unit(conc_subset, "ppb")
#'
#' @export
as_archchem <- function(
  df, id_column = "ID", context = c(),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() NA_character_,
  # this only allows static functions, essentially: bdl_replace = "NA"
  # in case more sophisticated handling is desired:
  # bdl_strategy = function(x, colname) { bdl_lookup_table[colname] / sqrt(2) }
  # bdl_lookup_table = c("Fe_%" = 3)
  guess_context_type = TRUE,
  na = c(
    "", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.",
    "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"
  ),
  drop_columns = FALSE,
  validate = TRUE,
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
  df1 <- df %>%
    dplyr::mutate(ID = .data[[id_column]]) %>%
    dplyr::relocate("ID", .before = 1)
  # handle ID duplicates
  if (length(unique(df1$ID)) != nrow(df1)) {
    warning(
      "Detected multiple data rows with the same ID. They will be renamed ",
      "consecutively using the following convention: _1, _2, ... _n"
    )
  }
  df2 <- df1 %>%
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
    df2, context, bdl, bdl_strategy, guess_context_type, na, drop_columns
  )
  col_list <- purrr::map2(df2, constructors, function(col, f) f(col)) %>%
    purrr::discard(is.null)
  df3 <- as.data.frame(col_list, check.names = FALSE)
  # remove unit names from columns if they got a unit
  df4 <- remove_unit_substrings(df3)
  # turn into tibble-derived object
  df5 <- tibble::new_tibble(df4, nrow = nrow(df4), class = "archchem")
  # post-reading validation
  if (validate) {
    validation_output <- validate(df5, quiet = FALSE)
    if (nrow(validation_output) > 0) {
      warning(
        "See the full list of validation output with: ",
        "ASTR::validate(<your archchem object>)."
      )
    }
  }
  return(df5)
}

# helper function to rename column names
remove_unit_substrings <- function(x, ...) {
  dplyr::rename_with(
    x,
    remove_unit_substring,
    tidyselect::where(function(y) {
      class(y) == "units" && !is_archchem_class(y, "archchem_error")
    })
  )
}

remove_unit_substring <- function(colname) {
  sub("_.*$", "", colname, perl = TRUE)
}

#' @param path path to the file that should be read
#' @param delim A character string with the separator for tabular data. Must be
#'   provided for all file types except `.xlsx` or `.xls`. Default to `,`. Use
#'   `\t` for tab-separated data.
#' @param ... Additional arguments passed to the respective import functions.
#'   See their documentation for details:
#'   * [readxl::read_excel()] for file formats `.xlsx` or `.xls`
#'   * [readr::read_delim()] for all other file formats.
#' @rdname archchem
#' @export
read_archchem <- function(
  path, id_column = "ID", context = c(),
  delim = ",",
  guess_context_type = TRUE,
  na = c(
    "", "n/a", "NA", "N.A.", "N/A", "na", "-", "n.d.", "n.a.",
    "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A", "#NULL!"
  ),
  bdl = c("b.d.", "bd", "b.d.l.", "bdl", "<LOD", "<"),
  bdl_strategy = function() NA_character_,
  drop_columns = FALSE,
  validate = TRUE,
  ...
) {
  ext <- strsplit(basename(path), split = "\\.")[[1]][-1] # extract file format

  # missing throws error despite delim having a (default) value
  #if (!(ext %in% c("xlsx", "xls")) && missing(delim)) {
  #  stop("Missing argument: delim")
  #}

  if (ext %in% c("xlsx", "xls") && !requireNamespace("readxl")) {

    if (!rlang::is_interactive()) {
      stop("Import of Excel files requires the package `readxl`. Please install it or choose another file format.")
    }

    answer <- readline("Package `readxl` required to import Excel files. Do you want to install it now? [Y/n]: ")

    if (tolower(answer) %in% c("yes", "y")) {
      utils::install.packages("readxl")
    } else {
      stop("Please import your data in another file format or install 'readxl' manually.")
    }
  }

  # read input as character columns only
  input_file <- switch(ext,
    xlsx = {
      readxl::read_xlsx(
        path,
        col_types = "text",
        na = na,
        ...
      )
    },
    xls = {
      readxl::read_xls(
        path,
        col_types = "text",
        na = na,
        ...
      )
    },
    readr::read_delim(
      path,
      delim = delim,
      col_types = readr::cols(.default = readr::col_character()),
      na = na,
      name_repair = "unique_quiet",
      trim_ws = TRUE,
      ...
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
    drop_columns = drop_columns,
    validate = validate
  )
}

#' @rdname archchem
#' @param quiet should warnings be printed? Defaults to TRUE
#' @export
validate <- function(x, quiet = TRUE, ...) {
  UseMethod("validate")
}

#' @export
validate.default <- function(x, quiet = TRUE, ...) {
  stop("x is not an object of class archchem")
}

#' @export
validate.archchem <- function(x, quiet = TRUE, ...) {
  # check for missingness in analytical columns
  df_analytical <- get_analytical_columns(x)[-1]
  missing_values <- purrr::map2_dfr(
    df_analytical, colnames(df_analytical),
    function(x, col) {
      n_na <- sum(is.na(x))
      if (n_na > 0) {
        tibble::tibble(
          column = col,
          count = n_na,
          warning = "missing values"
        )
      }
    }
  )
  if (!quiet && nrow(missing_values) > 0) {
    warning(
      sum(missing_values$count),
      " missing values across ",
      nrow(missing_values),
      " analytical columns"
    )
  }
  all_warnings <- dplyr::bind_rows(missing_values)
  return(all_warnings)
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
  if (length(x_analytical[-1]) > 0) {
    out_str$analytical_columns <- paste(
      "Analytical columns:",
      paste(add_color(x_analytical[-1], 32), collapse = ", ")
    )
  }
  # contextual columns
  x_context <- colnames(get_contextual_columns(x))
  if (length(x_context[-1]) > 0) {
    out_str$contextual_columns <- paste(
      "Contextual columns:",
      paste(add_color(x_context[-1], 35), collapse = ", ")
    )
  }
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

#### adjustments to preserve archchem properties with different dplyr verbs ####
# see ?dplyr_extending

# carry over archchem_class column attribute
preserve_archchem_attrs <- function(modified, original) {
  for (nm in intersect(names(modified), names(original))) {
    arch_attr <- attr(original[[nm]], "archchem_class")
    if (!is.null(arch_attr)) {
      attr(modified[[nm]], "archchem_class") <- arch_attr
    }
  }
  tibble::new_tibble(modified, class = class(original))
}

# row-slice method
#' @exportS3Method dplyr::dplyr_row_slice
dplyr_row_slice.archchem <- function(data, i, ...) {
  sliced <- purrr::map(data, vctrs::vec_slice, i = i)
  sliced_tbl <- tibble::new_tibble(sliced, class = class(data))
  preserve_archchem_attrs(sliced_tbl, data)
}

# column modification method
#' @exportS3Method dplyr::dplyr_col_modify
dplyr_col_modify.archchem <- function(data, cols) {
  modified_list <- utils::modifyList(as.list(data), cols)
  modified_tbl <- tibble::new_tibble(modified_list, class = class(data))
  preserve_archchem_attrs(modified_tbl, data)
}


# final reconstruction
#' @exportS3Method dplyr::dplyr_reconstruct
dplyr_reconstruct.archchem <- function(data, template) {
  preserve_archchem_attrs(data, template)
}
