/* model/SEIR.scenarios.model.R.c
   ___________________________________________________

   Model File:  model/SEIR.scenarios.model.R

   Date:  Wed Jul 22 23:17:55 2020

   Created by:  "MCSim/mod.exe v6.1.0"
    -- a model preprocessor by Don Maszle
   ___________________________________________________

   Copyright (c) 1993-2019 Free Software Foundation, Inc.

   Model calculations for compartmental model:

   13 States:
     S -> 0.0;
     S_C -> 0.0;
     E -> 0.0;
     E_C -> 0.0;
     I_U -> 0.0;
     I_C -> 0.0;
     R_U -> 0.0;
     I_T -> 0.0;
     R_T -> 0.0;
     F_T -> 0.0;
     CumInfected -> 0.0;
     CPosTest_U -> 0.0;
     CPosTest_C -> 0.0;

   21 Outputs:
     ThetaFit -> 0.0;
     HygieneFit -> 0.0;
     FTraced -> 0.0;
     lambda -> 0.0;
     lambda_C -> 0.0;
     rho_C -> 0.0;
     delta -> 0.0;
     c -> 0.0;
     beta -> 0.0;
     Rt -> 0.0;
     Refft -> 0.0;
     dtCumInfected -> 0.0;
     dtCumPosTest -> 0.0;
     dtCumDeath -> 0.0;
     CumPosTest -> 0.0;
     CumDeath -> 0.0;
     N_pos -> 0.0;
     D_pos -> 0.0;
     p_N_pos -> 0.0;
     p_D_pos -> 0.0;
     Tot -> 0.0;

   3 Inputs:
     MuLambda (is a function)
     MuC (is a function)
     DeltaDelta (is a function)

   102 Parameters:
     Npop = 1e5;
     NInit = 0;
     TIsolation = 0;
     R0 = 0;
     c0 = 0;
     TLatent = 0;
     TRecover = 0;
     IFR = 0;
     TStartTesting = 0;
     TauTesting = 0;
     TTestingRate = 0;
     TContactsTestingRate = 0;
     TestingCoverage = 0;
     TestSensitivity = 0;
     ThetaMin = 0;
     TauTheta = 0;
     PwrTheta = 0;
     HygienePwr = 0;
     FTraced0 = 0;
     TPosTest = 0;
     TFatalDeath = 0;
     alpha = 0;
     kappa = 0;
     rho = 0;
     lambda0 = 0;
     lambda0_C = 0;
     rho0_C = 0;
     beta0 = 0;
     TauS = 0;
     rMax = 0;
     TauR = 0;
     alpha_Pos = 4;
     alpha_Death = 4;
     GM_NInit = 1000;
     GM_TIsolation = 14;
     GM_R0 = 4;
     GM_c0 = 13;
     GM_TLatent = 4;
     GM_TRecover = 10;
     GM_IFR = 0.01;
     GM_TStartTesting = 70;
     GM_TauTesting = 3;
     GM_TTestingRate = 7;
     GM_TContactsTestingRate = 2;
     GM_TestingCoverage = 0.5;
     GM_TestSensitivity = 0.7;
     GM_ThetaMin = 0.44;
     GM_TauTheta = 18;
     GM_PwrTheta = 4.4;
     GM_HygienePwr = 0.25;
     GM_FracTraced = 0.1;
     GM_TPosTest = 3;
     GM_TFatalDeath = 3;
     GM_TauS = 33;
     GM_rMax = 0.53;
     GM_TauR = 44;
     SD_NInit = 0;
     SD_TIsolation = 0;
     SD_R0 = 0;
     SD_c0 = 0;
     SD_TLatent = 0;
     SD_TRecover = 0;
     SD_IFR = 0;
     SD_TStartTesting = 0;
     SD_TauTesting = 0;
     SD_TTestingRate = 0;
     SD_TContactsTestingRate = 0;
     SD_TestingCoverage = 0;
     SD_TestSensitivity = 0;
     SD_ThetaMin = 0;
     SD_TauTheta = 0;
     SD_PwrTheta = 0;
     SD_HygienePwr = 0;
     SD_FracTraced = 0;
     SD_TPosTest = 0;
     SD_TFatalDeath = 0;
     SD_TauS = 0;
     SD_rMax = 0;
     SD_TauR = 0;
     z_NInit = 0;
     z_TIsolation = 0;
     z_R0 = 0;
     z_c0 = 0;
     z_TLatent = 0;
     z_TRecover = 0;
     z_IFR = 0;
     z_TStartTesting = 0;
     z_TauTesting = 0;
     z_TTestingRate = 0;
     z_TContactsTestingRate = 0;
     z_TestingCoverage = 0;
     z_TestSensitivity = 0;
     z_ThetaMin = 0;
     z_TauTheta = 0;
     z_PwrTheta = 0;
     z_HygienePwr = 0;
     z_FracTraced = 0;
     z_TPosTest = 0;
     z_TFatalDeath = 0;
     z_TauS = 0;
     z_rMax = 0;
     z_TauR = 0;
*/


#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <float.h>
#include "modelu.h"
#include "random.h"
#include "yourcode.h"


/*----- Indices to Global Variables */

/* Model variables: States and other outputs */
#define ID_S 0x00000
#define ID_S_C 0x00001
#define ID_E 0x00002
#define ID_E_C 0x00003
#define ID_I_U 0x00004
#define ID_I_C 0x00005
#define ID_R_U 0x00006
#define ID_I_T 0x00007
#define ID_R_T 0x00008
#define ID_F_T 0x00009
#define ID_CumInfected 0x0000a
#define ID_CPosTest_U 0x0000b
#define ID_CPosTest_C 0x0000c
#define ID_ThetaFit 0x0000d
#define ID_HygieneFit 0x0000e
#define ID_FTraced 0x0000f
#define ID_lambda 0x00010
#define ID_lambda_C 0x00011
#define ID_rho_C 0x00012
#define ID_delta 0x00013
#define ID_c 0x00014
#define ID_beta 0x00015
#define ID_Rt 0x00016
#define ID_Refft 0x00017
#define ID_dtCumInfected 0x00018
#define ID_dtCumPosTest 0x00019
#define ID_dtCumDeath 0x0001a
#define ID_CumPosTest 0x0001b
#define ID_CumDeath 0x0001c
#define ID_N_pos 0x0001d
#define ID_D_pos 0x0001e
#define ID_p_N_pos 0x0001f
#define ID_p_D_pos 0x00020
#define ID_Tot 0x00021

/* Inputs */
#define ID_MuLambda 0x00000
#define ID_MuC 0x00001
#define ID_DeltaDelta 0x00002

