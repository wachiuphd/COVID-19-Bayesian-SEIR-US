MonteCarlo("simMTC0.out", 
           5000,  # iterations
           10101010);              # random seed (default)

Integrate (Lsodes, 1e-8, 1e-10, 1);

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
Distrib(GM_ThetaMin, TruncNormal, 0.462, 0.25, 0.00315, 0.807); # Minimum value for social distancing
Distrib(GM_TauTheta, TruncNormal, 18.8, 2.19, 15.5, 21.4); # Characteristic time for social distancing
Distrib(GM_PwrTheta, TruncNormal, 4.47, 1.4, 2.84, 7.34); # Power in Weibull model for social distancing
Distrib(GM_HygienePwr, Beta, 2, 2); # Power in Weibull model for social distancing
Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced

Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay

Distrib(GM_TauS, TruncNormal, 29.3, 8.8, 21, 46.1);
Distrib(GM_rMax, TruncNormal, 0.473, 0.183, 0.246, 0.749);
Distrib(GM_TauR, TruncNormal, 39.2, 11.9, 27.6, 60);

Distrib(alpha_Pos, LogUniform, 4, 40);
Distrib(alpha_Death, LogUniform, 8, 40);

    Simulation { # GA 

      Npop = 10617423 ;
      StartTime(60);

      Print(NInit, 60.01);
}
