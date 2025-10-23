# Sample tibble for tests
df <- tibble::tibble(
  id = 1:2,
  name = c("Alice", "Bob"),
  age = c(30, 25),
  city = c("Rome", "Milan"),
  nationality = c("Italy", "Italy"),
  score = c(90.5, 80.2)
)

#' --------------check_columns_exist--------------------------------------------
test_that("check_columns_exist returns TRUE when all columns exist", {
  expect_true(check_columns_exist(df, c("name", "age")))
})

test_that("check_columns_exist throws error when columns are missing", {
  expect_error(
    check_columns_exist(df, c("name", "email")),
    regexp = "Columns missing in dataset: email"
  )
})

test_that("check_columns_exist throws error on non-dataframe input", {
  expect_error(
    check_columns_exist("not_a_dataframe", c("name")),
    regexp = "Assertion on *"
  )
})

#' --------------filter_columns_with_id--------------------------------------------
test_that("filter_columns_with_id returns correct columns in correct order", {
  result <- filter_columns_with_id(df, c("name", "city"))
  expect_named(result, c("id", "name", "city"))
  expect_equal(nrow(result), 2)
})

test_that("filter_columns_with_id throws error if required column is missing", {
  expect_error(
    filter_columns_with_id(df, c("name", "email")),
    regexp = "Columns missing in dataset: email"
  )
})

test_that("filter_columns_with_id throws error if 'id' is missing", {
  df_no_id <- tibble::tibble(
    name = c("Alice", "Bob"),
    age = c(30, 25)
  )
  expect_error(
    filter_columns_with_id(df_no_id, c("name")),
    regexp = "Columns missing in dataset: id"
  )
})

test_that("filter_columns_with_id throws error if custom id column is missing", {
  expect_error(
    filter_columns_with_id(df, c("city", "age"), "non_existing_col"),
    regexp = "Columns missing in dataset: non_existing_col"
  )
})

test_that("filter_columns_with_id throws error if id column is not unique", {
  expect_error(
    filter_columns_with_id(df, c("city", "age"), "nationality"),
    regexp = "Column  nationality  is not unique and therefore cannot be used as id"
  )
})

#' --------------check_numeric_columns--------------------------------------------
test_that("check_numeric_columns() passes when all columns are numeric", {
  expect_true(check_numeric_columns(df, c("age", "score")))
})

test_that("check_numeric_columns() fails when a column is not numeric", {
  expect_error(
    check_numeric_columns(df, c("age", "name")),
    regexp = "not numeric"
  )
})


#' --------------return_numeric_columns--------------------------------------------
test_that("return_numeric_columns() returns only selected numeric columns", {
  result <- return_numeric_columns(df, columns = c("id", "score"))
  expect_equal(names(result), c("id", "score"))
  expect_true(all(sapply(result, is.numeric)))
})

test_that("return_numeric_columns(all = TRUE) returns all numeric columns", {
  result <- return_numeric_columns(df, columns = c("anything"), all = TRUE)
  expect_equal(names(result), c("id", "age", "score"))
  expect_true(all(sapply(result, is.numeric)))
})

test_that("return_numeric_columns() throws error for non-numeric columns", {
  expect_error(
    return_numeric_columns(df, columns = c("name", "city")),
    "These columns are not numeric: name, city"
  )
})
