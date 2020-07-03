# Description ####
# SEIR Model with separate tested/untested compartments
# Added social distancing to mitigate Transmission
# Calibration prediction is the daily increases, with time delays
# Negative binomial likelihood
# Including contact tracing/isolation
# Reopening model - assuming constant testing/tracing

States = {
  S, # Susceptible
  S_C, # Suspectible, contact traced/isolated
  E, # Exposed (not infectious)
  E_C, # Exposed (not infectious), contact traced/isolated
  I_U, # Infected, untested
  I_C, # Infected, untested, contact traced/isolated
  R_U, # Recovered, untested
  I_T, # Infected, tested
  R_T, # Recovered, tested
  F_T, # Fatal illness, tested
  CumInfected, # Cumulative infected
  CPosTest_U, # Cumulative observed positive test results
  CPosTest_C # Cumulative observed positive test results
};

# Inputs = {
#   ThetaInput,
#   TestRateScaleInput,
#   RelaxRestrFracInput
# }

Outputs = { 
  ### Dynamic outputs
  ThetaFit,
  HygieneFit,
  FTraced,
  lambda,
  lambda_C,
  rho_C,
  delta,
  c,
  beta,
  Rt,
  Refft,
  dtCumInfected,
  dtCumPosTest,
  dtCumDeath,
  CumPosTest, # Cumulative observed positive test results observed
  CumDeath, # Cumulative observed deaths
  N_pos, # Number of observed positive tests increased/day
  D_pos, # Number of observed dead with positive tests increased/day (with delay)
  p_N_pos, # p for negative binomial for N_pos
  p_D_pos, # p for negative binomial for D_pos
  Tot # Total - for mass balance
};

## Global parameters (initially set to zero unless assigned here)
# Number total in population at t=StartTime
Npop = 1e5; # only used for calculating observables and initialization

# Individual parameters, to be initialized
NInit;
TIsolation;
R0;
c0;
TLatent;
TRecover;
IFR;
TStartTesting;
TauTesting;
TTestingRate;
TContactsTestingRate;
TestingCoverage;
TestSensitivity;
ThetaMin;
TauTheta;
PwrTheta;
HygienePwr;
FTraced0;
TPosTest;
TFatalDeath;
alpha;
kappa;
rho;
lambda0;
lambda0_C;
rho0_C;
beta0;
TauS;
rMax; # Max reopen (1 = contacts/day back to baseline)
TauR; # Rate at which reopening occurs (fraction of return to baseline per day)

# Shape parameters for Negative Binomial
alpha_Pos = 4;
alpha_Death = 4;

# Sampling parameters
GM_NInit = 1000; # Initial number of infected at Start Time
GM_TIsolation = 14; # Isolation time after contact tracing
GM_R0 = 4; # Reproduction number
GM_c0 = 13; # Contacts/day
GM_TLatent = 4; # Latency period
GM_TRecover = 10; # Time to recovery (no longer infectious)
GM_IFR = 0.01; # Infected fatality rate
GM_TStartTesting = 70; # Time of start of testing
GM_TauTesting = 3;
GM_TTestingRate = 7; # 1/rate of testing
GM_TContactsTestingRate = 2; # 1/rate of testing for contacts
GM_TestingCoverage = 0.5; # Coverage of testing
GM_TestSensitivity = 0.7; # True positive rate
GM_ThetaMin = 0.44; # Minimum value for social distancing
GM_TauTheta = 18; # Characteristic time for social distancing
GM_PwrTheta = 4.4; # Power in Weibull model for social distancing
GM_HygienePwr = 0.25; # Relative impact of Hygiene vs. social distancing
GM_FracTraced = 0.1; # Fraction traced
GM_TPosTest = 3; # Delay time for positive tests (from I_U only)
GM_TFatalDeath = 3; # Delay time for deaths
GM_TauS = 33; # Days after TauTheta that Reopening starts
GM_rMax = 0.53; # Max reopen (1 = contacts/day back to baseline)
GM_TauR = 44; # Duration of linear ramp-up of reopening

