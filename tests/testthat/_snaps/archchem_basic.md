# reading of a basic example table works as expected

    Code
      as.data.frame(test_input)
    Output
           ID 206Pb/204Pb       Al2O3 SiO2+Al2O3   204Pb other other2      K2O  d18O
      1 troet         0.5 3 [count/s]   20 [ppt] 7 [ppm] troet     27 23 [wtP] -5.32
        SiO2/FeO         Mn        Zn SiO2/(FeO+MnO) Sb/As        Sn K2O+MgO+Na2O
      1      0.5 2.45 [atP] 240 [ppm]           0.32  5.69 56 [µg/g]     54 [wtP]

---

    Code
      as.data.frame(test_input2)
    Output
               ID   Sample Lab no.                    Site latitude  longitude Type
      1    TR-001   TR-001 3421/19                  Bochum 51.48165   7.216480    1
      2  TR-002_1 TR-002_1 3423/19                  Oviedo 43.36029  -5.844760    2
      3  TR-002_2 TR-002_2 3435/19                  Oviedo 43.36029  -5.844760    2
      4    TR-003   TR-003 3422/19                    佛山 23.02677 113.131480    3
      5    TR-004   TR-004 3429/19                   Băiuț 43.23490  23.124983    4
      6    TR-005   TR-005 3430/19                   Şuior 41.44557  24.935661    5
      7  TR-006.1 TR-006.1 3431/19                Blagodat 41.45313  25.505011    5
      8  TR-006.2 TR-006.2 3432/19                 Pezinok 45.92125  15.919219    1
      9  TR-006.3 TR-006.3 3433/19 Free State Geduld Mines 50.35621   7.651314    4
      10   smn348   smn348 3424/19                 Aggenys 50.99160   8.027573    3
      11   smn349   smn349 3425/19              Chiprovtsi 50.68903   6.406379    3
      12   smn350   smn350 3426/19 Krusov Dol; Krushev Dol 40.69575  24.591976    5
      13   smn351   smn351 3427/19                   Masua 37.72618  24.012951    1
      14     8896     8896 3428/19                  Σπαρτη 37.07446  22.430090    1
         method_comp 143Nd/144Nd d65Cu d65Cu_err2SD      Na2O         BaO          Pb
      1       ICP-MS    0.513014  1.24       0.1240 3.1 [wtP] 0.070 [wtP]  6.34 [wtP]
      2       ICP-MS    0.512994  0.88       0.0600 2.2 [wtP] 0.070 [wtP]  3.52 [wtP]
      3       ICP-MS    0.512996  0.85       0.0500 5.0 [wtP] 0.054 [wtP]  3.60 [wtP]
      4       ICP-MS    0.513008  2.76       0.2760 6.9 [wtP] 0.040 [wtP]  5.07 [wtP]
      5       ICP-MS          NA -8.21      -0.8210 3.0 [wtP] 0.030 [wtP]  9.15 [wtP]
      6       ICP-MS          NA  0.06       0.0040 4.1 [wtP] 0.070 [wtP] 12.61 [wtP]
      7       ICP-MS          NA  1.48       0.2220 3.4 [wtP] 0.050 [wtP] 12.68 [wtP]
      8       ICP-MS          NA -0.42      -0.0420 1.8 [wtP] 0.040 [wtP]  5.31 [wtP]
      9       ICP-MS          NA  0.30       0.0200 5.1 [wtP] 0.090 [wtP]  2.36 [wtP]
      10      ICP-MS    0.512977  0.24       0.0240 4.1 [wtP] 0.340 [wtP] 47.49 [wtP]
      11      ICP-MS    0.513004  0.54       0.0100 3.4 [wtP] 0.040 [wtP]  2.53 [wtP]
      12      ICP-MS    0.512991  2.04       0.8000 4.5 [wtP] 0.070 [wtP]  1.56 [wtP]
      13      ICP-MS          NA -0.24      -0.0504 3.2 [wtP] 0.040 [wtP]  3.64 [wtP]
      14      ICP-MS          NA -0.42      -0.0420 3.7 [wtP] 0.060 [wtP]  7.51 [wtP]
                MgO      Al2O3        SiO2 SiO2_errSD%       P2O5          S
      1  0.77 [wtP] 3.92 [wtP] 31.63 [wtP]    4.30 [%] 0.15 [wtP] 2.57 [atP]
      2  0.55 [wtP] 3.46 [wtP] 29.06 [wtP]    2.88 [%]   NA [wtP]   NA [atP]
      3  0.33 [wtP] 5.87 [wtP] 30.50 [wtP]    5.71 [%] 0.11 [wtP] 3.68 [atP]
      4  0.76 [wtP] 4.33 [wtP] 25.73 [wtP]    2.22 [%] 0.23 [wtP] 2.76 [atP]
      5  0.52 [wtP] 4.17 [wtP] 43.50 [wtP]    4.65 [%] 0.40 [wtP] 0.57 [atP]
      6  0.58 [wtP] 3.58 [wtP] 33.83 [wtP]    3.67 [%] 0.29 [wtP] 0.61 [atP]
      7  0.64 [wtP] 5.60 [wtP] 33.81 [wtP]    3.00 [%] 0.43 [wtP] 0.77 [atP]
      8  0.59 [wtP] 4.47 [wtP] 26.39 [wtP]    2.87 [%] 0.62 [wtP] 3.04 [atP]
      9  0.53 [wtP] 3.73 [wtP] 21.18 [wtP]    3.44 [%] 0.24 [wtP] 3.93 [atP]
      10 0.70 [wtP] 6.27 [wtP] 31.73 [wtP]    6.12 [%] 0.28 [wtP] 0.21 [atP]
      11 0.46 [wtP] 2.91 [wtP] 16.91 [wtP]    3.73 [%] 0.22 [wtP] 3.57 [atP]
      12 0.58 [wtP] 3.60 [wtP] 28.49 [wtP]    4.89 [%] 0.19 [wtP] 1.95 [atP]
      13 0.88 [wtP] 5.24 [wtP] 38.04 [wtP]   10.12 [%] 0.30 [wtP] 1.35 [atP]
      14 0.84 [wtP] 3.97 [wtP] 31.67 [wtP]    4.30 [%] 0.18 [wtP] 0.83 [atP]
                CaO       TiO2        MnO      FeOtot FeOtot_err2SD       ZnO
      1  2.11 [wtP] 0.52 [wtP] 0.20 [wtP] 43.83 [wtP]   4.120 [wtP]  5.64 [%]
      2  2.34 [wtP] 0.49 [wtP] 0.54 [wtP] 51.02 [wtP]   3.890 [wtP]  4.07 [%]
      3  2.00 [wtP] 0.55 [wtP] 0.10 [wtP] 30.59 [wtP]   2.940 [wtP]  6.87 [%]
      4  3.91 [wtP] 0.27 [wtP] 0.70 [wtP] 46.09 [wtP]   3.500 [wtP]  5.87 [%]
      5  1.79 [wtP] 0.24 [wtP] 1.00 [wtP] 31.91 [wtP]   2.870 [wtP]  2.26 [%]
      6  2.06 [wtP] 0.18 [wtP] 0.49 [wtP] 36.57 [wtP]   5.486 [wtP]  1.66 [%]
      7    NA [wtP]   NA [wtP] 1.52 [wtP] 35.52 [wtP]   2.660 [wtP]  2.46 [%]
      8  4.28 [wtP]   NA [wtP] 0.40 [wtP] 41.20 [wtP]   3.890 [wtP] 11.65 [%]
      9  4.08 [wtP] 0.15 [wtP] 0.46 [wtP] 48.26 [wtP]   2.268 [wtP]  6.80 [%]
      10 7.14 [wtP]   NA [wtP] 0.24 [wtP]  5.26 [wtP]   0.305 [wtP]  0.03 [%]
      11 2.50 [wtP] 0.14 [wtP] 0.21 [wtP] 56.36 [wtP]   6.763 [wtP]  4.89 [%]
      12 1.39 [wtP] 0.17 [wtP] 0.13 [wtP] 47.64 [wtP]   4.235 [wtP]  6.56 [%]
      13 2.10 [wtP] 0.34 [wtP] 1.32 [wtP] 43.21 [wtP]   2.161 [wtP]  1.52 [%]
      14 3.51 [wtP] 0.24 [wtP] 0.34 [wtP] 45.90 [wtP]   2.387 [wtP]  0.85 [%]
                K2O         Cu         As        LOI         Ag           Sn
      1  1.34 [wtP] 0.11 [wtP] 0.02 [wtP] 1.89 [wtP]  500 [ppb]   85 [µg/ml]
      2  1.26 [wtP] 0.22 [wtP] 0.01 [wtP]   NA [wtP]  200 [ppb]   85 [µg/ml]
      3  1.54 [wtP] 0.74 [wtP]   NA [wtP]   NA [wtP]  210 [ppb]   98 [µg/ml]
      4  1.66 [wtP] 0.13 [wtP] 0.01 [wtP]   NA [wtP]  350 [ppb]   45 [µg/ml]
      5  2.15 [wtP] 0.14 [wtP] 0.03 [wtP] 3.57 [wtP]  400 [ppb]   14 [µg/ml]
      6  1.21 [wtP] 0.09 [wtP] 0.11 [wtP] 5.66 [wtP]  250 [ppb]  181 [µg/ml]
      7  2.26 [wtP] 0.21 [wtP] 0.23 [wtP] 0.12 [wtP]  120 [ppb]  566 [µg/ml]
      8  1.86 [wtP] 0.43 [wtP] 0.02 [wtP] 0.89 [wtP]  430 [ppb]  203 [µg/ml]
      9  2.01 [wtP] 0.59 [wtP] 0.08 [wtP] 4.75 [wtP]  300 [ppb] 5594 [µg/ml]
      10 1.34 [wtP] 0.07 [wtP] 0.06 [wtP]   NA [wtP] 2420 [ppb]   32 [µg/ml]
      11 1.34 [wtP] 0.15 [wtP] 0.01 [wtP] 4.22 [wtP]  140 [ppb]   23 [µg/ml]
      12 0.98 [wtP] 0.16 [wtP] 0.02 [wtP] 6.01 [wtP] 1610 [ppb]   45 [µg/ml]
      13 1.48 [wtP] 0.27 [wtP] 0.05 [wtP] 3.22 [wtP]  100 [ppb]   15 [µg/ml]
      14 1.32 [wtP] 0.09 [wtP] 0.14 [wtP]   NA [wtP]  100 [ppb]  146 [µg/ml]
                 Sb       Te        Bi        U        V        Cr       Co        Ni
      1   370 [ppm]  2 [ppm]  18 [ppm]  3 [ppm] 60 [ppm] 160 [ppm] 60 [ppm]  60 [ppm]
      2   210 [ppm]  2 [ppm]  20 [ppm]  2 [ppm] 60 [ppm] 140 [ppm] 70 [ppm] 100 [ppm]
      3   256 [ppm] NA [ppm]  47 [ppm] NA [ppm] 63 [ppm]  99 [ppm] 55 [ppm]  87 [ppm]
      4   400 [ppm]  2 [ppm]  NA [ppm]  2 [ppm] 45 [ppm]  30 [ppm] 30 [ppm]  20 [ppm]
      5   410 [ppm]  2 [ppm]   6 [ppm]  3 [ppm] 55 [ppm]  75 [ppm] NA [ppm]  10 [ppm]
      6   453 [ppm]  6 [ppm]   9 [ppm]  3 [ppm] 54 [ppm]  41 [ppm]  8 [ppm]  47 [ppm]
      7   701 [ppm]  8 [ppm]   9 [ppm] NA [ppm] 75 [ppm] 106 [ppm] 22 [ppm]  19 [ppm]
      8   231 [ppm] 15 [ppm]   3 [ppm] NA [ppm] 84 [ppm]  91 [ppm] 47 [ppm]  34 [ppm]
      9   107 [ppm]  6 [ppm]   5 [ppm]  5 [ppm] 32 [ppm]  63 [ppm] 17 [ppm]  37 [ppm]
      10 3310 [ppm]  9 [ppm] 150 [ppm] NA [ppm] 61 [ppm]  45 [ppm] NA [ppm]   4 [ppm]
      11   95 [ppm]  5 [ppm]   1 [ppm]  3 [ppm] 37 [ppm]  36 [ppm] 69 [ppm]  39 [ppm]
      12   78 [ppm]  5 [ppm]   4 [ppm]  3 [ppm] 40 [ppm]  33 [ppm] 43 [ppm]  39 [ppm]
      13  610 [ppm]  2 [ppm]   1 [ppm]  2 [ppm] 80 [ppm] 190 [ppm] 20 [ppm]  50 [ppm]
      14  390 [ppm] NA [ppm]  NA [ppm]  1 [ppm] 40 [ppm] 100 [ppm] 10 [ppm]  65 [ppm]
                Sr       Se FeOtot/SiO2 (Na2O+K2O)/SiO2 206Pb/204Pb
      1  130 [ppm] NA [ppm]       1.386         0.14037    18.61147
      2  120 [ppm] NA [ppm]       1.756         0.11906    18.61617
      3  121 [ppm] 15 [ppm]       1.003         0.21443    18.61615
      4  250 [ppm] NA [ppm]       1.791         0.33269    18.61272
      5  160 [ppm] NA [ppm]       0.734         0.11839    18.63562
      6  258 [ppm] NA [ppm]       1.081         0.15696    18.63952
      7  122 [ppm]  3 [ppm]       1.051         0.16741    18.64465
      8  280 [ppm]  3 [ppm]       1.561         0.13869    18.83274
      9  310 [ppm] NA [ppm]       2.279         0.33569    18.83312
      10 287 [ppm]  5 [ppm]       0.166         0.17145    18.80371
      11 155 [ppm] NA [ppm]       3.333         0.28031    18.80760
      12 165 [ppm] NA [ppm]       1.672         0.19235    18.81356
      13 100 [ppm] NA [ppm]       1.136         0.12303    18.81501
      14 120 [ppm] NA [ppm]       1.449         0.15851    18.82037
         206Pb/204Pb_err2SD 207Pb/204Pb 207Pb/204Pb_err2SD 208Pb/204Pb
      1             0.01082    15.65405            0.00915    38.75630
      2             0.01629    15.65682            0.01341    38.76404
      3             0.01698    15.65740            0.01441    38.76411
      4             0.00926    15.65677            0.00747    38.76097
      5             0.01189    15.64765            0.00989    38.73583
      6             0.01802    15.65502            0.01513    38.75729
      7             0.01468    15.65836            0.01210    38.76615
      8             0.01608    15.82161            0.01350    39.20161
      9             0.01875    15.82042            0.01619    39.20067
      10            0.03129    15.81646            0.02600    39.15557
      11            0.01550    15.82128            0.01309    39.17608
      12            0.01557    15.82045            0.01305    39.17244
      13            0.01535    15.80824            0.01350    39.13346
      14            0.01483    15.81119            0.01252    39.13715
         208Pb/204Pb_err2SD 207Pb/206Pb 207Pb/206Pb_err2SD 208Pb/206Pb
      1             0.02270     0.84110            0.00006     2.08239
      2             0.03450     0.84103            0.00013     2.08229
      3             0.03452     0.84107            0.00014     2.08228
      4             0.01820     0.84119            0.00010     2.08251
      5             0.02561     0.83966            0.00009     2.07858
      6             0.04157     0.83989            0.00012     2.07923
      7             0.02716     0.83984            0.00009     2.07928
      8             0.03356     0.84852            0.00007     2.10238
      9             0.04173     0.84846            0.00007     2.10235
      10            0.06458     0.84955            0.00007     2.10313
      11            0.03091     0.84963            0.00012     2.10388
      12            0.03263     0.84931            0.00007     2.10297
      13            0.03109     0.84859            0.00007     2.10076
      14            0.03182     0.84851            0.00007     2.10030
         208Pb/206Pb_err2SD
      1             0.00017
      2             0.00033
      3             0.00033
      4             0.00025
      5             0.00023
      6             0.00032
      7             0.00023
      8             0.00017
      9             0.00018
      10            0.00026
      11            0.00022
      12            0.00022
      13            0.00018
      14            0.00024

