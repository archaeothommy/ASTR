# standard sample bracketing works as expected

    Code
      standard_sample_bracketing(subset_to_bracket, id_col = "Sample Name...1",
        id_values = "Cu65/63 corr 68/66", id_error = "Error...3", std = "Cu/Zn in house 25ppb")
    Output
      # A tibble: 12 x 3
         ID                `Cu65/63 corr 68/66_ratio` `Cu65/63 corr 68/66_errSD`
         <chr>             <chr>                      <chr>                     
       1 BIL-1/1 0807      0.9994                     7.441e-05                 
       2 BIL-2/1 1107      0.9992                     6.544e-06                 
       3 BIL-4/1 0807      0.9980                     2.823e-05                 
       4 BIL-4/1A 1107     0.9982                     4.09e-05                  
       5 BIL-4/2 0807      0.9980                     2.031e-05                 
       6 BIL-4/2A 1107     0.9986                     2.996e-05                 
       7 BIL-4/2A 1107 bis 0.9986                     NA                        
       8 BIL-5/1 0807      0.9985                     2.837e-05                 
       9 BIL-5/1A 1107     0.9987                     1.526e-05                 
      10 BIL-5/2 0807      0.9986                     0.000749                  
      11 BIL-5/2A 0807     0.9979                     3.235e-05                 
      12 BIL-5/2A 1107     0.9979                     NA                        

