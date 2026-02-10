

# here is the function to do SSB using the tidyverse
standard_sample_bracketing <- function(
    data = data,
    sample_id = "ID",
    values = "value",
    standard_name = "Std",
    multiplier = 1000,
    start_at_row = 1
) {

  library(dplyr)

  # start where the user says the data starts
  data <-
  data |>
    slice(start_at_row:n()) |>
    # we need a unique row number to rejoin the data later
    mutate(original_row_id = row_number())

  sample_id_sym <- sym(sample_id)  # turn string into symbol
  values_sym    <- sym(values)  # turn string into symbol

  # Find positions of all standard rows
  std_rows <- which(data[[sample_id_sym]] == standard_name)

  # build overlapping Std–Sample–Std groups, we duplicate
  # some stds to have distinct groups that we can process
  groups <- map2(
    std_rows[-length(std_rows)],
    std_rows[-1],
    .f = function(start, end) {
      idx <- which(std_rows[-length(std_rows)] == start)
      data[start:end, ] |>
        mutate(group_id =  paste0("group_", sprintf("%03d", idx)))
    }
  )

  df_grouped <- bind_rows(groups)

  # for eachStd–Sample–Std group,  take the first std and the last std
  # and compute mean and add in a new column containing this mean
  # for each group
  df_grouped_with_means <-
  df_grouped |>
    group_by(group_id) %>%
    # keep only Std rows
    filter({{sample_id_sym}} == standard_name) %>%
    # take only first and last Std in each group
    slice(c(1, n())) %>%
    summarise(
      mean_std = mean({{values_sym}}, na.rm = TRUE),
      .groups = "drop"
    )  |>
  right_join(df_grouped)

  # for each group, take the sample value, divide by the mean std
  # value -1, then multiple by the multiplier
  df_grouped_with_means_ssb <-
  df_grouped_with_means |>
    # Exclude the standards from the final calculation
    filter({{sample_id_sym}} != standard_name) |>
    mutate(
      # output is per mil
      ssb_value = ({{values_sym}} / mean_std - 1) * multiplier
    ) |>
    # Select only the ID and the result to avoid duplicate columns
    select(original_row_id, ssb_value)

  # Join the calculated values back to the original data frame
  final_data <- data |>
    left_join(df_grouped_with_means_ssb,
              by = "original_row_id") |>
    # Remove the temporary ID column
    select(-original_row_id)

  return(final_data)

}

# Test the function with some data -------------------------------------------

library(readxl)
library(tidyverse)

# import the data
df <- read_excel("data-raw/ULB_Cu_20190903-test 2.xlsx",
                 sheet = "03092019",
                 skip = 2)

# subset just the sequences of samples to apply SSB
subset_to_bracket <-
  df |>
  slice(13:45, 68:104)

# apply the function to create a new data frame with the new column
x <-
standard_sample_bracketing(data = subset_to_bracket,
                           sample_id = "Sample Name...1",
                           standard_name = "Cu/Zn in house 25ppb",
                           values = "Cu65/63 corr 68/66")
x

# take a look and compare the function result to the Excel result
x |>
  select(`Sample Name...1`,
         `Cu65/63 corr 68/66`,
         `δ65Cu`,
         ssb_value) |>
  mutate(all_equal = all.equal(`δ65Cu`,ssb_value )) |> View()



