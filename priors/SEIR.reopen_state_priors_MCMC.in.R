MCMC ("simMCMC.out","",  # name of output and restart file
      "",                     # name of data file
      X_iter,0,                 # iterations, print predictions flag,
      X_print,X_iter,                 # printing frequency, iters to print
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
  Distrib(GM_ThetaMin, TruncNormal, X_M_ThetaMin, X_SD_ThetaMin, X_MIN_ThetaMin, X_MAX_ThetaMin); # Minimum value for social distancing
  Distrib(GM_TauTheta, TruncNormal, X_M_TauTheta, X_SD_TauTheta, X_MIN_TauTheta, X_MAX_TauTheta); # Characteristic time for social distancing
  Distrib(GM_PwrTheta, TruncNormal, X_M_PwrTheta, X_SD_PwrTheta, X_MIN_PwrTheta, X_MAX_PwrTheta); # Power in Weibull model for social distancing
  Distrib(GM_HygienePwr, Beta, 2, 2); # Power in Weibull model for social distancing
  Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced
  
  Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
  Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay
  
  Distrib(GM_TauS, TruncNormal, X_M_TauS, X_SD_TauS, X_MIN_TauS, X_MAX_TauS);
  Distrib(GM_rMax, TruncNormal, X_M_rMax, X_SD_rMax, X_MIN_rMax, X_MAX_rMax);
  Distrib(GM_TauR, TruncNormal, X_M_TauR, X_SD_TauR, X_MIN_TauR, X_MAX_TauR);
  
  Distrib(alpha_Pos, LogUniform, 4, 40);
  Distrib(alpha_Death, LogUniform, 8, 40);
  
  Level {
    
    Likelihood(Data(N_pos), NegativeBinomial, alpha_Pos, Prediction(p_N_pos));
    Likelihood(Data(D_pos), NegativeBinomial, alpha_Death, Prediction(p_D_pos));

