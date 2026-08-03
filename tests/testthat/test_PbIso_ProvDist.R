library(testthat)

# ==============================================================================
# Helpers & Mock Objects Setup
# ==============================================================================

make_mock_ref_data <- function(n_rows = 5) {
  df <- data.frame(
    Region = paste0("Region_", seq_len(n_rows)),
    Pb206 = c(18.1, 18.2, 18.3, 18.4, 18.5)[seq_len(n_rows)],
    Pb207 = c(15.5, 15.6, 15.7, 15.8, 15.9)[seq_len(n_rows)],
    Pb208 = c(38.1, 38.2, 38.3, 38.4, 38.5)[seq_len(n_rows)]
  )
  class(df) <- c("ref.data", "data.frame")
  return(df)
}

make_mock_endmembers_obj <- function() {
  grp1 <- matrix(c(18.1, 15.5, 38.1, 18.2, 15.6, 38.2), ncol = 3, byrow = TRUE)
  colnames(grp1) <- c("Pb206", "Pb207", "Pb208")

  grp2 <- matrix(c(18.4, 15.8, 38.4, 18.5, 15.9, 38.5), ncol = 3, byrow = TRUE)
  colnames(grp2) <- c("Pb206", "Pb207", "Pb208")

  obj <- list(
    data = NULL,
    pca_ends = NULL,
    group1 = grp1,
    group2 = grp2
  )
  class(obj) <- c("pbisoendmembers", "list")
  return(obj)
}

# ==============================================================================
# Tests for pb_iso_prov_dist
# ==============================================================================

describe("pb_iso_prov_dist() input validation", {

  it("throws error when dist_type argument is missing", {
    ref <- make_mock_ref_data()
    x <- matrix(c(18.1, 15.5, 38.1), ncol = 3)

    expect_error(
      pb_iso_prov_dist(x, ref = ref),
      "Distance type should be Defined 'ed' or 'mfd'"
    )
  })

  it("throws error when dist_type is invalid", {
    ref <- make_mock_ref_data()
    x <- matrix(c(18.1, 15.5, 38.1), ncol = 3)

    expect_error(
      pb_iso_prov_dist(x, ref = ref, dist_type = "invalid_choice"),
      "'arg' should be one of \"ed\", \"mfd\""
    )
  })

  it("throws error when ref is not of class 'ref.data'", {
    plain_df <- data.frame(Region = "A", Pb206 = 18.1, Pb207 = 15.5, Pb208 = 38.1)
    x <- matrix(c(18.1, 15.5, 38.1), ncol = 3)

    expect_error(
      pb_iso_prov_dist(x, ref = plain_df, dist_type = "ed"),
      "ref must be of class ref.data."
    )
  })
})

describe("pb_iso_prov_dist() Euclidean Distance ('ed')", {

  it("calculates euclidean distance correctly for matrix input", {
    ref <- make_mock_ref_data(n_rows = 5)
    x <- matrix(
      c(18.1, 15.5, 38.1,
        18.5, 15.9, 38.5),
      ncol = 3, byrow = TRUE
    )
    colnames(x) <- c("Pb206", "Pb207", "Pb208")

    res <- pb_iso_prov_dist(x, ref = ref, dist_type = "ed", .n = 2)

    expect_s3_class(res, "data.frame")
    expect_equal(nrow(res), 4) # 2 query points * .n = 2
    expect_true("dist" %in% names(res))
    expect_equal(min(res$dist), 0, tolerance = 1e-7)
    expect_false(is.unsorted(res$dist))
  })

  it("handles pbisoendmembers S3 input for 'ed'", {
    ref <- make_mock_ref_data()
    end_obj <- make_mock_endmembers_obj()

    res <- pb_iso_prov_dist(end_obj, ref = ref, dist_type = "ed", .n = 1)

    expect_type(res, "list")
    expect_length(res, 2)
    expect_named(res, c("group1", "group2"))
    expect_s3_class(res$group1, "data.frame")
    expect_s3_class(res$group2, "data.frame")
  })
})

describe("pb_iso_prov_dist() Mass Fractionation Distance ('mfd')", {

  it("calculates MFD distance correctly and covers basis branch 1 (abs(n[1]) < 0.9)", {
    ref <- make_mock_ref_data(n_rows = 3)
    x_normal <- matrix(c(18.2, 15.6, 38.2), ncol = 3)
    colnames(x_normal) <- c("Pb206", "Pb207", "Pb208")

    res <- pb_iso_prov_dist(x_normal, ref = ref, dist_type = "mfd", .n = 2, s = 0.001)

    expect_s3_class(res, "data.frame")
    expect_equal(nrow(res), 2)
    expect_true("dist_sq" %in% names(res))
  })

  it("covers basis branch 2 (abs(n[1]) >= 0.9)", {
    ref <- make_mock_ref_data(n_rows = 3)
    # x0 constructed so that v[1] heavily dominates: abs(n[1]) >= 0.9
    x_high_n1 <- matrix(c(100, 0.001, 0.001), ncol = 3)
    colnames(x_high_n1) <- c("Pb206", "Pb207", "Pb208")

    res <- pb_iso_prov_dist(x_high_n1, ref = ref, dist_type = "mfd", .n = 1, s = 0.001)

    expect_s3_class(res, "data.frame")
    expect_equal(nrow(res), 1)
  })

  it("handles pbisoendmembers S3 input for 'mfd'", {
    ref <- make_mock_ref_data()
    end_obj <- make_mock_endmembers_obj()

    res <- pb_iso_prov_dist(end_obj, ref = ref, dist_type = "mfd", .n = 1, s = 0.001)

    expect_type(res, "list")
    expect_length(res, 2)
    expect_named(res, c("group1", "group2"))
    expect_s3_class(res$group1, "data.frame")
    expect_s3_class(res$group2, "data.frame")
  })
})