/* Parameters */
#define ID_Npop 0x00025
#define ID_NInit 0x00026
#define ID_TIsolation 0x00027
#define ID_R0 0x00028
#define ID_c0 0x00029
#define ID_TLatent 0x0002a
#define ID_TRecover 0x0002b
#define ID_IFR 0x0002c
#define ID_TStartTesting 0x0002d
#define ID_TauTesting 0x0002e
#define ID_TTestingRate 0x0002f
#define ID_TContactsTestingRate 0x00030
#define ID_TestingCoverage 0x00031
#define ID_TestSensitivity 0x00032
#define ID_ThetaMin 0x00033
#define ID_TauTheta 0x00034
#define ID_PwrTheta 0x00035
#define ID_HygienePwr 0x00036
#define ID_FTraced0 0x00037
#define ID_TPosTest 0x00038
#define ID_TFatalDeath 0x00039
#define ID_alpha 0x0003a
#define ID_kappa 0x0003b
#define ID_rho 0x0003c
#define ID_lambda0 0x0003d
#define ID_lambda0_C 0x0003e
#define ID_rho0_C 0x0003f
#define ID_beta0 0x00040
#define ID_TauS 0x00041
#define ID_rMax 0x00042
#define ID_TauR 0x00043
#define ID_alpha_Pos 0x00044
#define ID_alpha_Death 0x00045
#define ID_GM_NInit 0x00046
#define ID_GM_TIsolation 0x00047
#define ID_GM_R0 0x00048
#define ID_GM_c0 0x00049
#define ID_GM_TLatent 0x0004a
#define ID_GM_TRecover 0x0004b
#define ID_GM_IFR 0x0004c
#define ID_GM_TStartTesting 0x0004d
#define ID_GM_TauTesting 0x0004e
#define ID_GM_TTestingRate 0x0004f
#define ID_GM_TContactsTestingRate 0x00050
#define ID_GM_TestingCoverage 0x00051
#define ID_GM_TestSensitivity 0x00052
#define ID_GM_ThetaMin 0x00053
#define ID_GM_TauTheta 0x00054
#define ID_GM_PwrTheta 0x00055
#define ID_GM_HygienePwr 0x00056
#define ID_GM_FracTraced 0x00057
#define ID_GM_TPosTest 0x00058
#define ID_GM_TFatalDeath 0x00059
#define ID_GM_TauS 0x0005a
#define ID_GM_rMax 0x0005b
#define ID_GM_TauR 0x0005c
#define ID_SD_NInit 0x0005d
#define ID_SD_TIsolation 0x0005e
#define ID_SD_R0 0x0005f
#define ID_SD_c0 0x00060
#define ID_SD_TLatent 0x00061
#define ID_SD_TRecover 0x00062
#define ID_SD_IFR 0x00063
#define ID_SD_TStartTesting 0x00064
#define ID_SD_TauTesting 0x00065
#define ID_SD_TTestingRate 0x00066
#define ID_SD_TContactsTestingRate 0x00067
#define ID_SD_TestingCoverage 0x00068
#define ID_SD_TestSensitivity 0x00069
#define ID_SD_ThetaMin 0x0006a
#define ID_SD_TauTheta 0x0006b
#define ID_SD_PwrTheta 0x0006c
#define ID_SD_HygienePwr 0x0006d
#define ID_SD_FracTraced 0x0006e
#define ID_SD_TPosTest 0x0006f
#define ID_SD_TFatalDeath 0x00070
#define ID_SD_TauS 0x00071
#define ID_SD_rMax 0x00072
#define ID_SD_TauR 0x00073
#define ID_z_NInit 0x00074
#define ID_z_TIsolation 0x00075
#define ID_z_R0 0x00076
#define ID_z_c0 0x00077
#define ID_z_TLatent 0x00078
#define ID_z_TRecover 0x00079
#define ID_z_IFR 0x0007a
#define ID_z_TStartTesting 0x0007b
#define ID_z_TauTesting 0x0007c
#define ID_z_TTestingRate 0x0007d
#define ID_z_TContactsTestingRate 0x0007e
#define ID_z_TestingCoverage 0x0007f
#define ID_z_TestSensitivity 0x00080
#define ID_z_ThetaMin 0x00081
#define ID_z_TauTheta 0x00082
#define ID_z_PwrTheta 0x00083
#define ID_z_HygienePwr 0x00084
#define ID_z_FracTraced 0x00085
#define ID_z_TPosTest 0x00086
#define ID_z_TFatalDeath 0x00087
#define ID_z_TauS 0x00088
#define ID_z_rMax 0x00089
#define ID_z_TauR 0x0008a


/*----- Global Variables */

/* For export. Keep track of who we are. */
char szModelDescFilename[] = "model/SEIR.scenarios.model.R";
char szModelSourceFilename[] = __FILE__;
char szModelGenAndVersion[] = "MCSim/mod.exe v6.1.0";

/* Externs */
extern BOOL vbModelReinitd;

/* Model Dimensions */
int vnStates = 13;
int vnOutputs = 21;
int vnModelVars = 34;
int vnInputs = 3;
int vnParms = 102;

/* States and Outputs*/
double vrgModelVars[34];

/* Inputs */
IFN vrgInputs[3];

/* Parameters */
double Npop;
double NInit;
double TIsolation;
double R0;
double c0;
double TLatent;
double TRecover;
double IFR;
double TStartTesting;
double TauTesting;
double TTestingRate;
double TContactsTestingRate;
double TestingCoverage;
double TestSensitivity;
double ThetaMin;
double TauTheta;
double PwrTheta;
double HygienePwr;
double FTraced0;
double TPosTest;
double TFatalDeath;
double alpha;
double kappa;
double rho;
double lambda0;
double lambda0_C;
double rho0_C;
double beta0;
double TauS;
double rMax;
double TauR;
double alpha_Pos;
double alpha_Death;
double GM_NInit;
double GM_TIsolation;
double GM_R0;
double GM_c0;
double GM_TLatent;
double GM_TRecover;
double GM_IFR;
double GM_TStartTesting;
double GM_TauTesting;
double GM_TTestingRate;
double GM_TContactsTestingRate;
double GM_TestingCoverage;
double GM_TestSensitivity;
double GM_ThetaMin;
double GM_TauTheta;
double GM_PwrTheta;
double GM_HygienePwr;
double GM_FracTraced;
double GM_TPosTest;
double GM_TFatalDeath;
double GM_TauS;
double GM_rMax;
double GM_TauR;
double SD_NInit;
double SD_TIsolation;
double SD_R0;
double SD_c0;
double SD_TLatent;
double SD_TRecover;
double SD_IFR;
double SD_TStartTesting;
double SD_TauTesting;
double SD_TTestingRate;
double SD_TContactsTestingRate;
double SD_TestingCoverage;
double SD_TestSensitivity;
double SD_ThetaMin;
double SD_TauTheta;
double SD_PwrTheta;
double SD_HygienePwr;
double SD_FracTraced;
double SD_TPosTest;
double SD_TFatalDeath;
double SD_TauS;
double SD_rMax;
double SD_TauR;
double z_NInit;
double z_TIsolation;
double z_R0;
double z_c0;
double z_TLatent;
double z_TRecover;
double z_IFR;
double z_TStartTesting;
double z_TauTesting;
double z_TTestingRate;
double z_TContactsTestingRate;
double z_TestingCoverage;
double z_TestSensitivity;
double z_ThetaMin;
double z_TauTheta;
double z_PwrTheta;
double z_HygienePwr;
double z_FracTraced;
double z_TPosTest;
double z_TFatalDeath;
double z_TauS;
double z_rMax;
double z_TauR;

