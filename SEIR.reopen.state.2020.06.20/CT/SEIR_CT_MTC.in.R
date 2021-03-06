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
Distrib(GM_T50Testing, Uniform, 61, 106); # Time of 50% of final testing rate (between March 1 and April 15)
Distrib(GM_TauTesting, TruncNormal, 7, 3, 1, 14); # Time constant for testing (1 to 14 days)
Distrib(GM_TTestingRate, TruncNormal, 7, 3, 2, 12);
Distrib(GM_TContactsTestingRate, TruncNormal, 2, 1, 1, 3); 
Distrib(GM_FAsymp, TruncNormal, 0.295, 0.275, 0.02, 0.57); # Fraction asymptomatic
Distrib(GM_TestingCoverage, Beta, 2, 2); # Testing coverage
Distrib(GM_TestSensitivity, TruncNormal, 0.7, 0.1, 0.6, 0.95);
Distrib(GM_ThetaMin, TruncNormal, 0.408, 0.239, 0, 1); # Minimum value for social distancing
Distrib(GM_TauTheta, TruncNormal, 17.2, 1.48, 7, 35); # Characteristic time for social distancing
Distrib(GM_PwrTheta, TruncNormal, 3.97, 0.913, 1, 11); # Power in Weibull model for social distancing
Distrib(GM_HygienePwr, Beta, 2, 4); # Power in Weibull model for social distancing
Distrib(GM_FracTraced, TruncLogNormal, 0.25, 2, 0.05, 1); # Fraction traced

Distrib(GM_TPosTest, TruncLogNormal, 7, 2, 1, 14); # Reporting delay
Distrib(GM_TFatalDeath, TruncLogNormal, 7, 2, 1, 14); # Time from fatal illness to death + reporting delay

Distrib(GM_TauS, TruncNormal, 36.5, 9.67, 21, 90);
Distrib(GM_rMax, TruncNormal, 0.46, 0.146, 0, 2);
Distrib(GM_TauR, TruncNormal, 47, 10.2, 14, 105);

Distrib(alpha_Pos, LogUniform, 0.1, 40);
Distrib(alpha_Death, LogUniform, 0.1, 40);

    Simulation { # CT 

      Npop = 3565287 ;
      StartTime(60);

      Print(NInit, 60.01);
}
