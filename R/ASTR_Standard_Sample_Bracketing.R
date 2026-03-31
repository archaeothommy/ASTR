

#' Standard Sample Bracketing
#'
#' @description Performs Standard Sample Bracketing (SSB) correction for isotope
#'   ratio data.
#'
#' @details This function corrects for instrumental drift or mass bias during
#'   isotopic analyses using the Standard Sample Bracketing method. The measured
#'   isotope value of each sample is corrected by the linearly interpolated mass
#'   bias drift between the two standard measurements taken immediately before
#'   and after the sample measurement.
#'
#' @param df data frame including at least a column with the analysis results
#'   from the machine and a column with the labels for the standard
#'   measurements.
#' @param id_values String with the name of the column in `df` with the numeric
#'   results. Default is ´values´.
#' @param id_col String with the name of the column in `df`with the identifiers
#'   of each row.
#' @param id_error string with the name of the column  in `df` with the errors of each measurement
#' @param std String identifying the standard used for bracketing. Default is
#'   "Std".
#' @param pos Integer giving the line of the first standard measurement that
#'   opens the first bracket.
#' @param notation String that describes the calculation the user wants to be performed:
#' * ratio calculates the ratio between the sample and the standard mean
#' * delta calculates the delta value of the sample per mille.
#' * epsilon calculates the epsilon value of the sample per ten thousand.
#' @param weight_std A vector of length 2 with numeric value giving the weight
#'   assigned to the opening and closing standard of a bracket, respectively.
#'   The sum of both weights must be one. The default `0.5` gives the mean of
#'   both standards.
#' @param sd_input integer that gives the number the standard deviation will be multiplied for.
#'
#' @param display_details boolean to indicate if the user wants to get the detailed list of each
#'  measurement with their respective error calculation
#'
#' @references Mason, T. F.D., Weiss, D. J., Horstwood, M., Parrish, R. R.,
#'   Russell, S. S., Mullaneb, E., and Colesa, B. J. (2004) High-precision Cu
#'   and Zn isotope analysis by plasma source mass spectrometry. Journal of
#'   Analytical Atomic Spectrometry 19, pp. 209-217.
#'   <https://doi.org/10.1039/B306958C>
#'
#' @returns A list object with the average values plus Standard Error (SE)
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#'   ID = c("Std", "Sample_A", "Std", "Sample_A", "Std", "Sample_A", "Std"),
#'   values = c(16.928, 18.641, 16.932, 18.643, 16.935, 18.642, 16.938)
#' )
#'
#' result <- ASTR::standard_sample_bracketing(
#'  df = data,
#'  pos = 1,
#'  notation = "delta"
#')

standard_sample_bracketing <- function(
  df,
  id_values = "Data",
  id_col = "ID",
  id_error="Error_errSE",
  std = "Std",
  pos = 1,
  notation = c("ratio", "delta", "epsilon"),
  sd_input = 1,
  weight_std = c(0.5, 0.5),
  display_details=FALSE
) {

  # Check there are no empty values in header nor id_std
  if (std == "") {
    stop("You need to assign the ID of the standard.")
  }

  if (!(id_values %in% colnames(df))) {
    stop("The column name for the measured values is not included in the provided data frame.")
  }

  notation <- match.arg(notation)

  # Check of weight values

  checkmate::assert_vector(weight_std, strict = TRUE, len = 2, any.missing = FALSE)

  if (sum(weight_std) != 1) {
    stop("The sum of the weights must be 1.")
  }

  # prepare variables
  df <- df[c(id_col, id_values, id_error)] # make a dataframe with the ID of the samples and the measurements
  nr <- nrow(df) # count number of rows in the dataframe

  sample_names <- sample_results <-error_sample_list<- c()

  # SSB calculation

  while (pos + 1 <= nr) {
    # iterates over the whole data frame, it starts with the cycles
    std_opening <- df[pos, 2]
    error_std_opening<- df[pos, 3]
    cycle_end <- cycle_start <- pos + 1 # move the index to the first sample

    while (df[cycle_end, 1] != std) { # Find the second (closing) standard bracket from the cycle
      cycle_end <- cycle_end + 1
    }

    std_closing <- df[cycle_end, 2]
    error_std_closing<- df[cycle_end, 3]

    std_mean_weighted <- (weight_std[1] * std_opening) + (weight_std[2] * std_closing) # calculate weighted mean

    while (cycle_start < cycle_end) { # run the samples within the cycle
      sample_current <- df[cycle_start, 1]
      error_measurement<- df[cycle_start, 3]

      total_error<-error_measurement*sqrt((weight_std[1] * error_std_opening)^2 + (weight_std[2] * error_std_closing)^2 )

      if (!is.na(sample_current) && sample_current != "") {
        sample_measurement <- df[cycle_start, 2]
        ssb <- sample_measurement / std_mean_weighted

        switch(
          notation,
          delta = {
            ssb <- (ssb - 1) * 1000
          },
          epsilon = {
            ssb <- (ssb - 1) * 10000
          },
          {
            ssb
          }
        )

        sample_names <- append(sample_names, sample_current)
        sample_results <- append(sample_results, ssb)
        error_sample_list<- append(error_sample_list, total_error)

      }
      cycle_start <- cycle_start + 1
    }
    pos <- cycle_start
  }

  # for some reason, they are a list rather a vector, so turning them into vector
  sample_names <- unlist(sample_names)
  sample_results <- unlist(sample_results)
  error_sample_list<- unlist(error_sample_list)

  # Combine calculated values into data frame and order them by sample name
  results <- data.frame(ID = sample_names, SSB = sample_results, Error_err2SD=error_sample_list)

  # Calculate errors and averages for each sample
  library(dplyr)
  summary<-results %>% group_by(ID) %>% summarise(
    Mean=format(signif(mean(SSB), 4), nsmall = 4),
    SD=format(signif(sd_input*sd(SSB), 4), nsmall=4)
  )
  colnames(results)[2] <- paste0(notation)
  colnames(summary)[2] <- paste0(notation)
  if(sd_input!=1)
    colnames(summary)[3] <- paste0("Error_err",sd_input, "SD")
  else
    colnames(summary)[3] <- paste0("Error_errSD")

  if (display_details==TRUE)
    result <- list(results, summary)
  else
    result<- summary
  result

}
