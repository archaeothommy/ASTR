
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





standard_sample_bracketing <- function(data, ID_std = "", header="", pos=0, mp=1000) { # update name and arguments. The ellipsis parameter is special in R, use with care!

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
  SError<-c()
  counter<-0
  nsamples<-0
  i<-pos+1

  while (i<=nr){ #iterates over the whole dataframe, it starts with the cycles

    if (df[i,1]==ID_std){ #if we are in a standard, we need to check if its the first or the second part of the bracketing

      if(SecondStd==0) { #if true, we are closing the bracketing for the sample, so we need to calculate SBB
        SecondStd<-df[i,2]
        nsamples<-nsamples+1
        StdMean<-(FirstStd+SecondStd)/2#calculate mean of both standards
        SBB<-SampleMeasurement/StdMean #calculate SBB per sample measurement
        MeanSBBSamples<- MeanSBBSamples+SBB #add the new sbb value to further on calculate the average per sample
        SampleNames<-append(SampleNames, CurrentSample)
        SampleResults<-append(SampleResults, SBB)
        SError<-append(SError, "")
        FirstStd<-SecondStd #Define the second std as the first one to open the bracketing for the next sample
        SecondStd<-0 #Define the second std as zero to define the bracket as open
      }

    }
    else{#it is a sample

      if (counter==0){ #if it is the first time the sample appears on the sequence

        SampleMeasurement<- df[i, 2] #define the sample measurement value
        counter<- counter+1
        CurrentSample<-df[i,1] #define the new current sample
        MeanSBBSamples<-0

      }
      else
        if (CurrentSample==df[i,1]){ #if the sample in the iteration is equal to the current sample, we only increase the counter
          counter<-counter+1
<<<<<<< HEAD
          SampleMeasurement<- df[i, 2]
        }
=======

>>>>>>> 4f4d6827e62ef70bf5dffbf02f7c81a8dbdfe41c
        else{ #time to calculate the average SBB for the previous sample, and prepare everything for the new one

          MeanSBBSamples<- MeanSBBSamples/counter #Calculate the mean
          SampleNames<- append(SampleNames,paste("Average", CurrentSample))
          SampleResults<-append(SampleResults, MeanSBBSamples)
          nsamples<- nsamples+1
          array<-SampleResults[(nsamples-counter):(nsamples-1)]
          SE<- 2*sd(array)
          SError<-append(SError, SE)

          CurrentSample<- df[i,1] #Define the new current sample
          counter<-1
        }
    }

    i<- i+1 #increase in 1 the iterator so it continues with the next row

  }

  ResultDF<-data.frame(
    description = SampleNames,
    calculations = SampleResults,
    SE = SError
  )
  print(ResultDF)

}

file <- read.csv2("C:/Users/aacevedomejia/Documents/Andrea/Project/Programming/test3.csv")
standard_sample_bracketing(file, "Std", "Isotope_data", 1, 1000)


