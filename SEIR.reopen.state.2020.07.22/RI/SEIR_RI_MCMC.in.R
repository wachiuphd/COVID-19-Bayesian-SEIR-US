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
  Distrib(GM_ThetaMin, TruncNormal, 0.401, 0.242, 0, 1); # Minimum value for social distancing
  Distrib(GM_TauTheta, TruncNormal, 17.4, 1.69, 7, 35); # Characteristic time for social distancing
  Distrib(GM_PwrTheta, TruncNormal, 3.91, 0.954, 1, 11); # Power in Weibull model for social distancing
  Distrib(GM_HygienePwr, Beta, 2, 4); # Power in Weibull model for social distancing
  Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced
  
  Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
  Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay
  
  Distrib(GM_TauS, TruncNormal, 37.7, 10.1, 21, 90);
  Distrib(GM_rMax, TruncNormal, 0.634, 0.257, 0, 2);
  Distrib(GM_TauR, TruncNormal, 53.5, 12.6, 14, 105);
  
  Distrib(alpha_Pos, LogUniform, 0.1, 40);
  Distrib(alpha_Death, LogUniform, 0.1, 40);
  
  Level {
    
    Likelihood(Data(N_pos), NegativeBinomial, alpha_Pos, Prediction(p_N_pos));
    Likelihood(Data(D_pos), NegativeBinomial, alpha_Death, Prediction(p_D_pos));

    Simulation { # RI 

      Npop = 1059361 ;
      StartTime(60);

      Print(N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Data(N_pos, 17 13 14 25 16 19 28 41 31 64 105 78 73 100 62 101 137 182 206 261 273 279 404 280 289 187 267 307 392 290 283 339 378 387 382 419 415 305 276 203 324 372 348 317 189 181 291 303 342 271 231 286 186 175 219 196 228 232 252 125 137 215 187 169 201 108 84 70 154 133 132 178 104 76 99 107 105 117 105 68 49 45 68 104 87 81 49 32 76 52 51 71 59 36 27 59 77 51 45 69 36 22 36 40 65 59 22 27 24 55 41 0 39 69 0 0 175 101 52 71 82 0 0 111 82 76 -1 -1 -1 -1 );
      Print(p_N_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Print(D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
      Data(D_pos, 0 0 0 0 0 0 0 0 0 0 3 1 4 2 2 2 3 8 2 3 5 8 6 7 7 10 7 7 18 13 32 14 11 11 15 12 13 11 7 6 12 15 13 17 24 21 14 15 18 11 19 4 8 14 18 6 11 10 10 7 26 6 18 23 18 11 0 26 21 22 16 18 7 2 12 10 14 16 0 0 27 9 4 11 10 0 0 18 14 11 9 9 0 0 9 3 6 8 7 0 0 19 4 6 3 1 0 0 0 9 2 3 2 0 0 8 1 2 1 2 0 0 5 1 1 -1 -1 -1 -1 );
      Print(p_D_pos, 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 );
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