BOOL bDelays = 1;


/*----- Global Variable Map */

VMMAPSTRCT vrgvmGlo[] = {
  {"S", (PVOID) &vrgModelVars[ID_S], ID_STATE | ID_S},
  {"S_C", (PVOID) &vrgModelVars[ID_S_C], ID_STATE | ID_S_C},
  {"E", (PVOID) &vrgModelVars[ID_E], ID_STATE | ID_E},
  {"E_C", (PVOID) &vrgModelVars[ID_E_C], ID_STATE | ID_E_C},
  {"I_U", (PVOID) &vrgModelVars[ID_I_U], ID_STATE | ID_I_U},
  {"I_C", (PVOID) &vrgModelVars[ID_I_C], ID_STATE | ID_I_C},
  {"R_U", (PVOID) &vrgModelVars[ID_R_U], ID_STATE | ID_R_U},
  {"I_T", (PVOID) &vrgModelVars[ID_I_T], ID_STATE | ID_I_T},
  {"R_T", (PVOID) &vrgModelVars[ID_R_T], ID_STATE | ID_R_T},
  {"F_T", (PVOID) &vrgModelVars[ID_F_T], ID_STATE | ID_F_T},
  {"CumInfected", (PVOID) &vrgModelVars[ID_CumInfected], ID_STATE | ID_CumInfected},
  {"CPosTest_U", (PVOID) &vrgModelVars[ID_CPosTest_U], ID_STATE | ID_CPosTest_U},
  {"CPosTest_C", (PVOID) &vrgModelVars[ID_CPosTest_C], ID_STATE | ID_CPosTest_C},
  {"ThetaFit", (PVOID) &vrgModelVars[ID_ThetaFit], ID_OUTPUT | ID_ThetaFit},
  {"HygieneFit", (PVOID) &vrgModelVars[ID_HygieneFit], ID_OUTPUT | ID_HygieneFit},
  {"FTraced", (PVOID) &vrgModelVars[ID_FTraced], ID_OUTPUT | ID_FTraced},
  {"lambda", (PVOID) &vrgModelVars[ID_lambda], ID_OUTPUT | ID_lambda},
  {"lambda_C", (PVOID) &vrgModelVars[ID_lambda_C], ID_OUTPUT | ID_lambda_C},
  {"rho_C", (PVOID) &vrgModelVars[ID_rho_C], ID_OUTPUT | ID_rho_C},
  {"delta", (PVOID) &vrgModelVars[ID_delta], ID_OUTPUT | ID_delta},
  {"c", (PVOID) &vrgModelVars[ID_c], ID_OUTPUT | ID_c},
  {"beta", (PVOID) &vrgModelVars[ID_beta], ID_OUTPUT | ID_beta},
  {"Rt", (PVOID) &vrgModelVars[ID_Rt], ID_OUTPUT | ID_Rt},
  {"Refft", (PVOID) &vrgModelVars[ID_Refft], ID_OUTPUT | ID_Refft},
  {"dtCumInfected", (PVOID) &vrgModelVars[ID_dtCumInfected], ID_OUTPUT | ID_dtCumInfected},
  {"dtCumPosTest", (PVOID) &vrgModelVars[ID_dtCumPosTest], ID_OUTPUT | ID_dtCumPosTest},
  {"dtCumDeath", (PVOID) &vrgModelVars[ID_dtCumDeath], ID_OUTPUT | ID_dtCumDeath},
  {"CumPosTest", (PVOID) &vrgModelVars[ID_CumPosTest], ID_OUTPUT | ID_CumPosTest},
  {"CumDeath", (PVOID) &vrgModelVars[ID_CumDeath], ID_OUTPUT | ID_CumDeath},
  {"N_pos", (PVOID) &vrgModelVars[ID_N_pos], ID_OUTPUT | ID_N_pos},
  {"D_pos", (PVOID) &vrgModelVars[ID_D_pos], ID_OUTPUT | ID_D_pos},
  {"p_N_pos", (PVOID) &vrgModelVars[ID_p_N_pos], ID_OUTPUT | ID_p_N_pos},
  {"p_D_pos", (PVOID) &vrgModelVars[ID_p_D_pos], ID_OUTPUT | ID_p_D_pos},
  {"Tot", (PVOID) &vrgModelVars[ID_Tot], ID_OUTPUT | ID_Tot},
  {"MuLambda", (PVOID) &vrgInputs[ID_MuLambda], ID_INPUT | ID_MuLambda},
  {"MuC", (PVOID) &vrgInputs[ID_MuC], ID_INPUT | ID_MuC},
  {"DeltaDelta", (PVOID) &vrgInputs[ID_DeltaDelta], ID_INPUT | ID_DeltaDelta},
  {"Npop", (PVOID) &Npop, ID_PARM | ID_Npop},
  {"NInit", (PVOID) &NInit, ID_PARM | ID_NInit},
  {"TIsolation", (PVOID) &TIsolation, ID_PARM | ID_TIsolation},
  {"R0", (PVOID) &R0, ID_PARM | ID_R0},
  {"c0", (PVOID) &c0, ID_PARM | ID_c0},
  {"TLatent", (PVOID) &TLatent, ID_PARM | ID_TLatent},
  {"TRecover", (PVOID) &TRecover, ID_PARM | ID_TRecover},
  {"IFR", (PVOID) &IFR, ID_PARM | ID_IFR},
  {"TStartTesting", (PVOID) &TStartTesting, ID_PARM | ID_TStartTesting},
  {"TauTesting", (PVOID) &TauTesting, ID_PARM | ID_TauTesting},
  {"TTestingRate", (PVOID) &TTestingRate, ID_PARM | ID_TTestingRate},
  {"TContactsTestingRate", (PVOID) &TContactsTestingRate, ID_PARM | ID_TContactsTestingRate},
  {"TestingCoverage", (PVOID) &TestingCoverage, ID_PARM | ID_TestingCoverage},
  {"TestSensitivity", (PVOID) &TestSensitivity, ID_PARM | ID_TestSensitivity},
  {"ThetaMin", (PVOID) &ThetaMin, ID_PARM | ID_ThetaMin},
  {"TauTheta", (PVOID) &TauTheta, ID_PARM | ID_TauTheta},
  {"PwrTheta", (PVOID) &PwrTheta, ID_PARM | ID_PwrTheta},
  {"HygienePwr", (PVOID) &HygienePwr, ID_PARM | ID_HygienePwr},
  {"FTraced0", (PVOID) &FTraced0, ID_PARM | ID_FTraced0},
  {"TPosTest", (PVOID) &TPosTest, ID_PARM | ID_TPosTest},
  {"TFatalDeath", (PVOID) &TFatalDeath, ID_PARM | ID_TFatalDeath},
  {"alpha", (PVOID) &alpha, ID_PARM | ID_alpha},
  {"kappa", (PVOID) &kappa, ID_PARM | ID_kappa},
  {"rho", (PVOID) &rho, ID_PARM | ID_rho},
  {"lambda0", (PVOID) &lambda0, ID_PARM | ID_lambda0},
  {"lambda0_C", (PVOID) &lambda0_C, ID_PARM | ID_lambda0_C},
  {"rho0_C", (PVOID) &rho0_C, ID_PARM | ID_rho0_C},
  {"beta0", (PVOID) &beta0, ID_PARM | ID_beta0},
  {"TauS", (PVOID) &TauS, ID_PARM | ID_TauS},
  {"rMax", (PVOID) &rMax, ID_PARM | ID_rMax},
  {"TauR", (PVOID) &TauR, ID_PARM | ID_TauR},
  {"alpha_Pos", (PVOID) &alpha_Pos, ID_PARM | ID_alpha_Pos},
  {"alpha_Death", (PVOID) &alpha_Death, ID_PARM | ID_alpha_Death},
  {"GM_NInit", (PVOID) &GM_NInit, ID_PARM | ID_GM_NInit},
  {"GM_TIsolation", (PVOID) &GM_TIsolation, ID_PARM | ID_GM_TIsolation},
  {"GM_R0", (PVOID) &GM_R0, ID_PARM | ID_GM_R0},
  {"GM_c0", (PVOID) &GM_c0, ID_PARM | ID_GM_c0},
  {"GM_TLatent", (PVOID) &GM_TLatent, ID_PARM | ID_GM_TLatent},
  {"GM_TRecover", (PVOID) &GM_TRecover, ID_PARM | ID_GM_TRecover},
  {"GM_IFR", (PVOID) &GM_IFR, ID_PARM | ID_GM_IFR},
  {"GM_TStartTesting", (PVOID) &GM_TStartTesting, ID_PARM | ID_GM_TStartTesting},
  {"GM_TauTesting", (PVOID) &GM_TauTesting, ID_PARM | ID_GM_TauTesting},
  {"GM_TTestingRate", (PVOID) &GM_TTestingRate, ID_PARM | ID_GM_TTestingRate},
  {"GM_TContactsTestingRate", (PVOID) &GM_TContactsTestingRate, ID_PARM | ID_GM_TContactsTestingRate},
  {"GM_TestingCoverage", (PVOID) &GM_TestingCoverage, ID_PARM | ID_GM_TestingCoverage},
  {"GM_TestSensitivity", (PVOID) &GM_TestSensitivity, ID_PARM | ID_GM_TestSensitivity},
  {"GM_ThetaMin", (PVOID) &GM_ThetaMin, ID_PARM | ID_GM_ThetaMin},
  {"GM_TauTheta", (PVOID) &GM_TauTheta, ID_PARM | ID_GM_TauTheta},
  {"GM_PwrTheta", (PVOID) &GM_PwrTheta, ID_PARM | ID_GM_PwrTheta},
  {"GM_HygienePwr", (PVOID) &GM_HygienePwr, ID_PARM | ID_GM_HygienePwr},
  {"GM_FracTraced", (PVOID) &GM_FracTraced, ID_PARM | ID_GM_FracTraced},
  {"GM_TPosTest", (PVOID) &GM_TPosTest, ID_PARM | ID_GM_TPosTest},
  {"GM_TFatalDeath", (PVOID) &GM_TFatalDeath, ID_PARM | ID_GM_TFatalDeath},
  {"GM_TauS", (PVOID) &GM_TauS, ID_PARM | ID_GM_TauS},
  {"GM_rMax", (PVOID) &GM_rMax, ID_PARM | ID_GM_rMax},
  {"GM_TauR", (PVOID) &GM_TauR, ID_PARM | ID_GM_TauR},
  {"SD_NInit", (PVOID) &SD_NInit, ID_PARM | ID_SD_NInit},
  {"SD_TIsolation", (PVOID) &SD_TIsolation, ID_PARM | ID_SD_TIsolation},
  {"SD_R0", (PVOID) &SD_R0, ID_PARM | ID_SD_R0},
  {"SD_c0", (PVOID) &SD_c0, ID_PARM | ID_SD_c0},
  {"SD_TLatent", (PVOID) &SD_TLatent, ID_PARM | ID_SD_TLatent},
  {"SD_TRecover", (PVOID) &SD_TRecover, ID_PARM | ID_SD_TRecover},
  {"SD_IFR", (PVOID) &SD_IFR, ID_PARM | ID_SD_IFR},
  {"SD_TStartTesting", (PVOID) &SD_TStartTesting, ID_PARM | ID_SD_TStartTesting},
  {"SD_TauTesting", (PVOID) &SD_TauTesting, ID_PARM | ID_SD_TauTesting},
  {"SD_TTestingRate", (PVOID) &SD_TTestingRate, ID_PARM | ID_SD_TTestingRate},
  {"SD_TContactsTestingRate", (PVOID) &SD_TContactsTestingRate, ID_PARM | ID_SD_TContactsTestingRate},
  {"SD_TestingCoverage", (PVOID) &SD_TestingCoverage, ID_PARM | ID_SD_TestingCoverage},
  {"SD_TestSensitivity", (PVOID) &SD_TestSensitivity, ID_PARM | ID_SD_TestSensitivity},
  {"SD_ThetaMin", (PVOID) &SD_ThetaMin, ID_PARM | ID_SD_ThetaMin},
  {"SD_TauTheta", (PVOID) &SD_TauTheta, ID_PARM | ID_SD_TauTheta},
  {"SD_PwrTheta", (PVOID) &SD_PwrTheta, ID_PARM | ID_SD_PwrTheta},
  {"SD_HygienePwr", (PVOID) &SD_HygienePwr, ID_PARM | ID_SD_HygienePwr},
  {"SD_FracTraced", (PVOID) &SD_FracTraced, ID_PARM | ID_SD_FracTraced},
  {"SD_TPosTest", (PVOID) &SD_TPosTest, ID_PARM | ID_SD_TPosTest},
  {"SD_TFatalDeath", (PVOID) &SD_TFatalDeath, ID_PARM | ID_SD_TFatalDeath},
  {"SD_TauS", (PVOID) &SD_TauS, ID_PARM | ID_SD_TauS},
  {"SD_rMax", (PVOID) &SD_rMax, ID_PARM | ID_SD_rMax},
  {"SD_TauR", (PVOID) &SD_TauR, ID_PARM | ID_SD_TauR},
  {"z_NInit", (PVOID) &z_NInit, ID_PARM | ID_z_NInit},
  {"z_TIsolation", (PVOID) &z_TIsolation, ID_PARM | ID_z_TIsolation},
  {"z_R0", (PVOID) &z_R0, ID_PARM | ID_z_R0},
  {"z_c0", (PVOID) &z_c0, ID_PARM | ID_z_c0},
  {"z_TLatent", (PVOID) &z_TLatent, ID_PARM | ID_z_TLatent},
  {"z_TRecover", (PVOID) &z_TRecover, ID_PARM | ID_z_TRecover},
  {"z_IFR", (PVOID) &z_IFR, ID_PARM | ID_z_IFR},
  {"z_TStartTesting", (PVOID) &z_TStartTesting, ID_PARM | ID_z_TStartTesting},
  {"z_TauTesting", (PVOID) &z_TauTesting, ID_PARM | ID_z_TauTesting},
  {"z_TTestingRate", (PVOID) &z_TTestingRate, ID_PARM | ID_z_TTestingRate},
  {"z_TContactsTestingRate", (PVOID) &z_TContactsTestingRate, ID_PARM | ID_z_TContactsTestingRate},
  {"z_TestingCoverage", (PVOID) &z_TestingCoverage, ID_PARM | ID_z_TestingCoverage},
  {"z_TestSensitivity", (PVOID) &z_TestSensitivity, ID_PARM | ID_z_TestSensitivity},
  {"z_ThetaMin", (PVOID) &z_ThetaMin, ID_PARM | ID_z_ThetaMin},
  {"z_TauTheta", (PVOID) &z_TauTheta, ID_PARM | ID_z_TauTheta},
  {"z_PwrTheta", (PVOID) &z_PwrTheta, ID_PARM | ID_z_PwrTheta},
  {"z_HygienePwr", (PVOID) &z_HygienePwr, ID_PARM | ID_z_HygienePwr},
  {"z_FracTraced", (PVOID) &z_FracTraced, ID_PARM | ID_z_FracTraced},
  {"z_TPosTest", (PVOID) &z_TPosTest, ID_PARM | ID_z_TPosTest},
  {"z_TFatalDeath", (PVOID) &z_TFatalDeath, ID_PARM | ID_z_TFatalDeath},
  {"z_TauS", (PVOID) &z_TauS, ID_PARM | ID_z_TauS},
  {"z_rMax", (PVOID) &z_rMax, ID_PARM | ID_z_rMax},
  {"z_TauR", (PVOID) &z_TauR, ID_PARM | ID_z_TauR},
  {"", NULL, 0} /* End flag */
};  /* vrgpvmGlo[] */