SD_NInit; # Initial number of infected at Start Time
SD_TIsolation; # Isolation time after contact tracing
SD_R0; # Reproduction number
SD_c0; # Contacts/day
SD_TLatent; # Latency period
SD_TRecover; # Time to recovery (no longer infectious)
SD_IFR; # Infected fatality rate
SD_TStartTesting; # Time of start of testing
SD_TauTesting;
SD_TTestingRate; # 1/rate of testing
SD_TContactsTestingRate; # 1/rate of testing for contacts
SD_TestingCoverage; # Coverage of testing
SD_TestSensitivity; # True positive rate
SD_ThetaMin; # Minimum value for social distancing
SD_TauTheta; # Characteristic time for social distancing
SD_PwrTheta; # Power in Weibull model for social distancing
SD_HygienePwr; # Relative impact of Hygiene vs. social distancing
SD_FracTraced; # Fraction traced 
SD_TPosTest; # Delay time for positive tests (from I_U only)
SD_TFatalDeath; # Delay time for deaths
SD_TauS; # Days after TauTheta that Reopening starts
SD_rMax; # Max reopen (1 = contacts/day back to baseline)
SD_TauR; # Duration of linear ramp-up of reopening

z_NInit; # Initial number of infected at Start Time
z_TIsolation; # Isolation time after contact tracing
z_R0; # Reproduction number
z_c0; # Contacts/day
z_TLatent; # Latency period
z_TRecover; # Time to recovery (no longer infectious)
z_IFR; # Infected fatality rate
z_TStartTesting; # Time of start of testing
z_TauTesting;
z_TTestingRate; # 1/rate of testing
z_TContactsTestingRate; # 1/rate of testing for contacts
z_TestingCoverage; # Coverage of testing
z_TestSensitivity; # True positive rate
z_ThetaMin; # Minimum value for social distancing
z_TauTheta; # Characteristic time for social distancing
z_PwrTheta; # Power in Weibull model for social distancing
z_HygienePwr; # Relative impact of Hygiene vs. social distancing
z_FracTraced; # Fraction traced 
z_TPosTest; # Delay time for positive tests (from I_U only)
z_TFatalDeath; # Delay time for deaths
z_TauS; # Days after TauTheta that Reopening starts
z_rMax; # Max reopen (1 = contacts/day back to baseline)
z_TauR; # Duration of linear ramp-up of reopening

Initialize {
  # Scaling parameters
  ## Initialization
  NInit = GM_NInit * exp(SD_NInit * z_NInit);
  ## Isolation
  TIsolation = GM_TIsolation * exp(SD_TIsolation  * z_TIsolation);
  ## Transmission
  R0 = GM_R0 * exp(SD_R0 * z_R0);
  c0 = GM_c0 * exp(SD_c0 * z_c0);
  ## Latency
  TLatent = GM_TLatent * exp(SD_TLatent * z_TLatent);
  ## Recovery
  TRecover = GM_TRecover * exp(SD_TRecover  * z_TRecover);
  ## Fatality
  IFR = GM_IFR * exp(SD_IFR  * z_IFR);
  ## Testing
  TStartTesting = GM_TStartTesting * exp(SD_TStartTesting  * z_TStartTesting);
  TauTesting = GM_TauTesting * exp(SD_TauTesting  * z_TauTesting);
  TTestingRate = GM_TTestingRate * exp(SD_TTestingRate  * z_TTestingRate);
  TContactsTestingRate = GM_TContactsTestingRate * exp(SD_TContactsTestingRate  * z_TContactsTestingRate);
  TestingCoverage = GM_TestingCoverage * exp(SD_TestingCoverage  * z_TestingCoverage);
  TestSensitivity = GM_TestSensitivity * exp(SD_TestSensitivity  * z_TestSensitivity);
  # Social distancing and hygiene
  ThetaMin = GM_ThetaMin * exp(SD_ThetaMin  * z_ThetaMin); 
  TauTheta = GM_TauTheta * exp(SD_TauTheta  * z_TauTheta); 
  PwrTheta = GM_PwrTheta * exp(SD_PwrTheta  * z_PwrTheta); 
  HygienePwr = GM_HygienePwr * exp(SD_HygienePwr  * z_HygienePwr); 
  # Contact tracing
  FTraced0 = GM_FracTraced * exp(SD_FracTraced  * z_FracTraced);
  # Observation delays
  TPosTest = GM_TPosTest * exp(SD_TPosTest  * z_TPosTest); 
  TFatalDeath = GM_TFatalDeath * exp(SD_TFatalDeath  * z_TFatalDeath); 
  # Actual parameters used in ODEs
  alpha = 1/TIsolation;
  kappa = 1/TLatent;
  rho = 1/TRecover;
  lambda0 = TestingCoverage*TestSensitivity/TTestingRate;
  lambda0_C = 1.0*TestSensitivity/TContactsTestingRate;
  rho0_C = 1.0*(1.0 - TestSensitivity)/TContactsTestingRate;
  beta0 = R0 * rho / c0;
  # State parameter initialization
  S = 1;
  I_U = NInit/Npop;  
  # Reopening
  TauS = GM_TauS * exp(SD_TauS  * z_TauS); 
  rMax = GM_rMax * exp(SD_rMax  * z_rMax); 
  TauR = GM_TauR * exp(SD_TauR  * z_TauR); 
  
}