---

    Code
      print(test_input)
    Output
      [1marchchem table[22m
      Analytical columns: [0;32m206Pb/204Pb[0m, [0;32mAl2O3[0m, [0;32mSiO2+Al2O3[0m, [0;32m204Pb[0m, [0;32mK2O[0m, [0;32md18O[0m, [0;32mSiO2/FeO[0m, [0;32mMn[0m, [0;32mZn[0m, [0;32mSiO2/(FeO+MnO)[0m, [0;32mSb/As[0m, [0;32mSn[0m, [0;32mK2O+MgO+Na2O[0m
      Contextual columns: [0;35mother[0m, [0;35mother2[0m 
      # A data frame: 1 x 16
        ID    `206Pb/204Pb`     Al2O3 `SiO2+Al2O3` `204Pb` other other2   K2O  d18O
        <chr>         <dbl> [count/s]        [ppt]   [ppm] <chr>  <dbl> [wtP] <dbl>
      1 troet           0.5         3           20       7 troet     27    23 -5.32
      # i 7 more variables: `SiO2/FeO` <dbl>, Mn [atP], Zn [ppm],
      #   `SiO2/(FeO+MnO)` <dbl>, `Sb/As` <dbl>, Sn [µg/g], `K2O+MgO+Na2O` [wtP]