/*----- InitModel
   Should be called to initialize model variables at
   the beginning of experiment before reading
   variants from the simulation spec file.
*/

void InitModel(void)
{
  /* Initialize things in the order that they appear in
     model definition file so that dependencies are
     handled correctly. */

  vrgModelVars[ID_S] = 0.0;
  vrgModelVars[ID_S_C] = 0.0;
  vrgModelVars[ID_E] = 0.0;
  vrgModelVars[ID_E_C] = 0.0;
  vrgModelVars[ID_I_U] = 0.0;
  vrgModelVars[ID_I_C] = 0.0;
  vrgModelVars[ID_R_U] = 0.0;
  vrgModelVars[ID_I_T] = 0.0;
  vrgModelVars[ID_R_T] = 0.0;
  vrgModelVars[ID_F_T] = 0.0;
  vrgModelVars[ID_CumInfected] = 0.0;
  vrgModelVars[ID_CPosTest_U] = 0.0;
  vrgModelVars[ID_CPosTest_C] = 0.0;
  vrgInputs[ID_MuLambda].iType = IFN_CONSTANT;
  vrgInputs[ID_MuLambda].dTStartPeriod = 0;
  vrgInputs[ID_MuLambda].bOn = FALSE;
  vrgInputs[ID_MuLambda].dMag = -1.000000;
  vrgInputs[ID_MuLambda].dT0 = 0.000000;
  vrgInputs[ID_MuLambda].dTexp = 0.000000;
  vrgInputs[ID_MuLambda].dDecay = 0.000000;
  vrgInputs[ID_MuLambda].dTper = 0.000000;
  vrgInputs[ID_MuLambda].hMag = 0;
  vrgInputs[ID_MuLambda].hT0 = 0;
  vrgInputs[ID_MuLambda].hTexp = 0;
  vrgInputs[ID_MuLambda].hDecay = 0;
  vrgInputs[ID_MuLambda].hTper = 0;
  vrgInputs[ID_MuLambda].dVal = 0.0;
  vrgInputs[ID_MuLambda].nDoses = 0;
  vrgInputs[ID_MuC].iType = IFN_CONSTANT;
  vrgInputs[ID_MuC].dTStartPeriod = 0;
  vrgInputs[ID_MuC].bOn = FALSE;
  vrgInputs[ID_MuC].dMag = -1.000000;
  vrgInputs[ID_MuC].dT0 = 0.000000;
  vrgInputs[ID_MuC].dTexp = 0.000000;
  vrgInputs[ID_MuC].dDecay = 0.000000;
  vrgInputs[ID_MuC].dTper = 0.000000;
  vrgInputs[ID_MuC].hMag = 0;
  vrgInputs[ID_MuC].hT0 = 0;
  vrgInputs[ID_MuC].hTexp = 0;
  vrgInputs[ID_MuC].hDecay = 0;
  vrgInputs[ID_MuC].hTper = 0;
  vrgInputs[ID_MuC].dVal = 0.0;
  vrgInputs[ID_MuC].nDoses = 0;
  vrgInputs[ID_DeltaDelta].iType = IFN_CONSTANT;
  vrgInputs[ID_DeltaDelta].dTStartPeriod = 0;
  vrgInputs[ID_DeltaDelta].bOn = FALSE;
  vrgInputs[ID_DeltaDelta].dMag = -1.000000;
  vrgInputs[ID_DeltaDelta].dT0 = 0.000000;
  vrgInputs[ID_DeltaDelta].dTexp = 0.000000;
  vrgInputs[ID_DeltaDelta].dDecay = 0.000000;
  vrgInputs[ID_DeltaDelta].dTper = 0.000000;
  vrgInputs[ID_DeltaDelta].hMag = 0;
  vrgInputs[ID_DeltaDelta].hT0 = 0;
  vrgInputs[ID_DeltaDelta].hTexp = 0;
  vrgInputs[ID_DeltaDelta].hDecay = 0;
  vrgInputs[ID_DeltaDelta].hTper = 0;
  vrgInputs[ID_DeltaDelta].dVal = 0.0;
  vrgInputs[ID_DeltaDelta].nDoses = 0;
  vrgModelVars[ID_ThetaFit] = 0.0;
  vrgModelVars[ID_HygieneFit] = 0.0;
  vrgModelVars[ID_FTraced] = 0.0;
  vrgModelVars[ID_lambda] = 0.0;
  vrgModelVars[ID_lambda_C] = 0.0;
  vrgModelVars[ID_rho_C] = 0.0;
  vrgModelVars[ID_delta] = 0.0;
  vrgModelVars[ID_c] = 0.0;
  vrgModelVars[ID_beta] = 0.0;
  vrgModelVars[ID_Rt] = 0.0;
  vrgModelVars[ID_Refft] = 0.0;
  vrgModelVars[ID_dtCumInfected] = 0.0;
  vrgModelVars[ID_dtCumPosTest] = 0.0;
  vrgModelVars[ID_dtCumDeath] = 0.0;
  vrgModelVars[ID_CumPosTest] = 0.0;
  vrgModelVars[ID_CumDeath] = 0.0;
  vrgModelVars[ID_N_pos] = 0.0;
  vrgModelVars[ID_D_pos] = 0.0;
  vrgModelVars[ID_p_N_pos] = 0.0;
  vrgModelVars[ID_p_D_pos] = 0.0;
  vrgModelVars[ID_Tot] = 0.0;
  Npop = 1e5;
  NInit = 0;
  TIsolation = 0;
  R0 = 0;
  c0 = 0;
  TLatent = 0;
  TRecover = 0;
  IFR = 0;
  TStartTesting = 0;
  TauTesting = 0;
  TTestingRate = 0;
  TContactsTestingRate = 0;
  TestingCoverage = 0;
  TestSensitivity = 0;
  ThetaMin = 0;
  TauTheta = 0;
  PwrTheta = 0;
  HygienePwr = 0;
  FTraced0 = 0;
  TPosTest = 0;
  TFatalDeath = 0;
  alpha = 0;
  kappa = 0;
  rho = 0;
  lambda0 = 0;
  lambda0_C = 0;
  rho0_C = 0;
  beta0 = 0;
  TauS = 0;
  rMax = 0;
  TauR = 0;
  alpha_Pos = 4;
  alpha_Death = 4;
  GM_NInit = 1000;
  GM_TIsolation = 14;
  GM_R0 = 4;
  GM_c0 = 13;
  GM_TLatent = 4;
  GM_TRecover = 10;
  GM_IFR = 0.01;
  GM_TStartTesting = 70;
  GM_TauTesting = 3;
  GM_TTestingRate = 7;
  GM_TContactsTestingRate = 2;
  GM_TestingCoverage = 0.5;
  GM_TestSensitivity = 0.7;
  GM_ThetaMin = 0.44;
  GM_TauTheta = 18;
  GM_PwrTheta = 4.4;
  GM_HygienePwr = 0.25;
  GM_FracTraced = 0.1;
  GM_TPosTest = 3;
  GM_TFatalDeath = 3;
  GM_TauS = 33;
  GM_rMax = 0.53;
  GM_TauR = 44;
  SD_NInit = 0;
  SD_TIsolation = 0;
  SD_R0 = 0;
  SD_c0 = 0;
  SD_TLatent = 0;
  SD_TRecover = 0;
  SD_IFR = 0;
  SD_TStartTesting = 0;
  SD_TauTesting = 0;
  SD_TTestingRate = 0;
  SD_TContactsTestingRate = 0;
  SD_TestingCoverage = 0;
  SD_TestSensitivity = 0;
  SD_ThetaMin = 0;
  SD_TauTheta = 0;
  SD_PwrTheta = 0;
  SD_HygienePwr = 0;
  SD_FracTraced = 0;
  SD_TPosTest = 0;
  SD_TFatalDeath = 0;
  SD_TauS = 0;
  SD_rMax = 0;
  SD_TauR = 0;
  z_NInit = 0;
  z_TIsolation = 0;
  z_R0 = 0;
  z_c0 = 0;
  z_TLatent = 0;
  z_TRecover = 0;
  z_IFR = 0;
  z_TStartTesting = 0;
  z_TauTesting = 0;
  z_TTestingRate = 0;
  z_TContactsTestingRate = 0;
  z_TestingCoverage = 0;
  z_TestSensitivity = 0;
  z_ThetaMin = 0;
  z_TauTheta = 0;
  z_PwrTheta = 0;
  z_HygienePwr = 0;
  z_FracTraced = 0;
  z_TPosTest = 0;
  z_TFatalDeath = 0;
  z_TauS = 0;
  z_rMax = 0;
  z_TauR = 0;

  vbModelReinitd = TRUE;

} /* InitModel */


