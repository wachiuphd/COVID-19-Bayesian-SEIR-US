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
Distrib(GM_ThetaMin, TruncNormal, 0.472, 0.259, 0.0019, 0.828); # Minimum value for social distancing
Distrib(GM_TauTheta, TruncNormal, 19.2, 2.41, 15.9, 23.6); # Characteristic time for social distancing
Distrib(GM_PwrTheta, TruncNormal, 3.73, 1.13, 2.01, 5.48); # Power in Weibull model for social distancing
Distrib(GM_HygienePwr, Beta, 2, 2); # Power in Weibull model for social distancing
Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced

Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay

Distrib(GM_TauS, TruncNormal, 26.6, 14.6, 6.51, 54);
Distrib(GM_rMax, TruncNormal, 0.781, 0.274, 0.367, 1.15);
Distrib(GM_TauR, TruncNormal, 47.5, 15.7, 25.7, 75.1);

Distrib(alpha_Pos, LogUniform, 4, 40);
Distrib(alpha_Death, LogUniform, 8, 40);

    Simulation { # MT 

      Npop = 1068778 ;
      StartTime(60);

      Print(NInit, 60.01);
}
