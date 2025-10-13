#' @name archchem
#' @rdname archchem
#'
#' @title \strong{archchem}
#'
#' @description A data format for chemical analysis datasets in archaeology
#'
#' @param x a data.frame
#' @param ... further arguments passed to or from other methods
#'
#' @export
as.archchem <- function(x, ...) {
  # input checks
  checkmate::assert_data_frame(x)
  # determine and apply column types
  modify_columns(x) |>
    # turn into tibble-derived object
    tibble::new_tibble(., nrow = nrow(.), class = "archchem")
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

modify_columns <- function(x) {
  # determine column type constructors from column names
  constructors <- colnames_to_constructor(x)
  # apply column type constructors
  purrr::map2(x, constructors, function(col, f) f(col))
}