/*----- Dynamics section */

void CalcDeriv (double  rgModelVars[], double  rgDerivs[], PDOUBLE pdTime)
{
  /* local */ double TimeReopen;
  /* local */ double ReopenStart;
  /* local */ double ReopenStop;
  /* local */ double ReopenFitTmp;
  /* local */ double ctmp;
  /* local */ double Deltatmp;
  /* local */ double Deltatmp2;
  /* local */ double Delta;
  /* local */ double ReopenFit;
  /* local */ double TestingTimeDep;
  /* local */ double FTraced1;
  /* local */ double FTracedTmp;
  /* local */ double lambda1;
  /* local */ double fracpos;
  /* local */ double fracposmin;
  /* local */ double CFR;

  CalcInputs (pdTime); /* Get new input vals */


  rgModelVars[ID_ThetaFit] = ( ThetaMin - ( ThetaMin - 1 ) * exp ( - pow ( ( (*pdTime) -60 ) / TauTheta , PwrTheta ) ) ) ;

  TimeReopen = 60 + TauTheta + TauS ;

  ReopenStart = ( 1 - 1 / ( 1 + exp ( 4 * ( (*pdTime) - TimeReopen ) ) ) ) ;

  ReopenStop = ( 1 - 1 / ( 1 + exp ( 4 * ( (*pdTime) - ( TimeReopen + TauR ) ) ) ) ) ;

  ReopenFitTmp = ( ( (*pdTime) - TimeReopen ) * ( rMax / TauR ) * ( ReopenStart - ReopenStop ) + rMax * ReopenStop ) ;

  ctmp = c0 * ( rgModelVars[ID_ThetaFit] + ( 1 - ThetaMin ) * ReopenFitTmp ) ;

  rgModelVars[ID_HygieneFit] = pow ( rgModelVars[ID_ThetaFit] , HygienePwr ) ;

  rgModelVars[ID_beta] = beta0 * rgModelVars[ID_HygieneFit] ;

  Deltatmp = ( ctmp * rgModelVars[ID_beta] / ( c0 * beta0 ) - pow ( ThetaMin , 1 + HygienePwr ) ) / ( 1 - pow ( ThetaMin , 1 + HygienePwr ) ) ;

  Deltatmp2 = ( vrgInputs[ID_DeltaDelta].dVal > -1 ) ? ( Deltatmp + vrgInputs[ID_DeltaDelta].dVal ) : Deltatmp ;

  Delta = ( Deltatmp2 > 1 ) ? 1 : ( ( Deltatmp2 < 0 ) ? 0 : Deltatmp2 ) ;

  ReopenFit = ( ( Delta * ( 1 - pow ( ThetaMin , 1 + HygienePwr ) ) - ( pow ( rgModelVars[ID_ThetaFit] , 1 + HygienePwr ) - pow ( ThetaMin , 1 + HygienePwr ) ) ) / ( ( 1 - ThetaMin ) * pow ( rgModelVars[ID_ThetaFit] , HygienePwr ) ) ) ;

  rgModelVars[ID_c] = ( vrgInputs[ID_DeltaDelta].dVal > -1 ) ? ( c0 * ( rgModelVars[ID_ThetaFit] + ( 1 - ThetaMin ) * ReopenFit ) ) : ctmp ;

  TestingTimeDep = ( 1 -1 / ( 1 + exp ( ( (*pdTime) - TStartTesting ) / TauTesting ) ) ) ;

  FTraced1 = FTraced0 * TestingTimeDep ;

  FTracedTmp = FTraced1 * ( ( vrgInputs[ID_MuC].dVal > 0 ) ? vrgInputs[ID_MuC].dVal : 1 ) ;

  rgModelVars[ID_FTraced] = ( FTracedTmp > 1 ) ? 1 : FTracedTmp ;

  lambda1 = TestingTimeDep * lambda0 ;

  rgModelVars[ID_lambda] = lambda1 * ( ( vrgInputs[ID_MuLambda].dVal > 0 ) ? vrgInputs[ID_MuLambda].dVal : 1 ) ;

  rgModelVars[ID_lambda_C] = TestingTimeDep * lambda0_C ;

  rgModelVars[ID_rho_C] = TestingTimeDep * rho0_C ;

  fracpos = FTraced1 * rgModelVars[ID_lambda_C] / ( rgModelVars[ID_lambda_C] + rgModelVars[ID_rho_C] ) + ( 1 - FTraced1 ) * lambda1 / ( lambda1 + rho ) ;

  fracposmin = IFR / 0.9 ;

  CFR = ( fracpos > fracposmin ) ? IFR / fracpos : 0.9 ;

  rgModelVars[ID_delta] = rho * CFR / ( 1 - CFR ) ;

  rgDerivs[ID_S] = - rgModelVars[ID_S] * rgModelVars[ID_c] * rgModelVars[ID_I_U] * ( rgModelVars[ID_beta] + ( 1 - rgModelVars[ID_beta] ) * rgModelVars[ID_FTraced] ) + rgModelVars[ID_S_C] * alpha ;

  rgDerivs[ID_S_C] = - rgModelVars[ID_S_C] * alpha + rgModelVars[ID_S] * rgModelVars[ID_c] * rgModelVars[ID_I_U] * ( 1 - rgModelVars[ID_beta] ) * rgModelVars[ID_FTraced] ;

  rgDerivs[ID_E] = - rgModelVars[ID_E] * kappa + rgModelVars[ID_S] * rgModelVars[ID_c] * rgModelVars[ID_I_U] * rgModelVars[ID_beta] * ( 1 - rgModelVars[ID_FTraced] ) ;

  rgDerivs[ID_E_C] = - rgModelVars[ID_E_C] * kappa + rgModelVars[ID_S] * rgModelVars[ID_c] * rgModelVars[ID_I_U] * rgModelVars[ID_beta] * rgModelVars[ID_FTraced] ;

  rgDerivs[ID_I_U] = - rgModelVars[ID_I_U] * ( rgModelVars[ID_lambda] + rho ) + rgModelVars[ID_E] * kappa ;

  rgDerivs[ID_I_C] = - rgModelVars[ID_I_C] * ( rgModelVars[ID_lambda_C] + rgModelVars[ID_rho_C] ) + rgModelVars[ID_E_C] * kappa ;

  rgDerivs[ID_R_U] = rgModelVars[ID_I_U] * rho + rgModelVars[ID_I_C] * rgModelVars[ID_rho_C] ;

  rgDerivs[ID_I_T] = - rgModelVars[ID_I_T] * ( rho + rgModelVars[ID_delta] ) + rgModelVars[ID_I_U] * rgModelVars[ID_lambda] + rgModelVars[ID_I_C] * rgModelVars[ID_lambda_C] ;

  rgDerivs[ID_R_T] = rgModelVars[ID_I_T] * rho ;

  rgDerivs[ID_F_T] = rgModelVars[ID_I_T] * rgModelVars[ID_delta] ;

  rgDerivs[ID_CumInfected] = ( rgModelVars[ID_E] + rgModelVars[ID_E_C] ) * kappa ;

  rgDerivs[ID_CPosTest_U] = rgModelVars[ID_I_U] * rgModelVars[ID_lambda] ;

  rgDerivs[ID_CPosTest_C] = rgModelVars[ID_I_C] * rgModelVars[ID_lambda_C] ;

} /* CalcDeriv */


