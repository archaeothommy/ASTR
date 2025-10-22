
#' Managing standard bracketing
#'
#' @description
#' Working with standard bracketing during analysis
#'
#' @details
#' <Any text written here goes into the "Details" section>
#'
#'
#' @param data < Dataframe with analysis results from the machine>
#' @param ID_std string, <ID of the standard for bracketing>. The default value is "".
#' @param pos integer <position of the first line for bracketing>.
#' @param mp integer <multiplier>.
#'
#' @references
#' <include here any relevant literature references>
#'
#' @returns
#' <Describe the output of the function. This part goes into the "Value" section>
#'
#' @export # remove if the function should not be visible to the user
#'
#' @examples
#' <write here any example code. These are small simple examples on how to use
#' the function or to highlight specific features>

library(readr)
library(tibble)
library(dplyr)


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
  counter<-0
  nsamples<-0
  i<-pos+1
  
  while (i<=nr){ #iterates over the whole dataframe, it starts with the cycles
    
    if (df[i,1]==ID_std){ #if we are in a standard, we need to check if its the first or the second part of the bracketing
      
      if(SecondStd==0) { #if true, we are closing the bracketing for the sample, so we need to calculate SBB 
        SecondStd<-df[i,2]
        StdMean<-(FirstStd+SecondStd)/2#calculate mean of both standards
        SBB<-SampleMeasurement/StdMean #calculate SBB per sample measurement
        MeanSBBSamples<- MeanSBBSamples+SBB #add the new sbb value to further on calculate the average per sample
        SampleNames<-append(SampleNames, CurrentSample)
        print(CurrentSample)
        print(SBB)
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
        if (CurrentSample==df[i,1]) #if the sample in the iteration is equal to the current sample, we only increase the counter
          counter<-counter+1
          
        else{ #time to calculate the average SBB for the previous sample, and prepare everything for the new one
          
          MeanSBBSamples<- MeanSBBSamples/counter #Calculate the mean
          print(paste("Average ", CurrentSample, MeanSBBSamples ))
          CurrentSample<- df[i,1] #Define the new current sample
          counter<-1
        }
    } 
    
    i<- i+1 #increase in 1 the iterator so it continues with the next row
    
  }

}

file <- read.csv2("C:/Users/aacevedomejia/Documents/Andrea/Project/Programming/test3.csv")
standard_sample_bracketing(file, "Std", "Isotope_data", 1, 1000)


