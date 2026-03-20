#' GeomSpider ggproto
#'
GeomSpider <- ggplot2::ggproto(
  "GeomSpider",
  ggplot2::Geom,

  required_aes = character(0),

  default_aes = ggplot2::aes(
    colour = "black",
    linewidth = 0.6,
    linetype = 1,
    alpha = NA
  ),

  extra_params = c("na.rm", "elements", "reference", "sample_id"),

  draw_key = ggplot2::draw_key_path,

  setup_data = function(data, params) {

    if (!inherits(data, "data.frame")) {
      cli::cli_abort("geom_spider: data must be a data frame")
    }

    elements <- params$elements
    # Resolve predefined element groups
    if (length(elements) == 1 && elements %in% names(element_groups)) {
      elements <- element_groups[[elements]]
    }

    # Check elements exist
    missing_elements <- setdiff(elements, names(data))
    if (length(missing_elements) > 0) {
      cli::cli_abort(c(
        "Elements not found in data: {.val {missing_elements}}",
        "i" = "Available columns: {.val {names(data)}}"
      ))
    }

    # Normalize
    norm_data <- normalise_spider(
      df = data,
      elements = elements,
      reference = params$reference
    )

    # Pivot wide -> long
    data_long <- tidyr::pivot_longer(
      norm_data,
      cols = dplyr::all_of(elements),
      names_to = "element",
      values_to = "value"
    )

    # Maintain order of elements
    data_long$element <- factor(data_long$element, levels = elements)

    # Numeric x
    data_long$x <- as.numeric(data_long$element)
    data_long$y <- data_long$value

    # Grouping
    if (!is.null(params$sample_id) && params$sample_id %in% names(data_long)) {
      data_long$group <- data_long[[params$sample_id]]
    } else {
      data_long$group <- seq_len(nrow(norm_data))
    }

    data_long
  },

  draw_group = function(data, panel_params, coord) {
    # Handle missing values by breaking lines
    if (any(is.na(data$y))) {
      not_na <- !is.na(data$y)
      rle_not_na <- rle(not_na)
      ends <- cumsum(rle_not_na$lengths)
      starts <- c(1, ends[-length(ends)] + 1)
      grobs <- list()

      for (i in seq_along(rle_not_na$lengths)) {
        if (rle_not_na$values[i]) {
          idx <- starts[i]:ends[i]
          segment <- data[idx, , drop = FALSE]
          if (nrow(segment) >= 2) {
            coords <- coord$transform(segment, panel_params)
            grobs[[length(grobs) + 1]] <- grid::polylineGrob(
              coords$x, coords$y,
              gp = grid::gpar(
                col = coords$colour[1],
                lwd = coords$linewidth[1] * .pt,
                lty = coords$linetype[1],
                alpha = coords$alpha[1]
              )
            )
          }
        }
      }

      if (length(grobs) == 0) {
        return(grid::nullGrob())
      }
      return(do.call(grid::grobTree, grobs))
    }

    # No missing values
    if (nrow(data) < 2) {
      return(grid::nullGrob())
    }

    coords <- coord$transform(data, panel_params)
    grid::polylineGrob(
      coords$x, coords$y, id = coords$group,
      gp = grid::gpar(
        col = coords$colour,
        lwd = coords$linewidth * .pt,
        lty = coords$linetype,
        alpha = coords$alpha
      )
    )
  }
)
