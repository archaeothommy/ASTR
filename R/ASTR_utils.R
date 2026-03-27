check_columns_exist <- function(df, columns) {
  #
  checkmate::assert_data_frame(df)

  missing_cols <- setdiff(columns, colnames(df))

  if (length(missing_cols) > 0) {
    stop(paste("Columns missing in dataset:", paste(missing_cols, collapse = ", ")))
  }

  TRUE
}


filter_columns_with_id <- function(df, columns, id_column = "id") {
  # all data is supposed to have an id column
  required_cols <- c(id_column, columns)

  check_columns_exist(df, required_cols)

  if (length(unique(df[[id_column]])) != length(df[[id_column]])) {
    stop(paste("Column ", id_column, " is not unique and therefore cannot be used as id"))
  }

  df_filtered <- df[, required_cols]

  df_filtered
}

# TODO: improve when specific  archem classes are defined
# TODO: evaluate if worth replacing the generic R code columns[!sapply(df[columns], is.numeric)]
# with columns <- df %>%
#   select(all_of(columns)) %>%
#   select(where(~ !is.numeric(.))) %>%
#   names()

check_numeric_columns <- function(df, columns) {
  non_numeric <- columns[!sapply(df[columns], is.numeric)]

  if (length(non_numeric) > 0) {
    stop(paste("These columns are not numeric:", paste(non_numeric, collapse = ", ")))
  }

  TRUE
}

# TODO: improve when specific  archem classes are defined, atm it's just a wrapper
# TODO: add tests when it does something meaningful
# TODO: evaluate if worth replacing the generic R code columns[!sapply(df[columns], is.numeric)]
# with df %>% select(where(~ !is.numeric(.))) %>% names()
#
#
# function is supposed to strip any metadata that may influence the ML algorithms (PCA, k-means,...)

return_numeric_columns <- function(df, columns, all = FALSE) {
  if (all) {
    columns <- names(df)[sapply(df, is.numeric)]
  } else {
    check_numeric_columns(df, columns)
  }
  df[columns]
}

#' Transform unit in ratio notation into notation with negative exponents
#'
#' This is necessary to align with output of units from [units::deparse_unit()].
#' Example: m/s2 -> m s-2
#'
#' @param unit Character string
#' @keywords internal
#'
transform_notation <- function(unit) {
  checkmate::assert_character(unit, len = 1)

  unit <- unlist(strsplit(unit, "/"))
  if (length(unit) == 2) {
    unit[3] <- sub("[[:alpha:]]*", "", unit[2])
    if (unit[3] == "") {
      unit[3] <- "1"
    }
    unit[2] <- sub("[[:digit:]]*$", "", unit[2])
    unit[2] <- paste0(unit[2:3], collapse = "-")
    unit <- paste0(unit[1:2], collapse = " ")
  }
  if (length(unit) > 2) {
    stop("This unit cannot be converted into a format with negative exponents. Please provide it in the proper format.")
  }
  unit
}
