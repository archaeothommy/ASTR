

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
#' @param values String with the name of the column in `df` with the numeric
#'   results. Default is ´values´.
#' @param id_col String with the name of the column in `df`with the identifiers
#'   of each row.
#' @param id_std String identifying the standard used for bracketing. Default is
#'   "Std".
#' @param pos Integer giving the line of the first standard measurement that
#'   opens the first bracket.
#' @param weight_std A vector of length 2 with numeric value giving the weight
#'   assigned to the opening and closing standard of a bracket, respectively.
#'   The sum of both weights must be one. The default `0.5` gives the mean of
#'   both standards.
#' @param sd_input integer that gives the number the standard deviation will be multiplied for.
#'
#' @references Mason, T. F.D., Weiss, D. J., Horstwood, M., Parrish, R. R.,
#'   Russell, S. S., Mullaneb, E., and Colesa, B. J. (2004) High-precision Cu
#'   and Zn isotope analysis by plasma source mass spectrometry. Journal of
#'   Analytical Atomic Spectrometry 19, pp. 209-217.
#'   <https://doi.org/10.1039/B306958C>
#'
#' @returns A data frame with the SSB values plus Standard Error (SE)
#'
#' @export
#'
#' @examples
#' <write here any example code. These are small simple examples on how to use
#' the function or to highlight specific features>

standard_sample_bracketing <- function(df,
                                       values = "values",
                                       id_col = "ID",
                                       id_std = "Std",
                                       pos = 1,
                                       weight_std = c(0.5, 0.5),
                                       sd_input=1) {

  # Check there are no empty values in header nor id_std
  if (id_std == "") {
    stop("You need to assign the ID of the standard.")
  }

  if (!(values %in% colnames(df))) {
    stop("The column name for the measured values is not included in the provided data frame.")
  }

  # Check of weight values

  checkmate::assert_vector(weight_std, strict = TRUE, len = 2, any.missing = FALSE)

  if (sum(weight_std) != 1) {
    stop("The sum of the weights must be 1.")
  }

  # prepare variables
  df <- df[c(id_col, values)] # make a dataframe with the ID of the samples and the measurements
  nr <- nrow(df) # count number of rows in the dataframe

  sample_names <- sample_results <- sample_results_weighted <- c()

  # SSB calculation

  while (pos+1 <= nr) {
    #iterates over the whole data frame, it starts with the cycles
    std_opening <- df[pos, 2]
    std_opening
    cycle_end<- cycle_start <- pos + 1# move the index to the first sample

    while(df[cycle_end, 1]!=id_std) #Find the second (closing) standard bracket from the cycle
      cycle_end<-cycle_end+1

    std_closing <- df[cycle_end, 2]
    std_mean_weighted <- ((weight_std[1] * std_opening) +
                            (weight_std[2] * std_closing)) #calculate weighted mean
    std_mean <- (std_opening + std_closing) / 2 #calculate mean of both standards

    while (cycle_start < cycle_end) { #run the samples within the cycle
      sample_current <- df[cycle_start, 1]

      if ((!is.na(sample_current)) && (sample_current != "")) {
        sample_measurement <- df[cycle_start, 2]
        ssb <- sample_measurement / std_mean
        sample_names <- append(sample_names, sample_current)
        sample_results <- append(sample_results, ssb)

        if (weight_std[1] != 0.5 ||
              (weight_std[1] + weight_std[2]) != 1.0) {
          ssb_weighted <- format(signif(sample_measurement / std_mean_weighted, 4),
                                 nsmall = 4)
          sample_results_weighted <- append(sample_results_weighted, ssb_weighted)
        }
      }
      cycle_start <- cycle_start + 1
    }
    pos <- cycle_start
  }

  # for some reason, they are a list rather a vector, so turning them into vector
  sample_names <- unlist(sample_names)
  sample_results <- unlist(sample_results)

  # Combine calculated values into data frame and order them by sample name
  results <- data.frame(description = sample_names, Linear_SSB = sample_results)
  results <- results[order(results$description), , drop = FALSE]

  # Calculate errors and averages for each sample
  nr <- length(sample_names)
  pos <- 2
  counter <- 1
  sample_current <- results[1, 1]
  sample_mean <- results[1, 2]
  average <- sd_dev <- c()


  while (pos <= nr) {
    #iterates over the results dataframe to calculate averages and standard error

    if (is.na(results[pos, 1]) || (sample_current == results[pos, 1])) {
      counter <- counter + 1
      sample_mean <- sample_mean + results[pos, 2]
      sd_dev <- append(sd_dev, "")
      average <- append(average, "")

    } else {
      sample_mean <- format(signif(sample_mean / counter, 4), nsmall = 4)
      array <- sample_results[(pos - counter):(pos - 1)]
      sdev <- format(signif(sd_input * sd(array), 4), nsmall = 4)
      sd_dev <- append(sd_dev, sdev)
      average <- append(average, sample_mean)
      sample_current <- results[pos, 1]
      sample_mean <- results[pos, 2]
      counter <- 1
    }
    pos <- pos + 1
  }

  sample_mean <- format(signif(sample_mean / counter, 4), nsmall = 4)
  array <- sample_results[(pos - counter):(pos - 1)]
  sdev <- format(signif(sd_input * sd(array), 4), nsmall = 4)
  sd_dev <- append(sd_dev, sdev)
  average <- append(average, sample_mean)

  if (weight_std[1] != 0.5 || (weight_std[1] + weight_std[2]) != 1.0) {
    output <- data.frame(
      description = sample_names,
      Linear_SSB = format(signif(sample_results, 4), nsmall = 4),
      Weighted_SSB = sample_results_weighted,
      #add weighted values to the array
      Mean = average,
      SD = sd_dev
    )


  } else {
    output <- data.frame(
      description = sample_names,
      SSB = format(signif(sample_results, 4), nsmall = 4),
      Mean = average,
      SD = sd_dev
    )


  }
  colnames(output)[5] <- paste0(sd_input, "SD")
  return(output)
}

ID<- c("std", "11","std", "11", "std", "22", "std", "33", "std")
Isotope_data<- c(1.0, 1.5, 1.0, 1.6, 1.0, 2, 1.0, 1.7, 1.0)
#df<- data.frame(ID, Isotope_data)
vector<- c(0.4, 0.6)

df<- read.csv("C:/Users/aacevedomejia/Documents/Andrea/Project/Programming/test3.csv", sep=";", dec=",")
df[1]
standard_sample_bracketing(df,"Isotope_data","ID" ,"Std", 1, vector, 1)

