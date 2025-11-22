

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
#' @param df data frame including at least a column with the with analysis
#'   results from the machine
#' @param values String with the name of the column with the numeric results.
#'   Default is ´value´.
#' @param id_std String identifying the standard used for bracketing. Default is
#'   "Std".
#' @param pos Integer giving the line of the first standard measurement that
#'   opens the bracket.
#' @param cycle_size integer giving the number of samples per bracket.
#' @param weight_opening,weight_closing Numeric value giving the weight assigned
#'   to the opening and closing standard of a bracket, respectively. The default
#'   `0.5` gives the mean of both standards.
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
                                       values = "",
                                       id_std = "Std",
                                       pos = 0,
                                       cycle_size = 1,
                                       weight_opening = 0.5,
                                       weight_closing = 0.5) {

  # Check there are no empty values in header nor id_std
  if (id_std == "") {
    stop("You need to assign the ID of the standard.")
  }

  if (values == "" && !(values %in% colnames(df))) {
    stop("The column name for the measured values is not included in the provided data frae.")
  }

  df <- df[c("ID", values)] # make a dataframe with the ID of the samples and the measurements
  nr <- nrow(df) #count number of rows in the dataframe

  FirstStd <- df[pos, 2]
  SecondStd <- 0
  MeanSBBSamples <- 0
  CurrentSample <- ""
  SampleNames <- c()
  SampleResults <- c()
  WSampleResults <- c()
  counter <- 0
  nsamples <- 0
  i <- pos

  while (i <= nr) {
    #iterates over the whole dataframe, it starts with the cycles

    icicle <- i
    ecicle <- i + cycle_size + 1
    FirstStd <- df[icicle, 2]
    SecondStd <- df[ecicle, 2]
    icicle <- icicle + 1 #move the index to the first sample
    WeightedStdMean <- ((weight_opening * FirstStd) +
                          (weight_closing * SecondStd)) / (weight_opening + weight_closing) #calculate weighted mean
    StdMean <- (FirstStd + SecondStd) / (2) #calculate mean of both standards

    while (icicle < ecicle) {
      CurrentSample <- df[icicle, 1]
      if ((!is.na(CurrentSample)) && (CurrentSample != "")) {
        SampleMeasurement <- df[icicle, 2]
        SBB <- SampleMeasurement / StdMean
        SampleNames <- append(SampleNames, CurrentSample)
        SampleResults <- append(SampleResults, SBB)
        if (weight_opening != 0.5 ||
              (weight_opening + weight_closing) != 1.0) {
          WSBB <- format(signif(SampleMeasurement / WeightedStdMean, 4),
                         nsmall = 4)
          WSampleResults <- append(WSampleResults, WSBB)
        }
      }
      icicle <- icicle + 1
    }
    i <- icicle
  }

  nr <- length(SampleNames)
  ResultDF <- data.frame(description = SampleNames, LinearSBB = SampleResults)

  ResultDF <- ResultDF[order(ResultDF$description), , drop = FALSE] #order results by the sample name
  i <- 2
  counter <- 1
  CurrentSample <- ResultDF[1, 1]
  MeanSample <- ResultDF[1, 2]
  Average <- c()
  SError <- c()

  while (i <= nr) {
    #iterates over the results dataframe to calculate averages and standard error

    if (is.na(ResultDF[i, 1]) || (CurrentSample == ResultDF[i, 1])) {
      counter <- counter + 1
      MeanSample <- MeanSample + ResultDF[i, 2]
      SError <- append(SError, "")
      Average <- append(Average, "")

    } else {
      MeanSample <- format(signif(MeanSample / counter, 4), nsmall = 4)
      array <- SampleResults[(i - counter):(i - 1)]
      SE <- format(signif(2 * sd(array), 4), nsmall = 4)
      SError <- append(SError, SE)
      Average <- append(Average, MeanSample)
      CurrentSample <- ResultDF[i, 1]
      MeanSample <- ResultDF[i, 2]
      counter <- 1

    }

    i <- i + 1
  }
  MeanSample <- format(signif(MeanSample / counter, 4), nsmall = 4)
  array <- SampleResults[(i - counter):(i - 1)]
  SE <- format(signif(2 * sd(array), 4), nsmall = 4)
  SError <- append(SError, SE)
  Average <- append(Average, MeanSample)


  if (weight_opening != 0.5 || (weight_opening + weight_closing) != 1.0) {
    FinalDF <- data.frame(
      description = SampleNames,
      Linear_SBB = format(signif(SampleResults, 4), nsmall = 4),
      Weighted_SBB = WSampleResults,
      #add weighted values to the array
      Mean = Average,
      SE = SError
    )

  } else {
    FinalDF <- data.frame(
      description = SampleNames,
      SBB = format(signif(SampleResults, 4), nsmall = 4),
      Mean = Average,
      SE = SError
    )
  }
  return(FinalDF)

}
