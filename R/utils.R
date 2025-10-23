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
filter_columns_with_id <- function(df, columns, id_column_name = "id", all = FALSE) {
  # all data is supposed to have an id column
  if (all){
    required_cols <- c(id_column_name, columns)
  } else {
    required_cols = colnames(df)
  }
  check_columns_exist(df, required_cols)

  if (length(unique(df[[id_column_name]])) != length(df[[id_column_name]])) {
    stop(paste("Column ", id_column_name, " is not unique and therefore cannot be used as id"))
  }

  df_filtered <- df[, required_cols]

  df_filtered
}

#' TODO: improve when specific  archem classes are defined
#' TODO: evaluate if worth replacing the generic R code columns[!sapply(df[columns], is.numeric)]
#' with columns <- df %>%
#'   select(all_of(columns)) %>%
#'   select(where(~ !is.numeric(.))) %>%
#'   names()
#'
#'
#' @export
check_numeric_columns <- function(df, columns) {
  non_numeric <- columns[!sapply(df[columns], is.numeric)]

  if (length(non_numeric) > 0) {
    stop(paste("These columns are not numeric:", paste(non_numeric, collapse = ", ")))
  }

  TRUE
}

#' TODO: improve when specific  archem classes are defined, atm it's just a wrapper
#' TODO: add tests when it does something meaningful
#' TODO: evaluate if worth replacing the generic R code columns[!sapply(df[columns], is.numeric)]
#' with df %>% select(where(~ !is.numeric(.))) %>% names()
#'
#'
#' function is supposed to strip any metadata that may influence the ML algorithms (PCA, k-means,...)
#' @export
return_numeric_columns <- function(df, columns, all = FALSE) {
  if (all) {
    columns <- names(df)[sapply(df, is.numeric)]
  } else {
    check_numeric_columns(df, columns)
  }
  df[columns]
}