Dynamics { # ODEs
  # Dynamic parameters
  ## Social distancing - reduce contacts/day
  ThetaFit = (ThetaMin - (ThetaMin - 1)*exp(-pow((t-60)/TauTheta,PwrTheta)));
  ## Reopening - increase contacts/day
  TimeReopen = 60+TauTheta+TauS;
  ReopenStart = (1 - 1/(1 + exp(4*(t - TimeReopen))));
  ReopenStop =  (1 - 1/(1 + exp(4*(t - (TimeReopen+TauR)))));
  ReopenFit = (t - TimeReopen)*(rMax/TauR)*(ReopenStart-ReopenStop)+rMax*ReopenStop;
  ## Contacts/day
  c = c0 * (ThetaFit + (1 - ThetaMin) * ReopenFit); 
  ## Hygiene - reduce infection probability/infected contact
  HygieneFit = pow(ThetaFit, HygienePwr);
  beta = beta0 * HygieneFit; # infection probability/infected contact
  ## Time dependence of testing/contact tracting
  TestingTimeDep = (1-1/(1+exp((t-TStartTesting)/TauTesting))); 
  ## Contact tracing
  FTraced = FTraced0 * TestingTimeDep;
  ## Testing
  lambda = TestingTimeDep * lambda0; 
  lambda_C = TestingTimeDep * lambda0_C; 
  rho_C = TestingTimeDep * rho0_C;
  fracpos = FTraced*lambda_C/(lambda_C + rho_C)+(1-FTraced)*lambda/(lambda+rho); # fraction of infected that are tested and positive
  ## Case fatality
  fracposmin = IFR / 0.9; # max 90% of cases fatal
  CFR = (fracpos > fracposmin) ? IFR/fracpos : 0.9; # Adjust infected fatality to (tested) case fatality
  delta = rho * CFR/(1-CFR);
  # Susceptibles
  dt(S) = -S * c * I_U * (beta + (1 - beta) * FTraced) + S_C * alpha;
  dt(S_C) = -S_C * alpha + S * c * I_U * (1 - beta) * FTraced;
  # Exposed
  dt(E) = -E * kappa + S * c * I_U * beta * (1 - FTraced);
  dt(E_C) = -E_C * kappa + S * c * I_U * beta * FTraced;
  # Infected, not tested
  dt(I_U) = -I_U * (lambda + rho) + E * kappa;
  dt(I_C) = -I_C * (lambda_C + rho_C) + E_C * kappa;
  # Recovered, not tested
  dt(R_U) = I_U * rho + I_C * rho_C;
  # Infected, tested
  dt(I_T) = -I_T * (rho + delta) + I_U * lambda + I_C * lambda_C;
  # Recovered, tested
  dt(R_T) = I_T * rho;
  # Fatally ill, tested
  dt(F_T) = I_T * delta;
  # Cumulative infected
  dt(CumInfected) = (E + E_C) * kappa;
  # Cumulative positive tests
  dt(CPosTest_U) = I_U * lambda;
  dt(CPosTest_C) = I_C * lambda_C;
}

