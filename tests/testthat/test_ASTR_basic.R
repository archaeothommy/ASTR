# golden tests

test_df <- readr::read_csv(system.file("extdata", "input_format.csv", package = "ASTR"))

test_astr <- read_ASTR(
  system.file("extdata", "input_format.csv", package = "ASTR"),
  id_column = "other",
  context = c("other", "other2")
)

test_astr_xlsx <- read_ASTR(
  system.file("extdata", "input_format.xlsx", package = "ASTR"),
  id_column = "other",
  context = c("other", "other2")
)

test_astr2 <- suppressWarnings(
  read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = c("Lab no.", "Site", "latitude", "longitude", "Type", "method_comp")
  )
)

test_df2 <- test_df
# this is to test the automatic enumeration of IDs
test_df2[2, ] <- test_df2[1, ]
test_astr3 <- suppressWarnings(
  as_ASTR(test_df2, id_column = "other2", context = "other")
)

test_that("reading of a basic example table works as expected", {
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_astr)
  })
  expect_equal(test_astr_xlsx, test_astr)
  expect_snapshot({
    # turn to data.frame to render the entire table
    as.data.frame(test_astr2)
  })
  expect_snapshot({
    print(test_astr)
  })
  # checks that automatic renaming of ID values works
  expect_all_equal(test_astr3$ID[2], "27_2")
})

# parsing throws expected errors

test_that("archem functions result in expected errors and warnings", {
  expect_error(
    suppressWarnings(as_ASTR(test_df2, id_column = "other")),
    "Column name .* could not be parsed"
  )
  expect_warning(
    as_ASTR(test_df2, id_column = "other", context = "other2"),
    "Detected multiple data rows with the same ID"
  )
  expect_error(
    validate(2),
    "x is not an object of class ASTR"
  )
})

# bdl strategies

test_that("bdl_strategies can be used and work as expected", {
  # default strategy
  expect_true({
    test_df$`206Pb/204Pb` <- "bdl"
    astr <- as_ASTR(
      test_df, id_column = "other2", context = "other",
      bdl_strategy = bdl_strategy_default,
      validate = FALSE
    ) %>% suppressWarnings()
    is.na(astr$`206Pb/204Pb`)
  })
  # negative strategy
  expect_true({
    test_df$`204Pb_ppm` <- -5
    astr <- as_ASTR(
      test_df, id_column = "other2", context = "other",
      bdl_strategy = bdl_strategy_negative,
      validate = FALSE
    ) %>% suppressWarnings()
    is.na(astr$`204Pb`)
  })
  # custom strategy
  expect_true({
    test_df$`204Pb_ppm` <- "BDL"
    test_df$`Zn_ppm` <- "BDL"
    astr <- as_ASTR(
      test_df, id_column = "other2", context = "other",
      bdl_strategy = function(x, colname, ...) {
        if (colname %in% c("204Pb_ppm")) {
          bdl_indices <- which(grepl("BDL", x, perl = FALSE))
          x[bdl_indices] <- 0
          return(x)
        } else {
          return(x)
        }
      },
      validate = FALSE
    ) %>% suppressWarnings()
    # 204Pb_ppm gets set to 0
    astr$`204Pb` == units::set_units(0, "ppm") &&
      # Zn_ppm stays BDL and ends as NA in a character column
      is.na(astr$Zn)
  })
})