/*----- Model scaling */

void ScaleModel (PDOUBLE pdTime)
{

  NInit = GM_NInit * exp ( SD_NInit * z_NInit ) ;

  TIsolation = GM_TIsolation * exp ( SD_TIsolation * z_TIsolation ) ;

  R0 = GM_R0 * exp ( SD_R0 * z_R0 ) ;
  c0 = GM_c0 * exp ( SD_c0 * z_c0 ) ;

  TLatent = GM_TLatent * exp ( SD_TLatent * z_TLatent ) ;

  TRecover = GM_TRecover * exp ( SD_TRecover * z_TRecover ) ;

  IFR = GM_IFR * exp ( SD_IFR * z_IFR ) ;

  TStartTesting = GM_TStartTesting * exp ( SD_TStartTesting * z_TStartTesting ) ;
  TauTesting = GM_TauTesting * exp ( SD_TauTesting * z_TauTesting ) ;
  TTestingRate = GM_TTestingRate * exp ( SD_TTestingRate * z_TTestingRate ) ;
  TContactsTestingRate = GM_TContactsTestingRate * exp ( SD_TContactsTestingRate * z_TContactsTestingRate ) ;
  TestingCoverage = GM_TestingCoverage * exp ( SD_TestingCoverage * z_TestingCoverage ) ;
  TestSensitivity = GM_TestSensitivity * exp ( SD_TestSensitivity * z_TestSensitivity ) ;

  ThetaMin = GM_ThetaMin * exp ( SD_ThetaMin * z_ThetaMin ) ;
  TauTheta = GM_TauTheta * exp ( SD_TauTheta * z_TauTheta ) ;
  PwrTheta = GM_PwrTheta * exp ( SD_PwrTheta * z_PwrTheta ) ;
  HygienePwr = GM_HygienePwr * exp ( SD_HygienePwr * z_HygienePwr ) ;

  FTraced0 = GM_FracTraced * exp ( SD_FracTraced * z_FracTraced ) ;

  TPosTest = GM_TPosTest * exp ( SD_TPosTest * z_TPosTest ) ;
  TFatalDeath = GM_TFatalDeath * exp ( SD_TFatalDeath * z_TFatalDeath ) ;

  alpha = 1 / TIsolation ;
  kappa = 1 / TLatent ;
  rho = 1 / TRecover ;
  lambda0 = TestingCoverage * TestSensitivity / TTestingRate ;
  lambda0_C = 1.0 * TestSensitivity / TContactsTestingRate ;
  rho0_C = 1.0 * ( 1.0 - TestSensitivity ) / TContactsTestingRate ;
  beta0 = R0 * rho / c0 ;

  vrgModelVars[ID_S] = 1 ;
  vrgModelVars[ID_I_U] = NInit / Npop ;

  TauS = GM_TauS * exp ( SD_TauS * z_TauS ) ;
  rMax = GM_rMax * exp ( SD_rMax * z_rMax ) ;
  TauR = GM_TauR * exp ( SD_TauR * z_TauR ) ;

} /* ScaleModel */


