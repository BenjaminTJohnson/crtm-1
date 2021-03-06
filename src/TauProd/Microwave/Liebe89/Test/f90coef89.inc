!**********************************************************************
!     coeff from Liebe's paper
!     International. Jou. Infrared and Millimeter Waves, Vol 10,No 6,
!     1989, pp631,650 .
!
!     These coeff. are those published in the paper without any
!     modification.
!
!
!     FREQ DE RES DE L OXYGENE
      DATA FROX/ &
          50.474238,  50.987749,  51.503350,  52.021410,  52.542394, &
          53.066907,  53.595749,  54.130000,  54.671159,  55.221367, &
          55.783802,  56.264775,  56.363389,  56.968206,  57.612484, &
          58.323877,  58.446590,  59.164207,  59.590983,  60.306061, &
          60.434776,  61.150560,  61.800154,  62.411215,  62.486260, &
          62.997977,  63.568518,  64.127767,  64.678903,  65.224071, &
          65.764772,  66.302091,  66.836830,  67.369598,  67.900867, &
          68.431005,  68.960311, 118.750343, 368.498350, 424.763124, &
         487.249370, 715.393150, 773.839675, 834.145330 /
!
!     FREQ DE RES DE L'H2O
      DATA FRH2O/ &
          22.235080,  67.813960, 119.995940, 183.310074, 321.225644, &
         325.152919, 336.187000, 380.197372, 390.134508, 437.346667, &
         439.150812, 443.018295, 448.001075, 470.888947, 474.689127, &
         488.491133, 503.568532, 504.482692, 556.936002, 620.700807, &
         658.006500, 752.033227, 841.073593, 859.865000, 899.407000, &
         902.555000, 906.205524, 916.171582, 970.315022, 987.926764/
!
!
      DATA A1/ &
            0.94E-6,    2.46E-6,    6.08E-6,   14.14E-6,   31.02E-6, &
           64.10E-6,  124.70E-6,  228.00E-6,  391.80E-6,  631.60E-6, &
          953.50E-6,  548.90E-6, 1344.00E-6, 1763.00E-6, 2141.00E-6, &
         2386.00E-6, 1457.00E-6, 2404.00E-6, 2112.00E-6, 2124.00E-6, &
         2461.00E-6, 2504.00E-6, 2298.00E-6, 1933.00E-6, 1517.00E-6, &
         1503.00E-6, 1087.00E-6,  733.50E-6,  463.50E-6,  274.80E-6, &
          153.00E-6,   80.09E-6,   39.46E-6,   18.32E-6,    8.01E-6, &
            3.30E-6,    1.28E-6,  945.00E-6,   67.90E-6,  638.00E-6, &
          235.00E-6,   99.60E-6,  671.00E-6,  180.00E-6 /
!
      DATA A2/ &
         9.694, 8.694, 7.744, 6.844, 6.004, &
         5.224, 4.484, 3.814, 3.194, 2.624, &
         2.119, 0.015, 1.660, 1.260, 0.915, &
         0.626, 0.084, 0.391, 0.212, 0.212, &
         0.391, 0.626, 0.915, 1.260, 0.083, &
         1.665, 2.115, 2.620, 3.195, 3.815, &
         4.485, 5.225, 6.005, 6.845, 7.745, &
         8.695, 9.695, 0.009, 0.049, 0.044, &
         0.049, 0.145, 0.130, 0.147 /
!
      DATA A3/ &
          8.60E-3,  8.70E-3,  8.90E-3,  9.20E-3,  9.40E-3, &
          9.70E-3, 10.00E-3, 10.20E-3, 10.50E-3, 10.79E-3, &
         11.10E-3, 16.46E-3, 11.44E-3, 11.81E-3, 12.21E-3, &
         12.66E-3, 14.49E-3, 13.19E-3, 13.60E-3, 13.82E-3, &
         12.97E-3, 12.48E-3, 12.07E-3, 11.71E-3, 14.68E-3, &
         11.39E-3, 11.08E-3, 10.78E-3, 10.50E-3, 10.20E-3, &
         10.00E-3,  9.70E-3,  9.40E-3,  9.20E-3,  8.90E-3, &
          8.70E-3,  8.60E-3, 16.30E-3, 19.20E-3, 19.16E-3, &
         19.20E-3, 18.10E-3, 18.10E-3, 18.10E-3 /
!
      DATA A4/ 38*0., 6*0.6 /
