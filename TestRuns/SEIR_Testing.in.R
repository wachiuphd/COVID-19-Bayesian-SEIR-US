#-------------------------------------------------------------------------------
# Simulation file.
#-------------------------------------------------------------------------------

Integrate (Lsodes, 1e-4, 1e-6, 1);

Simulation {

  Npop = 29000000;
  StartTime(60);
  PrintStep( S, S_C, E, E_C, I_U, I_C, R_U, I_T, R_T, F_T, 60, 160, 1); # States
  PrintStep( CumInfected, CumPosTest, CumDeath, 60, 160, 1); # Cumulatives
  PrintStep( ThetaFit, HygieneFit, FTraced, lambda, lambda_C, rho_C, delta, c, beta, 60, 160, 1); # Outputs
  PrintStep( Rt, Refft, dtCumInfected, dtCumPosTest, dtCumDeath, N_pos, D_pos, p_N_pos, p_D_pos, Tot, 60, 160, 1); # Outputs
  PrintStep( NInit, TIsolation, R0, c0, TLatent, TRecover, IFR, 60, 160, 1); # Parameters
  PrintStep( T50Testing, TauTesting, TTestingRate, TContactsTestingRate, FAsymp, TestingCoverage, TestSensitivity, ThetaMin, TauTheta, PwrTheta, 60, 160, 1); # Parameters 
  PrintStep( HygienePwr, FTraced0, TPosTest, TFatalDeath, alpha, kappa, rho, lambda0, lambda0_C, rho0_C, 60, 160, 1); # Parameters
  PrintStep( beta0, TauS, rMax, TauR, 60, 160, 1); # Parameters
}

End.
