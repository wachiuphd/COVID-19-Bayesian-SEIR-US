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
  Distrib(GM_T50Testing, Uniform, 61, 106); # Time of 50% of final testing rate (between March 1 and April 15)
  Distrib(GM_TauTesting, TruncNormal, 7, 3, 1, 14); # Time constant for testing (1 to 14 days)
  Distrib(GM_TTestingRate, TruncNormal, 7, 3, 2, 12);
  Distrib(GM_TContactsTestingRate, TruncNormal, 2, 1, 1, 3); 
  Distrib(GM_FAsymp, TruncNormal, 0.295, 0.275, 0.02, 0.57); # Fraction asymptomatic
  Distrib(GM_TestingCoverage, Beta, 2, 2); # Testing coverage
  Distrib(GM_TestSensitivity, TruncNormal, 0.7, 0.1, 0.6, 0.95);
  Distrib(GM_ThetaMin, TruncNormal, 0.458, 0.261, 0, 1); # Minimum value for social distancing
  Distrib(GM_TauTheta, TruncNormal, 18.8, 1.49, 7, 35); # Characteristic time for social distancing
  Distrib(GM_PwrTheta, TruncNormal, 4.3, 1.81, 1, 11); # Power in Weibull model for social distancing
  Distrib(GM_HygienePwr, Beta, 2, 4); # Power in Weibull model for social distancing
  Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced
  
  Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
  Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay
  
  Distrib(GM_TauS, TruncNormal, 34.4, 7.97, 21, 90);
  Distrib(GM_rMax, TruncNormal, 0.342, 0.124, 0, 2);
  Distrib(GM_TauR, TruncNormal, 27.6, 7.2, 14, 105);
  
  Distrib(alpha_Pos, LogUniform, 0.1, 40);
  Distrib(alpha_Death, LogUniform, 0.1, 40);
  
  Level {
    
    Likelihood(Data(N_pos), NegativeBinomial, alpha_Pos, Prediction(p_N_pos));
    Likelihood(Data(D_pos), NegativeBinomial, alpha_Death, Prediction(p_D_pos));

    Simulation { # AZ 

      Npop = 7278717 ;
      StartTime(60);

      Print(N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Data(N_pos, 16 21 39 48 113 92 93 127 159 137 46 238 132 124 185 171 250 250 187 119 151 292 94 281 146 163 104 156 272 273 212 210 135 187 208 310 276 235 246 190 232 254 446 314 402 276 279 386 402 238 581 434 159 261 356 440 498 495 462 306 233 396 331 418 293 431 300 222 222 479 501 702 790 681 187 1127 983 520 1579 1119 1438 789 618 1556 1412 1654 1540 1233 1014 2392 1827 2519 3246 3109 2592 2196 3593 1795 3056 3518 3503 3857 625 4682 4877 3333 4433 2695 3536 3352 3653 3520 4057 4221 3038 2537 1357 4273 3257 3259 3910 2742 2359 1559 3500 1926 -1 -1 -1 -1 );
      Print(p_N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Print(D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Data(D_pos, 0 0 1 1 0 3 1 2 5 2 2 3 4 5 3 9 11 12 1 8 7 9 8 11 7 7 9 11 8 19 8 7 3 21 21 20 17 0 9 0 18 11 16 10 18 14 0 33 31 24 67 15 4 6 20 32 30 27 28 1 6 18 43 16 12 24 1 6 1 24 26 28 18 3 11 24 40 15 16 30 2 3 23 25 32 17 39 3 8 25 20 32 41 26 1 3 42 79 27 45 44 9 0 44 88 37 31 17 4 1 117 36 75 44 69 86 8 92 97 58 91 147 31 23 134 56 -1 -1 -1 -1 );
      Print(p_D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      PrintStep( S , 60,  298 , 1);
      PrintStep( S_C , 60,  298 , 1);
      PrintStep( E , 60,  298 , 1);
      PrintStep( E_C , 60,  298 , 1);
      PrintStep( I_U , 60,  298 , 1);
      PrintStep( I_C , 60,  298 , 1);
      PrintStep( I_T , 60,  298 , 1);
      PrintStep( A_U , 60,  298 , 1);
      PrintStep( A_C , 60,  298 , 1);
      PrintStep( R_U , 60,  298 , 1);
      PrintStep( R_T , 60,  298 , 1);
      PrintStep( F_T , 60,  298 , 1);
      PrintStep( CumInfected , 60,  298 , 1);
      PrintStep( CumPosTest , 60,  298 , 1);
      PrintStep( CumDeath , 60,  298 , 1);
      PrintStep( dtCumInfected , 60,  298 , 1);
      PrintStep( dtCumPosTest , 60,  298 , 1);
      PrintStep( dtCumDeath , 60,  298 , 1);
      PrintStep( Tot , 60,  298 , 1);
      PrintStep( ThetaFit , 60,  298 , 1);
      PrintStep( HygieneFit , 60,  298 , 1);
      PrintStep( c , 60,  298 , 1);
      PrintStep( beta , 60,  298 , 1);
      PrintStep( rho , 60,  298 , 1);
      PrintStep( lambda , 60,  298 , 1);
      PrintStep( delta , 60,  298 , 1);
      PrintStep( Rt , 60,  298 , 1);
      PrintStep( Refft , 60,  298 , 1);

    }
  }
}
