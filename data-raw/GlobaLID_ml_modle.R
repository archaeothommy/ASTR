# see R/data.R for the documentation of these datasets

# Retrive and process GlobaLID dataset.
GlobaLID <- readr::read_csv(
  "https://raw.githubusercontent.com/archmetalDBM/GlobaLID-database/refs/heads/main/GlobaLID.csv"
) %>%
  select("Political province/region",
         "206Pb/204Pb",
         "207Pb/204Pb",
         "208Pb/204Pb")

GlobaLID_ASTR <- as_ASTR(GlobaLID, id_column = "Political province/region", drop_columns = TRUE)

# Train machine learing model
ml_model <- pb_iso_train_data(GlobaLID_ASTR, "Political province/region")

usethis::use_data(
  GlobaLID_ASTR,
  ml_model
  overwrite = TRUE,
  internal = FALSE
)
