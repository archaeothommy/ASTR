suppressWarnings(
  df_raw <- read_ASTR(
    system.file("extdata", "test_data_input_good.csv", package = "ASTR"),
    id_column = "Sample",
    context = 1,
    drop_columns = TRUE
  ) %>%
    dplyr::mutate(
      `204Pb/206Pb` = 1 / `206Pb/204Pb`,
      `204Pb/206Pb_err2SD` = `206Pb/204Pb_err2SD` / (`206Pb/204Pb`^2)
    )
)

ref_raw <- ArgentinaDatabase %>%
  dplyr::rename(ID = `Sample number`) %>%
  dplyr::mutate(
    `206Pb/204Pb_err2SD` = `206Pb/204Pb` * (0.10 / 100),
    `207Pb/204Pb_err2SD` = `207Pb/204Pb` * (0.14 / 100),
    `208Pb/204Pb_err2SD` = `208Pb/204Pb` * (0.20 / 100),
    `204Pb/206Pb` = 1 / `206Pb/204Pb`,
    `204Pb/206Pb_err2SD` = `206Pb/204Pb_err2SD` / (`206Pb/204Pb`^2),
    `207Pb/206Pb_err2SD` = `207Pb/206Pb` * (0.13 / 100),
    `208Pb/206Pb_err2SD` = `208Pb/206Pb` * (0.20 / 100)
  )

test_that("amalia algorithm works correctly", {
  # These calls are spiked with erroneous inputs of the tripled that is not used to make sure that these remain ignored
  result_204 <- amalia(
    df = df_raw, ref = ref_raw, id_sample = "Sample",
    id_ref = "ID", triplet = "204Pb", ratios_206 = "Test"
  )
  result_206 <- amalia(
    df = df_raw, ref = ref_raw, id_sample = "Sample",
    id_ref = "ID", triplet = "206Pb", error_204 = "Test"
  )

  result_both <- amalia(
    df = df_raw, ref = ref_raw, id_sample = "Sample",
    id_ref = "ID", triplet = "both"
  )

  expect_type(result_204, "list")
  expect_named(result_204, c("summary_matches", "matches", "unmatched"))
  expect_s3_class(result_204$summary_matches, "data.frame")
  expect_s3_class(result_204$matches, "data.frame")
  expect_type(result_204$unmatched, "character")


  expect_named(result_204$summary_matches, c("sample_id", "n_matches"))
  expect_named(result_204$matches, c("sample_id", "ref_id"))
  expect_equal(nrow(result_204$summary_matches), nrow(df_raw))
  expect_true(all(df_raw$Sample %in% result_204$summary_matches$sample_id))

  expect_lte(nrow(result_both$matches), nrow(result_204$matches))
  expect_lte(nrow(result_both$matches), nrow(result_206$matches))

  expect_true(all(result_204$summary_matches$n_matches >= 0))
  expect_true(all(result_206$summary_matches$n_matches >= 0))
  expect_true(all(result_both$summary_matches$n_matches >= 0))

  ref_empty <- ref_raw[0, ]
  result_empty <- amalia(
    df = df_raw, ref = ref_empty, id_sample = "Sample",
    id_ref = "ID", triplet = "204Pb"
  )
  expect_equal(nrow(result_empty$matches), 0)
  expect_equal(nrow(result_empty$summary_matches), nrow(df_raw))
  expect_equal(length(result_empty$unmatched), nrow(df_raw))

  expect_message(amalia(df_raw, ref_empty, id_sample = "Sample", id_ref = "ID", triplet = "204Pb"), "without matches")
})

test_that("amalia: input validation catches bad inputs", {
  expect_error(amalia(df = list(), ref = ref_raw))

  expect_error(amalia(
    df = df_raw, ref = ref_raw, id_sample = "nonexistent",
    id_ref = "ID", triplet = "204Pb"
  ))

  expect_error(amalia(
    df = df_raw, ref = ref_raw, id_sample = "Sample",
    id_ref = "nonexistent", triplet = "204Pb"
  ))

  expect_error(amalia(
    df = df_raw, ref = ref_raw, id_sample = "Sample",
    id_ref = "ID", triplet = "wrong"
  ))

  df_bad <- df_raw[, !names(df_raw) %in% "206Pb/204Pb"]
  expect_error(amalia(df_bad, ref_raw, id_sample = "Sample", id_ref = "ID", triplet = "204Pb"))
})