!
      DATA A5/ 1.600E-3,  1.400E-3,  1.165E-3,  0.883E-3,  0.579E-3, &
               0.252E-3, -0.066E-3, -0.314E-3, -0.706E-3, -1.151E-3, &
              -0.920E-3,  2.881E-3, -0.596E-3, -0.556E-3, -2.414E-3, &
              -2.635E-3,  6.848E-3, -6.032E-3,  8.266E-3, -7.170E-3, &
               5.664E-3,  1.731E-3,  1.738E-3, -0.048E-3, -4.290E-3, &
               0.134E-3,  0.541E-3,  0.814E-3,  0.415E-3,  0.069E-3, &
              -0.143E-3, -0.428E-3, -0.726E-3, -1.002E-3, -1.255E-3, &
              -1.500E-3, -1.700E-3, -0.247E-3,  0.      ,  0.      , &
               0.      ,  0.      ,  0.      ,  0. /
!
      DATA A6/ 5.520E-3,  5.520E-3,  5.520E-3,  5.520E-3,  5.520E-3, &
               5.520E-3,  5.520E-3,  5.520E-3,  5.520E-3,  5.514E-3, &
               5.025E-3, -0.069E-3,  4.750E-3,  4.104E-3,  3.536E-3, &
               2.686E-3, -0.647E-3,  1.858E-3, -1.413E-3,  0.916E-3, &
              -2.323E-3, -3.039E-3, -3.797E-3, -4.277E-3,  0.238E-3, &
              -4.860E-3, -5.079E-3, -5.525E-3, -5.520E-3, -5.520E-3, &
              -5.520E-3, -5.520E-3, -5.520E-3, -5.520E-3, -5.520E-3, &
              -5.520E-3, -5.520E-3,  0.003E-3,  0.   ,     0.      , &
               0.   ,     0.      ,  0.      ,  0.   /
!
!
      DATA B1/ &
           0.1090,   0.0011,   0.0007,   2.3000,   0.0464, &
           1.5400,   0.0010,  11.9000,   0.0044,   0.0637, &
           0.9210,   0.1940,  10.6000,   0.3300,   1.2800, &
           0.2530,   0.0374,   0.0125, 510.0000,   5.0900, &
           0.2740, 250.0000,   0.0130,   0.1330,   0.0550, &
           0.0380,   0.1830,   8.5600,   9.1600, 138.0000/
!
      DATA B2/ 2.143, 8.735, 8.356, 0.668, 6.181, &
               1.540, 9.829, 1.048, 7.350, 5.050, &
               3.596, 5.050, 1.405, 3.599, 2.381, &
               2.853, 6.733, 6.733, 0.159, 2.200, &
               7.820, 0.396, 8.180, 7.989, 7.917, &
               8.432, 5.111, 1.442, 1.920, 0.258 /
!
      DATA B3/ 28.11E-3, 28.58E-3, 29.48E-3, 28.13E-3, 23.03E-3, &
               27.83E-3, 26.93E-3, 28.73E-3, 21.52E-3, 18.45E-3, &
               21.00E-3, 18.60E-3, 26.32E-3, 21.52E-3, 23.55E-3, &
               26.02E-3, 16.12E-3, 16.12E-3, 32.10E-3, 24.38E-3, &
               32.10E-3, 30.60E-3, 15.90E-3, 30.60E-3, 29.85E-3, &
               28.65E-3, 24.08E-3, 26.70E-3, 25.50E-3, 29.85E-3 /
!
      DATA B4/ 0.69, 0.69, 0.70, 0.64, 0.67, &
               0.68, 0.69, 0.69, 0.63, 0.60, &
               0.63, 0.60, 0.66, 0.66, 0.65, &
               0.69, 0.61, 0.61, 0.69, 0.71, &
               0.69, 0.68, 0.33, 0.68, 0.68, &
               0.70, 0.70, 0.70, 0.64, 0.68 /
!
      DATA B5/ 4.80, 4.93, 4.78, 5.30, 4.69, &
               4.85, 4.74, 5.38, 4.81, 4.23, &
               4.29, 4.23, 4.84, 4.57, 4.65, &
               5.04, 3.98, 4.01, 4.11, 4.68, &
               4.14, 4.09, 5.76, 4.09, 4.53, &
               5.10, 4.70, 4.78, 4.94, 4.55 /
!
      DATA B6/ 1.00, 0.82, 0.79, 0.85, 0.54, &
               0.74, 0.61, 0.84, 0.55, 0.48, &
               0.52, 0.50, 0.67, 0.65, 0.64, &
               0.72, 0.43, 0.45, 1.00, 0.68, &
               1.00, 0.84, 0.45, 0.84, 0.90, &
               0.95, 0.53, 0.78, 0.67, 0.90 /
!
!**********************************************************************

