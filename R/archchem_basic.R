#' @name archchem
#' @rdname archchem
#'
#' @title \strong{archchem}
#'
#' @description A data format for chemical analysis datasets in archaeology
#'
#' @param df a data.frame
#' @param ... further arguments passed to or from other methods
#'
#' @export
as.archchem <- function(df, ...) {
  # input checks
  checkmate::assert_data_frame(df)
  # determine and apply column types
  modify_columns(df) %>%
    # turn into tibble-derived object
    tibble::new_tibble(., nrow = nrow(.), class = "archchem")
}

modify_columns <- function(x) {
  # determine column type constructors from column names
  constructors <- colnames_to_constructor(x)
  # apply column type constructors
  purrr::map2(x, constructors, function(col, f) f(col))
}

#' @param path path to the file that should be read
#' @rdname archchem
#' @export
read_archchem <- function(path) {
  # read input as character columns only
  input_file <- readr::read_csv(
    path,
    col_types = readr::cols(.default = readr::col_character()),
    na = c("", "n/a", "NA"),
    name_repair = "unique_quiet"
  ) |>
    # remove columns without a header
    dplyr::select(!tidyselect::starts_with("..."))
  # transform to desired data type
  as.archchem(input_file)
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
  x %>% `class<-`(c("tbl", "tbl_df", "data.frame")) %>% print
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
        tidyselect::where(\(x) {
          class(x) == "units"
        }),
        units::drop_units
      )
    )
   tibble::as_tibble(without_units)
}