/*----- Jacobian calculations */

void CalcJacob (PDOUBLE pdTime, double rgModelVars[],
                long column, double rgdJac[])
{

} /* CalcJacob */


/*----- Outputs calculations */

void CalcOutputs (double  rgModelVars[], double  rgDerivs[], PDOUBLE pdTime)
{
  /* local */ double TimeReopen;
  /* local */ double ReopenStart;
  /* local */ double ReopenStop;
  /* local */ double ReopenFitTmp;
  /* local */ double ctmp;
  /* local */ double Deltatmp;
  /* local */ double Deltatmp2;
  /* local */ double Delta;
  /* local */ double ReopenFit;
  /* local */ double TestingTimeDep;
  /* local */ double FTraced1;
  /* local */ double FTracedTmp;
  /* local */ double lambda1;
  /* local */ double fracpos;
  /* local */ double fracposmin;
  /* local */ double CFR;
  /* local */ double TeffPosTest;
  /* local */ double TeffDeath;

  rgModelVars[ID_ThetaFit] = ( ThetaMin - ( ThetaMin - 1 ) * exp ( - pow ( ( (*pdTime) -60 ) / TauTheta , PwrTheta ) ) ) ;

  TimeReopen = 60 + TauTheta + TauS ;
  ReopenStart = ( 1 - 1 / ( 1 + exp ( 4 * ( (*pdTime) - TimeReopen ) ) ) ) ;
  ReopenStop = ( 1 - 1 / ( 1 + exp ( 4 * ( (*pdTime) - ( TimeReopen + TauR ) ) ) ) ) ;
  ReopenFitTmp = ( ( (*pdTime) - TimeReopen ) * ( rMax / TauR ) * ( ReopenStart - ReopenStop ) + rMax * ReopenStop ) ;

  ctmp = c0 * ( rgModelVars[ID_ThetaFit] + ( 1 - ThetaMin ) * ReopenFitTmp ) ;

  rgModelVars[ID_HygieneFit] = pow ( rgModelVars[ID_ThetaFit] , HygienePwr ) ;
  rgModelVars[ID_beta] = beta0 * rgModelVars[ID_HygieneFit] ;

  Deltatmp = ( ctmp * rgModelVars[ID_beta] / ( c0 * beta0 ) - pow ( ThetaMin , 1 + HygienePwr ) ) / ( 1 - pow ( ThetaMin , 1 + HygienePwr ) ) ;
  Deltatmp2 = ( vrgInputs[ID_DeltaDelta].dVal > -1 ) ? ( Deltatmp + vrgInputs[ID_DeltaDelta].dVal ) : Deltatmp ;
  Delta = ( Deltatmp2 > 1 ) ? 1 : ( ( Deltatmp2 < 0 ) ? 0 : Deltatmp2 ) ;

  ReopenFit = ( ( Delta * ( 1 - pow ( ThetaMin , 1 + HygienePwr ) ) - ( pow ( rgModelVars[ID_ThetaFit] , 1 + HygienePwr ) - pow ( ThetaMin , 1 + HygienePwr ) ) ) / ( ( 1 - ThetaMin ) * pow ( rgModelVars[ID_ThetaFit] , HygienePwr ) ) ) ;
  rgModelVars[ID_c] = ( vrgInputs[ID_DeltaDelta].dVal > -1 ) ? ( c0 * ( rgModelVars[ID_ThetaFit] + ( 1 - ThetaMin ) * ReopenFit ) ) : ctmp ;

  TestingTimeDep = ( 1 -1 / ( 1 + exp ( ( (*pdTime) - TStartTesting ) / TauTesting ) ) ) ;

  FTraced1 = FTraced0 * TestingTimeDep ;
  FTracedTmp = FTraced1 * ( ( vrgInputs[ID_MuC].dVal > 0 ) ? vrgInputs[ID_MuC].dVal : 1 ) ;
  rgModelVars[ID_FTraced] = ( FTracedTmp > 1 ) ? 1 : FTracedTmp ;

  lambda1 = TestingTimeDep * lambda0 ;
  rgModelVars[ID_lambda] = lambda1 * ( ( vrgInputs[ID_MuLambda].dVal > 0 ) ? vrgInputs[ID_MuLambda].dVal : 1 ) ;
  rgModelVars[ID_lambda_C] = TestingTimeDep * lambda0_C ;
  rgModelVars[ID_rho_C] = TestingTimeDep * rho0_C ;
  fracpos = FTraced1 * rgModelVars[ID_lambda_C] / ( rgModelVars[ID_lambda_C] + rgModelVars[ID_rho_C] ) + ( 1 - FTraced1 ) * lambda1 / ( lambda1 + rho ) ;

  fracposmin = IFR / 0.9 ;
  CFR = ( fracpos > fracposmin ) ? IFR / fracpos : 0.9 ;
  rgModelVars[ID_delta] = rho * CFR / ( 1 - CFR ) ;

  rgModelVars[ID_Rt] = rgModelVars[ID_c] * rgModelVars[ID_beta] * ( 1 - rgModelVars[ID_FTraced] ) / ( rho + rgModelVars[ID_lambda] ) ;

  rgModelVars[ID_Refft] = rgModelVars[ID_S] * rgModelVars[ID_Rt] ;

  rgModelVars[ID_dtCumInfected] = ( rgModelVars[ID_E] + rgModelVars[ID_E_C] ) * kappa ;

  TeffPosTest = (*pdTime) - 60 - TPosTest ;
  rgModelVars[ID_dtCumPosTest] = ( ( TeffPosTest > 0 ) ? ( CalcDelay ( ID_I_U, (*pdTime) , TPosTest ) * rgModelVars[ID_lambda] ) : 0 ) + rgModelVars[ID_I_C] * rgModelVars[ID_lambda_C] ;
  rgModelVars[ID_CumPosTest] = ( ( TeffPosTest > 0 ) ? CalcDelay ( ID_CPosTest_U, (*pdTime) , TPosTest ) : 0 ) + rgModelVars[ID_CPosTest_C] ;

  TeffDeath = (*pdTime) - 60 - TFatalDeath ;
  rgModelVars[ID_dtCumDeath] = ( TeffDeath > 0 ) ? ( CalcDelay ( ID_I_T, (*pdTime) , TFatalDeath ) * rgModelVars[ID_delta] ) : 0 ;
  rgModelVars[ID_CumDeath] = ( TeffDeath > 0 ) ? CalcDelay ( ID_F_T, (*pdTime) , TFatalDeath ) : 0 ;

  rgModelVars[ID_N_pos] = ( ( rgModelVars[ID_dtCumPosTest] * Npop ) > 1e-15 ) ? ( rgModelVars[ID_dtCumPosTest] * Npop ) : 1e-15 ;
  rgModelVars[ID_D_pos] = ( ( rgModelVars[ID_dtCumDeath] * Npop ) > 1e-15 ) ? ( rgModelVars[ID_dtCumDeath] * Npop ) : 1e-15 ;

  rgModelVars[ID_p_N_pos] = rgModelVars[ID_N_pos] / ( alpha_Pos + rgModelVars[ID_N_pos] ) ;
  rgModelVars[ID_p_D_pos] = rgModelVars[ID_D_pos] / ( alpha_Death + rgModelVars[ID_D_pos] ) ;

  rgModelVars[ID_Tot] = rgModelVars[ID_S] + rgModelVars[ID_S_C] + rgModelVars[ID_E] + rgModelVars[ID_E_C] + rgModelVars[ID_I_U] + rgModelVars[ID_I_C] + rgModelVars[ID_R_U] + rgModelVars[ID_I_T] + rgModelVars[ID_R_T] + rgModelVars[ID_F_T] ;

}  /* CalcOutputs */


