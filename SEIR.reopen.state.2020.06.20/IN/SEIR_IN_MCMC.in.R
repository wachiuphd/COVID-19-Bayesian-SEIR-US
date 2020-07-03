MCMC ("simMCMC.out","",  # name of output and restart file
      "",                     # name of data file
      200000,0,                 # iterations, print predictions flag,
      100,200000,                 # printing frequency, iters to print
      10101010);              # random seed (default)

Integrate (Lsodes, 1e-8, 1e-10, 1);

Level {
  
  Distrib(GM_NInit, TruncLogNormal, 1000, 10, 1, 10000); # Number of index cases
  Distrib(GM_TIsolation, TruncLogNormal, 14, 2, 7, 21); # Isolation time after contact tracing
  Distrib(GM_R0, TruncNormal, 2.9, 0.78, 1.46, 4.5); # Basic reproductive number
  Distrib(GM_c0, TruncNormal, 13, 5, 7, 20); # Average contacts/day
  Distrib(GM_TLatent, TruncNormal, 4, 1, 2, 7); # Latency
  Distrib(GM_TRecover, TruncLogNormal, 10, 1.5, 5, 30); # Time to recovery (no longer infectious)
  Distrib(GM_IFR, TruncLogNormal, 0.01, 2, 0.001, 0.1); # Infected fatality rate
  Distrib(GM_TStartTesting, TruncNormal, 90, 30, 60, 150); # Time of start of testing
  Distrib(GM_TauTesting, TruncNormal, 7, 3, 1, 14); # Time constant for testing
  Distrib(GM_TTestingRate, TruncNormal, 7, 3, 2, 12);
  Distrib(GM_TContactsTestingRate, TruncNormal, 2, 1, 1, 3); 
  Distrib(GM_TestingCoverage, TruncNormal, 0.5, 0.2, 0.2, 0.8);
  Distrib(GM_TestSensitivity, TruncNormal, 0.7, 0.1, 0.6, 0.95);
  Distrib(GM_ThetaMin, TruncNormal, 0.474, 0.262, 0, 0.805); # Minimum value for social distancing
  Distrib(GM_TauTheta, TruncNormal, 18.5, 2.41, 15.1, 21.4); # Characteristic time for social distancing
  Distrib(GM_PwrTheta, TruncNormal, 4.04, 0.903, 2.52, 5.18); # Power in Weibull model for social distancing
  Distrib(GM_HygienePwr, Beta, 2, 2); # Power in Weibull model for social distancing
  Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced
  
  Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
  Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay
  
  Distrib(GM_TauS, TruncNormal, 30.5, 8.42, 23.9, 49.2);
  Distrib(GM_rMax, TruncNormal, 0.652, 0.177, 0.358, 0.839);
  Distrib(GM_TauR, TruncNormal, 47.4, 7.81, 37.9, 58.6);
  
  Distrib(alpha_Pos, LogUniform, 4, 40);
  Distrib(alpha_Death, LogUniform, 8, 40);
  
  Level {
    
    Likelihood(Data(N_pos), NegativeBinomial, alpha_Pos, Prediction(p_N_pos));
    Likelihood(Data(D_pos), NegativeBinomial, alpha_Death, Prediction(p_D_pos));

    Simulation { # IN 

      Npop = 6732219 ;
      StartTime(60);

      Print(N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 );
      Data(N_pos, 17 23 47 75 58 106 112 168 336 251 282 272 373 406 474 398 516 458 533 563 436 408 556 528 493 308 291 428 587 612 487 569 476 411 341 601 641 715 617 949 627 594 653 795 665 638 574 526 837 633 643 586 394 501 500 346 580 602 625 498 477 450 569 662 473 492 475 339 363 359 631 490 653 363 256 407 475 384 482 419 400 226 410 304 411 398 397 366 521 356 227 425 308 315 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 );
      Print(p_N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 );
      Print(D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 );
      Data(D_pos, 0 0 2 2 1 5 2 3 7 7 1 3 14 16 13 24 14 11 12 34 30 42 55 30 13 7 38 48 41 42 26 17 7 61 31 45 35 44 28 31 57 164 49 61 54 17 18 62 51 37 33 43 18 32 38 41 27 45 50 10 14 59 40 49 28 2 33 0 28 26 38 42 15 9 8 55 10 24 27 34 11 13 23 16 25 16 17 9 11 14 28 16 25 20 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 );
      Print(p_D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 );
      PrintStep( S , 60,  274 , 1);
      PrintStep( S_C , 60,  274 , 1);
      PrintStep( E , 60,  274 , 1);
      PrintStep( E_C , 60,  274 , 1);
      PrintStep( I_U , 60,  274 , 1);
      PrintStep( I_C , 60,  274 , 1);
      PrintStep( I_T , 60,  274 , 1);
      PrintStep( R_U , 60,  274 , 1);
      PrintStep( R_T , 60,  274 , 1);
      PrintStep( F_T , 60,  274 , 1);
      PrintStep( CumInfected , 60,  274 , 1);
      PrintStep( CumPosTest , 60,  274 , 1);
      PrintStep( CumDeath , 60,  274 , 1);
      PrintStep( dtCumInfected , 60,  274 , 1);
      PrintStep( dtCumPosTest , 60,  274 , 1);
      PrintStep( dtCumDeath , 60,  274 , 1);
      PrintStep( Tot , 60,  274 , 1);
      PrintStep( ThetaFit , 60,  274 , 1);
      PrintStep( HygieneFit , 60,  274 , 1);
      PrintStep( c , 60,  274 , 1);
      PrintStep( beta , 60,  274 , 1);
      PrintStep( rho , 60,  274 , 1);
      PrintStep( lambda , 60,  274 , 1);
      PrintStep( delta , 60,  274 , 1);
      PrintStep( Rt , 60,  274 , 1);
      PrintStep( Refft , 60,  274 , 1);

    }
  }
}
