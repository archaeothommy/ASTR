#' @export
check_columns_exist <- function(data, columns) {
  #
  if (!is.data.frame(data)) {
    stop("Data needs to be a tibble or data frame!")
  }

  missing_cols <- setdiff(columns, colnames(data))

  if (length(missing_cols) > 0) {
    stop(paste("Columns missing in dataset:", paste(missing_cols, collapse = ", ")))
  }

  TRUE
}


#' @export
filter_columns_with_id <- function(data, columns) {
  #all data is supposed to have an id column
  required_cols <- c("id", columns)

  check_columns_exist(data, required_cols)

  data_filtered <- data[, required_cols]

  data_filtered
}
