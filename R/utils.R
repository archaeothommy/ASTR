#' @export
check_columns_exist <- function(df, columns) {
  #
  checkmate::assert_data_frame(df)

  missing_cols <- setdiff(columns, colnames(df))

  if (length(missing_cols) > 0) {
    stop(paste("Columns missing in dataset:", paste(missing_cols, collapse = ", ")))
  }

  TRUE
}


#' @export
filter_columns_with_id <- function(df, columns, id_column = "id") {
  #all data is supposed to have an id column
  required_cols <- c(id_column, columns)

  check_columns_exist(df, required_cols)

  if (length(unique(df[[id_column]])) != length(df[[id_column]])) {
    stop(paste("Column ", id_column, " is not unique and therefore cannot be used as id"))
  }

  df_filtered <- df[, required_cols]

  df_filtered
}

check_numeric_columns <- function(df, columns) {
  non_numeric <- columns[!sapply(df[columns], is.numeric)]

  if (length(non_numeric) > 0) {
    stop(paste("These columns are not numeric:", paste(non_numeric, collapse = ", ")))
  }

  TRUE
}
