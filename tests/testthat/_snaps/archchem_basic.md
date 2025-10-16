# reading of a basic example table works as expected

    Code
      test_input <- read_archchem("input_format.csv")
      as.data.frame(test_input)
    Output
        206Pb/204Pb Al2O3_% SiO2+Al2O3_ppt 204Pb_ppm other other2 K2O_wt%       d18O
      1     0.5 [1]   3 [%]       20 [ppt]   7 [ppm] troet     27  23 [%] -0.532 [%]
        SiO2/FeO   Mn_at%    Zn_ppm SiO2/(FeO+MnO)    Sb/As   Sn_µg/g
      1  0.5 [1] 2.45 [%] 240 [ppm]       0.32 [1] 5.69 [1] 56 [µg/g]
        K2O+MgO+Na2O_wt%
      1           54 [%]

