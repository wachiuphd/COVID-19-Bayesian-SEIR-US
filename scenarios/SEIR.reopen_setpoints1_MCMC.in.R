SetPoints ("X_outfile", "X_setpoints", 
          X_nRuns, 
          GM_NInit, # Initial number of infected at Start Time
          GM_TIsolation, # Isolation time after contact tracing
          GM_R0, # Reproduction number
          GM_c0, # Contacts/day
          GM_TLatent, # Latency period
          GM_TRecover, # Time to recovery (no longer infectious)
          GM_IFR, # Infected fatality rate
          GM_T50Testing, # Time of 50% of final testing rate
          GM_TauTesting, # Time constant for testing
          GM_TTestingRate, # 1/rate of testing
          GM_TContactsTestingRate, # 1/rate of testing for contacts
          GM_FAsymp, # Fraction asymptomatic
          GM_TestingCoverage, # Coverage of testing
          GM_TestSensitivity, # True positive rate
          GM_ThetaMin, # Minimum value for social distancing
          GM_TauTheta, # Characteristic time for social distancing
          GM_PwrTheta, # Power in Weibull model for social distancing
          GM_HygienePwr, # Relative impact of Hygiene vs. social distancing
          GM_FracTraced, # Fraction traced 
          GM_TPosTest, # Reporting delay
          GM_TFatalDeath, # Delay time for deaths
          GM_TauS, # Days after TauTheta that Reopening starts
          GM_rMax, # Max reopen (1 = contacts/day back to baseline)
          GM_TauR # Days after TauS that max reopening occurs
          );

Integrate (Lsodes, 1e-8, 1e-10, 1);

# Printing setpoints results for a single time point

Simulation { # X_State
  
  Npop = X_Npop ;
  StartTime(60);
  
  # Key Fixed Parameters
  Print(alpha, kappa, rho, lambda0, lambda0_C, rho0_C, beta0, T_Print);
  
  # State Variables
  Print( S, S_C, E, E_C, I_U,I_C,I_T, R_U,R_T,F_T, T_Print);
  
  # Key Time-Varying Parameters
  Print( ThetaFit, HygieneFit, FTraced, lambda, lambda_C, rho_C, delta, c, beta, T_Print);
  Print( Rt, Refft, T_Print);
  
  # Observables (daily and cumulative)
  Print( N_pos, D_pos, CumPosTest, CumDeath, T_Print);
  
}
