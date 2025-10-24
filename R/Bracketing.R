
#' Standard Sample Bracketing
#'
#' @description
#' Performs Standard Sample Bracketing (SSB) correction for isotope ratio data.
#'
#' @details
#' This function corrects for instrumental drift or mass bias during isotopic analyses.
#' The measured isotope value of each sample is linearly interpolated between the two standard measurements taken immediately before and after the sample measurement.
#' This function is a useful tool for automating a common practice in handling isotope data. It reduces the likelihood of human error and saves time.
#'
#'
#' @param data < Dataframe with analysis results from the machine>
#' @param ID_std string, <ID of the standard for bracketing>. The default value is "".
#' @param pos integer <position of the first line for bracketing>.
#' @param mp integer <multiplier>.

#'
#' @references
#' Mason, Thomas F.D., Dominik J. Weiss, Matthew Horstwood, Randall R. Parrish, Sara S. Russell, Eta Mullaneb and Barry J. Colesa. 2004. High-precision Cu and Zn isotope analysis by plasma source mass spectrometry. Journal of Analytical Atomic Spectrometry, 19, 209-217. DOI	https://doi.org/10.1039/B306958C
#'
#' @returns
#' A data frame
#'
#' @export
#'
#' @examples
#' <write here any example code. These are small simple examples on how to use
#' the function or to highlight specific features>





standard_sample_bracketing <- function(data, header="", ID_std = "", pos=0, CicleSize=1) { # update name and arguments. The ellipsis parameter is special in R, use with care!

  if (ID_std == ""){
    print("You need to assign the ID of the standard.")
    stop ()
  }
  else
      if (header==""){
        print("You need to define the header of the column with the results.")
        stop (NA)
      }

  df <- data[c("ID", header)]
  nr <- nrow(df)
  FirstStd<-df[pos,2]
  SecondStd<-0
  MeanSBBSamples<-0
  CurrentSample<-""
  SampleNames<- c()
  SampleResults<-c()
  counter<-0
  nsamples<-0
  i<-pos

  while (i<=nr){ #iterates over the whole dataframe, it starts with the cycles

    icicle<-i
    ecicle<-i+CicleSize+1
    FirstStd<-df[icicle,2]
    SecondStd<-df[ecicle, 2]
    icicle<-icicle+1
    StdMean<-(FirstStd+SecondStd)/2#calculate mean of both standards

    while(icicle<ecicle){

      CurrentSample<-df[icicle, 1]
      if((!is.na(CurrentSample)) & (CurrentSample!="")){
        SampleMeasurement<-df[icicle, 2]
        SBB<-SampleMeasurement/StdMean
        SampleNames<-append(SampleNames, CurrentSample)
        SampleResults<-append(SampleResults, SBB)
      }
      icicle<- icicle+1
    }
    i=icicle


  }
    nr<- length(SampleNames)
    #print(nr)
    ResultDF<-data.frame(
      description = SampleNames,
      LinearSBB = SampleResults
    )

    ResultDF<-ResultDF[order(ResultDF$description),,drop=FALSE]

    i=2
    counter=1
    CurrentSample<-ResultDF[1, 1]
    MeanSample=ResultDF[1,2]
    Average<-c()
    SError<-c()
    #SError<-append(SError, "")

    while(i<=nr){


      if(is.na(ResultDF[i,1])|(CurrentSample==ResultDF[i,1])){

        counter<-counter+1
        MeanSample<-MeanSample+ResultDF[i,2]
        SError<-append(SError, "")
        Average<-append(Average, "")

      }
      else{

        MeanSample<-MeanSample/counter
        array<-SampleResults[(i-counter):(i-1)]
        SE<- 2*sd(array)
        SError<-append(SError, SE)
        #print(array)
        Average<-append(Average, MeanSample)
        #print(paste(i-counter-1, i-1))
        #print(paste(CurrentSample,MeanSample, SE))
        CurrentSample<-ResultDF[i,1]
        MeanSample<-ResultDF[i,2]
        counter<-1

      }

      i<-i+1
    }
    MeanSample<-MeanSample/counter
    array<-SampleResults[(i-counter):(i-1)]
    #print(array)
    SE<- 2*sd(array)
    SError<-append(SError, SE)
    Average<-append(Average, MeanSample)


    a=nrow(SampleNames)
    b=nrow(SampleResults)
    c=nrow(Average)
    d=nrow(SError)
    #print(SError)
    FinalDF<-data.frame(
        description = SampleNames,
        LinearSBB = SampleResults,
        Mean=Average,
        SE = SError
    )
    print(FinalDF)

}



#file <- read.csv2("C:/Users/aacevedomejia/Documents/Andrea/Project/Programming/FlowerDataProcessing-SBB-test-04.csv")
#file <- read.csv2("C:/Users/aacevedomejia/Documents/Andrea/Project/Programming/test3.csv")
standard_sample_bracketing(file, "Isotope_data", "Std", 1, 3)


