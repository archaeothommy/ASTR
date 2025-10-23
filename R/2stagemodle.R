iso_output <- function(Mu1 = 10){
  #### Table 1 ####
  library(tidyverse)
  table1 <- tibble(
    stacykamer1975 = c("stage 1", "stage 2", "present"),
    "206204" = c(9.307, 11.152, 18.7),
    "207/204" = c(10.294, 12.998, 15.628),
    "208/204" = c(29.476, 31.23, 38.63),
    "mu" = c(7.192, 9.735, 9.735),
    "omega" = c(32.208, 36.837, 36.837)
  ) %>% mutate("k=w/m" = omega / mu)
  
  ##### Constants #####
  
  Ti <- 3.70e+09 # Starting time of Second Stage
  a0 <- 11.152 # 206 pb/204pb initial
  b0 <- 12.998 # 207 pb/204pb initial
  lambda1 <- 1.55125E-10 # 238U (to 206Pb) decay constant
  lambda2 <- 9.8485E-10 # 235U (to 207Pb) decay constant
  c0 <- 31.23 # 208 pb/204pb initial
  lambda3 <- 4.95E-11 # 232Th (to 208Pb) decay constant
  
  ##### Time intervals ######
  
  t0 <- 0
  t1 <- 1.00E+09
  t2 <- 2.00E+09
  t3 <- 3.00E+09
  t3.6 <- 3.60E+09
  t0.2 <- 2.00E+08
  t0.4 <- 4.00E+08
  t0.6 <- 6.00E+08
  t0.8 <- 8.00E+08
  
  time <- c(t0, t1, t2, t3, t3.6, t0.2, t0.4, t0.6, t0.8)
  
  ##### 6/4 #####
  
  pb6.4 <- c(20,18,16,14, table1[[2,2]])
  
  ##### Isocrong  7/4 vs 6/4 ######
  
  functionA <- function(t){
    exp(lambda1*Ti) - exp(lambda1*t)
  }
  functionB <- function(t){
    exp(lambda2*Ti) - exp(lambda2*t)
  }
  functionAB <- function(t){
    functionB(t)/functionA(t)
  }
  slopeM <- function(t){
    (1/137.88)*functionAB(t)
  }
  y7.4 <- function(t, x){
    slopeM(t)*(x-a0)+b0
  }
  
  
  pb7.4pb6.4 <-
    data.frame(Time = numeric(), "6.4" = numeric(), Output = numeric(), stringsAsFactors = FALSE)
  
  # Loop through time and pb6.4
  for (t in time) {
    for (x in pb6.4) {
      # Compute the function result
      output_value <- y7.4(t, x)
      
      # Append the results as a new row
      pb7.4pb6.4 <- rbind(pb7.4pb6.4, data.frame(Time = t, `X6.4` = x, Output = output_value))
    }
  }
  
  pb7.4pb6.4_table <- pivot_wider(pb7.4pb6.4, id_cols = `X6.4`, names_from = Time, values_from = Output)
  
  ##### 8/4 vs. 6/4 #####
  
  functionC <- function(t){
    exp(lambda3*Ti) - exp(lambda3*t)
  }
  mu <- 8
  omega <- 35
  k <- omega/mu
  SlopM2 <- function(t){k*(functionC(t)/functionA(t))}
  y8.4 <- function(t, x){
    SlopM2(t)*(x-a0)+c0
  }
  
  pb8.4pb6.4 <-
    data.frame(Time = numeric(), "6.4" = numeric(), Output = numeric(), stringsAsFactors = FALSE)
  
  for (t in time) {
    for (x in pb6.4) {
      # Compute the function result
      output_value <- y8.4(t, x)
      
      # Append the results as a new row
      pb8.4pb6.4 <- rbind(pb8.4pb6.4, data.frame(Time = t, `X6.4` = x, Output = output_value))
    }
  }
  
  pb8.4pb6.4_table <- pivot_wider(pb8.4pb6.4, id_cols = `X6.4`, names_from = Time, values_from = Output)
  
  ##### Growth Curves ######
  
  mu_list <- c(6, 9, 10, 12)
  k_list <- seq(3, 5, by=0.2)
  omega_func <- function(kap, mu){
    kap*mu
  }
  
  growth_curv6.4 <- function(t, mu){
    a0+(mu*functionA(t))
  }
  growth_curv7.4 <- function(t, mu){
    b0+(mu/137.88)*functionB(t)
  }
  growth_curv8.4 <- function(t, kap, mu){
    c0+omega_func(kap, mu)*functionC(t)
  }
  
  ##### Output Stage 2 #####
  
  iso_output <- data.frame(Time = numeric(), mu = numeric(), kapa = numeric(),
                           omega = numeric(), `X6/4`= numeric(),
                           `X7/4`= numeric(), `X8/4`= numeric())
  
  for (t in time){
    for (m in mu_list){
      for(k in k_list){
        iso_output <- rbind(iso_output, data.frame(
          Time = t,
          mu = m,
          kapa = k,
          omega = omega_func(k, m),
          `X6/4` = growth_curv6.4(t, m),
          `X7/4` = growth_curv7.4(t, m),
          `X8/4` = growth_curv8.4(t, k, m)
        ))
      }
    }
  }
  
  ##### Stage 1 Constants ######
  
  omega1 <- table1[[1,6]]
  mu1 <- table1[[1,5]]
  
  growth_curv6.4(t0, mu1)
  stage1 <- data.frame(
    Time = time,
    `x6/4`= sapply(time, growth_curv6.4, mu = mu1),
    `x7/4`= sapply(time, growth_curv7.4, mu = mu1),
    `x8/4`= sapply(time, function(t){ c0+omega1*functionC(t)})
  )
  
  iso_output2 <- filter(iso_output, mu == Mu1)
  
  return(iso_output2)
}