CalcOutputs {
  ## Social distancing - reduce contacts/day
  ThetaFit = (ThetaMin - (ThetaMin - 1)*exp(-pow((t-60)/TauTheta,PwrTheta)));
  ## Reopening - increase contacts/day
  TimeReopen = 60+TauTheta+TauS;
  ReopenStart = (1 - 1/(1 + exp(4*(t - TimeReopen))));
  ReopenStop =  (1 - 1/(1 + exp(4*(t - (TimeReopen+TauR)))));
  ReopenFit = (t - TimeReopen)*(rMax/TauR)*(ReopenStart-ReopenStop)+rMax*ReopenStop;
  ## Contacts/day
  c = c0 * (ThetaFit + (1 - ThetaMin) * ReopenFit); 
  ## Hygiene - reduce infection probability/infected contact
  HygieneFit = pow(ThetaFit, HygienePwr);
  beta = beta0 * HygieneFit; # infection probability/infected contact
  ## Time dependence of testing/contact tracting
  TestingTimeDep = (1-1/(1+exp((t-TStartTesting)/TauTesting))); 
  ## Contact tracing
  FTraced = FTraced0 * TestingTimeDep;
  ## Testing
  lambda = TestingTimeDep * lambda0; 
  lambda_C = TestingTimeDep * lambda0_C; 
  rho_C = TestingTimeDep * rho0_C;
  fracpos = FTraced*lambda_C/(lambda_C + rho_C)+(1-FTraced)*lambda/(lambda+rho); # fraction of infected that are tested and positive
  ## Case fatality
  fracposmin = IFR / 0.9; # max 90% of cases fatal
  CFR = (fracpos > fracposmin) ? IFR/fracpos : 0.9; # Adjust infected fatality to (tested) case fatality
  delta = rho * CFR/(1-CFR);
  ## Rt  
  Rt = c * beta * (1 - FTraced) / (rho + lambda);
  ## Refft - including herd immunity/contact isolation term
  Refft = S * Rt; 
  ## differentials
  dtCumInfected = (E + E_C) * kappa;
  # Cumulative positive tests observed
  TeffPosTest = t - 60 - TPosTest;
  dtCumPosTest = ((TeffPosTest > 0) ? (CalcDelay(I_U, TPosTest) * lambda) : 0) + I_C * lambda_C;
  CumPosTest = ((TeffPosTest > 0) ? CalcDelay(CPosTest_U, TPosTest) : 0) + CPosTest_C;
  # Deaths reported, tested
  TeffDeath = t - 60 - TFatalDeath;
  dtCumDeath = (TeffDeath > 0) ? (CalcDelay(I_T, TFatalDeath) * delta) : 0;
  CumDeath = (TeffDeath > 0) ? CalcDelay(F_T, TFatalDeath) : 0;
  # Observables - daily numbers rather than fractions
  N_pos = ((dtCumPosTest*Npop) > 1e-15) ? (dtCumPosTest*Npop) : 1e-15;
  D_pos = ((dtCumDeath*Npop) > 1e-15) ? (dtCumDeath*Npop) : 1e-15;
  # Negative binomial p parameter = lambda/(alpha+lambda)
  p_N_pos = N_pos/(alpha_Pos+N_pos);
  p_D_pos = D_pos/(alpha_Death+D_pos);
  # Mass balance
  Tot = S + S_C + E + E_C + I_U + I_C + R_U + I_T + R_T + F_T;
}

End.
