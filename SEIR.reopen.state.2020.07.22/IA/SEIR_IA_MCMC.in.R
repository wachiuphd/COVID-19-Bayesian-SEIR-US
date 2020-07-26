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
  Distrib(GM_T50Testing, TruncNormal, 120, 60, 60, 180); # Time of 50% of final testing rate
  Distrib(GM_TauTesting, TruncNormal, 21, 14, 1, 42); # Time constant for testing
  Distrib(GM_TTestingRate, TruncNormal, 7, 3, 2, 12);
  Distrib(GM_TContactsTestingRate, TruncNormal, 2, 1, 1, 3); 
  Distrib(GM_FAsymp, TruncNormal, 0.295, 0.275, 0.02, 0.57); # Fraction asymptomatic
  Distrib(GM_TestingCoverage, Beta, 2, 2); # Testing coverage
  Distrib(GM_TestSensitivity, TruncNormal, 0.7, 0.1, 0.6, 0.95);
  Distrib(GM_ThetaMin, TruncNormal, 0.506, 0.275, 0, 1); # Minimum value for social distancing
  Distrib(GM_TauTheta, TruncNormal, 18.1, 2.25, 7, 35); # Characteristic time for social distancing
  Distrib(GM_PwrTheta, TruncNormal, 5.32, 2.07, 1, 11); # Power in Weibull model for social distancing
  Distrib(GM_HygienePwr, Beta, 2, 4); # Power in Weibull model for social distancing
  Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced
  
  Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
  Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay
  
  Distrib(GM_TauS, TruncNormal, 34.3, 9.32, 21, 90);
  Distrib(GM_rMax, TruncNormal, 0.667, 0.287, 0, 2);
  Distrib(GM_TauR, TruncNormal, 49.5, 11, 14, 105);
  
  Distrib(alpha_Pos, LogUniform, 0.1, 40);
  Distrib(alpha_Death, LogUniform, 0.1, 40);
  
  Level {
    
    Likelihood(Data(N_pos), NegativeBinomial, alpha_Pos, Prediction(p_N_pos));
    Likelihood(Data(D_pos), NegativeBinomial, alpha_Death, Prediction(p_D_pos));

    Simulation { # IA 

      Npop = 3155070 ;
      StartTime(60);

      Print(N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 );
      Data(N_pos, 9 7 23 22 15 19 21 34 56 63 38 88 73 52 65 85 87 82 78 102 97 125 118 122 77 123 189 96 146 191 181 389 257 482 107 176 521 647 384 392 508 467 302 739 757 528 534 408 293 655 398 214 288 414 539 377 386 374 279 323 304 394 265 556 334 389 359 325 126 657 213 353 318 308 145 319 39 750 347 326 189 320 249 315 387 399 380 209 127 126 282 393 421 221 467 88 322 332 492 489 326 477 293 225 444 758 220 612 312 304 372 480 731 744 663 424 458 320 442 841 590 185 816 443 308 319 -1 -1 -1 );
      Print(p_N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 );
      Print(D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 );
      Data(D_pos, 0 0 0 0 0 0 1 0 2 0 1 2 1 2 2 0 3 8 3 1 1 2 2 3 7 2 6 4 7 4 10 1 4 4 7 6 11 5 6 9 9 12 14 8 5 9 4 19 12 12 12 9 13 6 18 17 12 18 10 5 4 17 16 18 19 19 10 5 19 13 13 18 9 3 17 10 13 6 12 6 6 8 12 6 9 4 7 2 3 14 4 6 2 0 4 1 2 4 3 9 0 1 3 7 2 1 2 1 0 2 2 10 4 4 5 2 4 3 5 16 6 3 7 3 5 6 -1 -1 -1 );
      Print(p_D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 );
      PrintStep( S , 60,  297 , 1);
      PrintStep( S_C , 60,  297 , 1);
      PrintStep( E , 60,  297 , 1);
      PrintStep( E_C , 60,  297 , 1);
      PrintStep( I_U , 60,  297 , 1);
      PrintStep( I_C , 60,  297 , 1);
      PrintStep( I_T , 60,  297 , 1);
      PrintStep( A_U , 60,  297 , 1);
      PrintStep( A_C , 60,  297 , 1);
      PrintStep( R_U , 60,  297 , 1);
      PrintStep( R_T , 60,  297 , 1);
      PrintStep( F_T , 60,  297 , 1);
      PrintStep( CumInfected , 60,  297 , 1);
      PrintStep( CumPosTest , 60,  297 , 1);
      PrintStep( CumDeath , 60,  297 , 1);
      PrintStep( dtCumInfected , 60,  297 , 1);
      PrintStep( dtCumPosTest , 60,  297 , 1);
      PrintStep( dtCumDeath , 60,  297 , 1);
      PrintStep( Tot , 60,  297 , 1);
      PrintStep( ThetaFit , 60,  297 , 1);
      PrintStep( HygieneFit , 60,  297 , 1);
      PrintStep( c , 60,  297 , 1);
      PrintStep( beta , 60,  297 , 1);
      PrintStep( rho , 60,  297 , 1);
      PrintStep( lambda , 60,  297 , 1);
      PrintStep( delta , 60,  297 , 1);
      PrintStep( Rt , 60,  297 , 1);
      PrintStep( Refft , 60,  297 , 1);

    }
  }
}
