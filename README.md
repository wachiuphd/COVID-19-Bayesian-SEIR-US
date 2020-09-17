# COVID-19-Bayesian-SEIR-US
Bayesian COVID-19 Extended SEIR Model for US States

## System Requirements

This model uses GNU MCSim version 6.1.0, along with R and R Studio. The GNU MCSim code is included in this repository in the MCSim directory, and is compiled directly from R. The software has been tested on maxOS Mojave 10.14.6 and Linux version 2.6.32-754.31.1.el6.x86_64 (mockbuild@x86-01.bsys.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-23) (GCC) ).  No non-standard software or hardware is required.

The R version and package information is as follows:

─ Session info ─────────────────────────────────────────────────
 setting  value                       
 version  R version 3.6.1 (2019-07-05)
 os       macOS Mojave 10.14.6        
 system   x86_64, darwin15.6.0        
 ui       RStudio                     
 language (EN)                        
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       America/Chicago             
 date     2020-07-03      
 
─ Packages ─────────────────────────────────────────────────────
 package      * version  date       lib source        
 assertthat     0.2.1    2019-03-21 [1] CRAN (R 3.6.0)
 backports      1.1.5    2019-10-02 [1] CRAN (R 3.6.0)
 bayesplot    * 1.7.1    2019-12-01 [1] CRAN (R 3.6.0)
 bitops         1.0-6    2013-08-17 [1] CRAN (R 3.6.0)
 broom          0.5.3    2019-12-14 [1] CRAN (R 3.6.0)
 callr          3.4.0    2019-12-09 [1] CRAN (R 3.6.0)
 cellranger     1.1.0    2016-07-27 [1] CRAN (R 3.6.0)
 cli            2.0.0    2019-12-09 [1] CRAN (R 3.6.0)
 coda         * 0.19-3   2019-07-05 [1] CRAN (R 3.6.0)
 colorspace     1.4-1    2019-03-18 [1] CRAN (R 3.6.0)
 covid19us    * 0.1.3    2020-04-29 [1] CRAN (R 3.6.1)
 crayon         1.3.4    2017-09-16 [1] CRAN (R 3.6.0)
 curl           4.3      2019-12-02 [1] CRAN (R 3.6.0)
 data.table   * 1.12.8   2019-12-09 [1] CRAN (R 3.6.0)
 DBI            1.1.0    2019-12-15 [1] CRAN (R 3.6.0)
 dbplyr         1.4.2    2019-06-17 [1] CRAN (R 3.6.0)
 desc           1.2.0    2018-05-01 [1] CRAN (R 3.6.0)
 devtools       2.2.1    2019-09-24 [1] CRAN (R 3.6.0)
 digest         0.6.23   2019-11-23 [1] CRAN (R 3.6.0)
 dplyr        * 0.8.3    2019-07-04 [1] CRAN (R 3.6.0)
 ellipsis       0.3.0    2019-09-20 [1] CRAN (R 3.6.0)
 fansi          0.4.0    2018-10-05 [1] CRAN (R 3.6.0)
 farver         2.0.1    2019-11-13 [1] CRAN (R 3.6.0)
 forcats      * 0.4.0    2019-02-17 [1] CRAN (R 3.6.0)
 fs             1.3.1    2019-05-06 [1] CRAN (R 3.6.0)
 generics       0.0.2    2018-11-29 [1] CRAN (R 3.6.0)
 GGally       * 1.4.0    2018-05-17 [1] CRAN (R 3.6.0)
 ggplot2      * 3.2.1    2019-08-10 [1] CRAN (R 3.6.0)
 ggridges       0.5.1    2018-09-27 [1] CRAN (R 3.6.0)
 glue           1.3.1    2019-03-12 [1] CRAN (R 3.6.0)
 gridExtra    * 2.3      2017-09-09 [1] CRAN (R 3.6.0)
 gtable         0.3.0    2019-03-25 [1] CRAN (R 3.6.0)
 haven          2.2.0    2019-11-08 [1] CRAN (R 3.6.0)
 here         * 0.1      2017-05-28 [1] CRAN (R 3.6.0)
 hms            0.5.2    2019-10-30 [1] CRAN (R 3.6.0)
 httr           1.4.1    2019-08-05 [1] CRAN (R 3.6.0)
 jsonlite     * 1.6      2018-12-07 [1] CRAN (R 3.6.0)
 knitr          1.26     2019-11-12 [1] CRAN (R 3.6.0)
 labeling       0.3      2014-08-23 [1] CRAN (R 3.6.0)
 lattice        0.20-38  2018-11-04 [2] CRAN (R 3.6.1)
 lazyeval       0.2.2    2019-03-15 [1] CRAN (R 3.6.0)
 lifecycle      0.1.0    2019-08-01 [1] CRAN (R 3.6.0)
 lubridate      1.7.4    2018-04-11 [1] CRAN (R 3.6.0)
 magrittr       1.5      2014-11-22 [1] CRAN (R 3.6.0)
 memoise        1.1.0    2017-04-21 [1] CRAN (R 3.6.0)
 modelr         0.1.5    2019-08-08 [1] CRAN (R 3.6.0)
 munsell        0.5.0    2018-06-12 [1] CRAN (R 3.6.0)
 nlme           3.1-140  2019-05-12 [2] CRAN (R 3.6.1)
 packrat        0.5.0    2018-11-14 [1] CRAN (R 3.6.0)
 pillar         1.4.3    2019-12-20 [1] CRAN (R 3.6.0)
 pkgbuild       1.0.6    2019-10-09 [1] CRAN (R 3.6.0)
 pkgconfig      2.0.3    2019-09-22 [1] CRAN (R 3.6.0)
 pkgload        1.0.2    2018-10-29 [1] CRAN (R 3.6.0)
 plyr           1.8.5    2019-12-10 [1] CRAN (R 3.6.0)
 prettyunits    1.0.2    2015-07-13 [1] CRAN (R 3.6.0)
 processx       3.4.1    2019-07-18 [1] CRAN (R 3.6.0)
 ps             1.3.0    2018-12-21 [1] CRAN (R 3.6.0)
 purrr        * 0.3.3    2019-10-18 [1] CRAN (R 3.6.0)
 R6             2.4.1    2019-11-12 [1] CRAN (R 3.6.0)
 RColorBrewer   1.1-2    2014-12-07 [1] CRAN (R 3.6.0)
 Rcpp           1.0.3    2019-11-08 [1] CRAN (R 3.6.0)
 RCurl        * 1.98-1.2 2020-04-18 [1] CRAN (R 3.6.2)
 readr        * 1.3.1    2018-12-21 [1] CRAN (R 3.6.0)
 readxl         1.3.1    2019-03-13 [1] CRAN (R 3.6.0)
 remotes        2.1.0    2019-06-24 [1] CRAN (R 3.6.0)
 reprex         0.3.0    2019-05-16 [1] CRAN (R 3.6.0)
 reshape        0.8.8    2018-10-23 [1] CRAN (R 3.6.0)
 reshape2     * 1.4.3    2017-12-11 [1] CRAN (R 3.6.0)
 rlang          0.4.2    2019-11-23 [1] CRAN (R 3.6.0)
 rprojroot      1.3-2    2018-01-03 [1] CRAN (R 3.6.0)
 rstudioapi     0.10     2019-03-19 [1] CRAN (R 3.6.0)
 rvest        * 0.3.5    2019-11-08 [1] CRAN (R 3.6.0)
 scales         1.1.0    2019-11-18 [1] CRAN (R 3.6.0)
 selectr        0.4-2    2019-11-20 [1] CRAN (R 3.6.0)
 sessioninfo    1.1.1    2018-11-05 [1] CRAN (R 3.6.0)
 stringi        1.4.3    2019-03-12 [1] CRAN (R 3.6.0)
 stringr      * 1.4.0    2019-02-10 [1] CRAN (R 3.6.0)
 testthat       2.3.1    2019-12-01 [1] CRAN (R 3.6.0)
 tibble       * 2.1.3    2019-06-06 [1] CRAN (R 3.6.0)
 tidyr        * 1.0.2    2020-01-24 [1] CRAN (R 3.6.0)
 tidyselect     0.2.5    2018-10-11 [1] CRAN (R 3.6.0)
 tidyverse    * 1.3.0    2019-11-21 [1] CRAN (R 3.6.0)
 usethis        1.5.1    2019-07-04 [1] CRAN (R 3.6.0)
 vctrs          0.2.1    2019-12-17 [1] CRAN (R 3.6.0)
 viridisLite    0.3.0    2018-02-01 [1] CRAN (R 3.6.0)
 withr          2.1.2    2018-03-15 [1] CRAN (R 3.6.0)
 xfun           0.11     2019-11-12 [1] CRAN (R 3.6.0)
 xml2         * 1.2.2    2019-08-09 [1] CRAN (R 3.6.0)
 zeallot        0.1.0    2018-01-28 [1] CRAN (R 3.6.0)

[1] /Users/wchiu/Library/R/3.6/library
[2] /Library/Frameworks/R.framework/Versions/3.6/Resources/library

## Installation Guide

(1) Install R and R Studio, and all required packages (see above).  Note that to run the demo, a C complier that is compatible with R/R Studio devtools package is required.
(2) Download the repository (from Github or zip file)
(3) Open the COVID-19-Bayesian-SEIR-US.Rproj in R Studio

Typical install time is <30 minutes, with the bottleneck usually being installing R devtools abd C compiler, and getting them working together.

The directories are organized as follows:

data - FIPS table and data related to social distancing
functions - scripts and R functions
MCSim - files for the Gnu MCSim engine
MobilityMetrics - analysis of mobility data to generate state-specific prior distributions (see below)
model - model definition files (compiled by MCSim to create executable files)
priors - prior distribution templates
scenarios - scenario templates
TestRuns - demonstration files
Figures - 

## Mobility Data Fits

Analysis of mobility data is contained in the *MobilityMetrics* directory.  Mobility data were used to generate state-specific prior distributions for social distancing time-dependence. Initial analyses in June are in the *Mobility Fits.Rmd* R markdown file.  Run each "chunk" and it will generate the results in the generated csv files and summary in the Word "docx" file.  Subsequent update was performed in July, using *Mobility Fits July.Rmd*.

Note that *MobilityFitExample-2020-07-21.pdf* is part of Figure 1, and Supplementary Figure 1 is *Mobility-2020-07-21.pdf*.

## Demonstration Test Runs

Test runs are demonstrated in the *TestRuns* directory.  All example runs are documented in the *Test Runs.Rmd* R markdown file.  Run each "chunk" and the results will be generated.  Entire demo should take <30 minutes on a "normal" computer (on a MacBook Pro, 15 in, 2017, running macOS Mojave Version 10.14.5, the test runs took 13 minutes).  A "knitted" version of the Rmd file is included as an html *Test-Runs.html* file in this directory.

The different sections are as follows:

### Testing data

This shows how the confirmed cases and reported deaths data are downloaded from public sources, and plots the data for each state.

### MCSim simulation

This compiles the MCSim executable file.  The repository has versions compiled for macOS.  

### Deterministic model

This is an example model run using "default" parameters.  Various results are plotted, including all time-dependent parameters and predicted cases and deaths compared to data.

### Monte Carlo Test

This example runs the model for 5000 random parameter sets drawn from the prior distributions.  One run is "without" integration of the differential equations, and another is with integration, in order to test the stability of the integration solver.  In this test, no integrations failed, so all parameters samples lead to complete solutions.

### MCMC run using generic prior

For "validation" runs (through April 30), generic wide priors were used for the social distancing and reopening parameters.  A short MCMC chain for TX is run here as a test, and put in the *TX.Val* directory.  A diagnostic file *Test.Validation.TX.pdf* is generated with plots of the results for a single iteration of the MCMC chain, with comparisons to data.

### MCMC run using state-specific prior

For "prediction" runs (through June 20), state-specific priors based on Mobility Data (see above) were used for the social distancing and reopening parameters.  A short MCMC chain for TX is run here as a test, and put in the *TX.Pred* directory.  A diagnostic file *Test.Prediction.TX.pdf* is generated with plots of the results for a single iteration of the MCMC chain, with comparisons to data.

### MCMC runs with 4 chains

This is a demo of a "short" version of the full "prediction" MCMC runs, with 4 chains.  The results are generated and put in the "TX" directory.  

Then, these runs are analyzed with two scripts *plot_parameter_results.R* and *run_batch_rhat_multicheck.R*.  This results in the generation of several CSV files showing:
* Rhat - the convergency diagnostic (value approaches 1 for convergence)
* Prediction quantiles - quantiles for predictions of key outputs
* Parameter quantiles - quantiles of model paramters
Additionally, several pdf files are generated:
* Parameter plots showing traces of the four chains

Finally, a demonstration of the different scenarios is run.  First, outputs at a single time point are run.  Then time-series are run for 12 scenarios (testing 1x and 2x; contact tracing 1x and 2x; reopening constant, +25%, and -25%).  The result is a PDF file *Scenarios_TestRuns.pdf* showing the posterior distribution of predictions for the different scenarios, along with the data.

## Instructions for use and reproduction of all results

### Running model for different dates

* To generate the input files for validation, run the script *setup_batch_validation_SEIR.reopen.R*, which will create a directory *SEIR.reopen.2020.04.30*.  
* Similarly, to generate the input files for prediction to June 20, run the script *setup_batch_validation.2_SEIR.reopen.R*, which will create a directory *SEIR.reopen.state.2020.06.20*. 
* For the predictions to July 22, run the script *setup_batch_prediction_SEIR.reopen.R*, which will create a directory *SEIR.reopen.state.2020.07.22*. 

In all cases, each state has its own directory, and a shell script *.jobfile* that runs the analyses. Because these are run on a cluster (named "ada" - hence the template file in "functions" with that in the name), a tgz archive is also created so it can be uploaded to a cluster.  Once on the cluster, the model file is compiled for that platform, and then a shell script *SEIR_run_all.sh* is run to submit all the jobfiles to the cluster.  

After the runs are complete, then tgz archives of all the *.csv* and *samps.out* files are manually created and downloaded from the cluster for analysis.  In the repository, all results files have been uploaded already.  

A quick set of diagnostic plots is generated by running *plot_all_pred_obs.R* in the *functions* folder (using the appropriate folders/dates for each different run).  A comparison of prior and posterior distributions across all runs is generated by running *Prior-Posterior-Comparison.R* which generates the file *PriorPostAll.pdf*.

### Comparisons between model fits/predictions to training/validation data

Validation comparisons (training through April 30, validation through June 20) are generated by first running the script *run_plot_validation_scenario.R* which generates Supplemental Figure S2 as a standalone PDF *FigS2_ValidationResults.pdf* in the *Figures* directory.  Coverage of the 95% CrI including dispersion is summarized in *FigS2_ValidationCoverage.csv*.  Additionally, in the Figures directory, the markdown file *Figure_Validation.Rmd* generates the example states validation shown in Figure 1 (file *Fig1B.pdf*), as well as Supplemental Figure S3 *FigS3.pdf*, the scatter plot of training and validation vs. data.

A second validation was performed (not shown in manuscript) using training data through June 20, and validation through July 22.  The equivalent to Supplement Figure S2 is generated by the script *run_plot_validation.2_scenario.R*, generating *FigS2_Validation.2.Results.pdf* and *FigS2_Validation.2.Coverage.csv* in the *Figures* directory. An analogous markdown file *Figure_Validation.2.Rmd* generates the equivalent example states validation shown in Figure 1 (file *Fig1B.2.pdf*), as well as the equivalent Supplemental Figure S3 *FigS3.2.pdf*, the scatter plot of training and validation vs. data.

The comparisons of model fit for the prediction run are generated first with *run_plot_fit_scenario.R*, which generates *FigS4_FitResults.pdf* and *FigS4_FitCoverage.csv*.  The markdown file *Figure_Fit.Rmd* generates the example states shown in Supplemental Figure S5 *FigS5.pdf* and the scatter plot of fit vs. data, Supplemental Figure S6 *FigS6.pdf*.

### Parameter posteriors and correlations

The markdown file *Figures_FitParameters.Rmd* generates Supplemental Figure 7 *FigS7_Priors_Posteriors_byState_07.22.pdf*, which is a comparison of prior and posterior distributions by states, for the prediction run through July 22.  

### Evaluating model and scenarios at July 22

For more detailed analysis, samples need to be obtained for state variables as well as parameters on July 22, so the script *run_plot_scenarios_OneTime.R* is run first to generate these values.  The markdown file *Figures_ReffRebound.Rmd* first generates Figure 2 with Reff(t) and the transmission rebound *Fig2_ReffRebound.pdf*.  The minimum values of Reff, along with the date it occurred, are tabulated in the file *ReffMin.csv*.  It also generates the ANOVA analysis of what are the greatest contributors to R(t) (*RefftANOVAtable.xlsx*) and the correlation plots in Extended Data Figure 1 (*ExtDat_Fig1_corr.2020.07.22.pdf*).  Next it generates the critical level of reopening permitted while keeping Reff(t)<1 under different scenarios, summarized Figure 4 *Fig4_DeltacritDeltaCurrent.2020.07.22.pdf*.  Finally, it generates the contour map of the combinations of testing and tracing that permit Reff(t) to be less then 1 at varying levels of confidence, summarized in Extended Data Figure 2 *ExtDat_Fig2_fC_lambda_Contour.2020.07.22.pdf*.

Additionally, the critical amounts of testing or tracing needed to reduce Reff(t) or R(t) with reopening below 1 are calculated in the markdown file *Figures_CritTestingTracing.Rmd*.  This generates Extended Data Figures 3 and 4 (*ExtDat_Fig3_TestingTracing.2020.07.22.pdf* and *ExtDat_Fig4_TestingTracingReopen.2020.07.22.pdf*, respectively).  The critical values are tabulated in CSV files *TestTraceCritValues.csv* and *RtReopen_TestTraceCritValues.csv*, with critical fold-change values in the CSV files .  For testing, an upper bound of 1 per day was enforced, and if the critical value exceeds this value, then an infinite value is substitituted, indicating that the level of testing is "impossible" to achieve. 

### Time-series predictions for Testing, Tracing, Re-opening Scenarios

To generate time-series predictions of the course of the epidemic under different testing, tracing, and re-opening scenarios, the script *run_plot_scenarios-all.R* should first be sourced to run all the scenarios.  This also generates Supplemental Figure S8 *FigS8_Scenarios_Results_All_2020-07-22.pdf*.

Then the markdown file *Figures_ScenarioPredictions.Rmd* first extracts the final reported case and death counts from each scenario, and the percent difference relative to the "baseline" scenario, putting the results graphically in *Fig_Scenarios_CumulPred_Oct01.pdf* and tabularly in *Fig_Scenarios_CumulPred_Oct01.csv*. It then generates the reopening examples in Figure 3 *Fig3ABCDcurrent_07_22-08-15.pdf*, as well as the mitigation map in Figure 5 *Fig5_RtMitigationNeed.pdf*, with the mitigation grades summarized in the file *RtMitigationGrades.csv*.

Note that Figures 1 and 5 are composites created in Powerpoint, and the Figure files created here are imported to Powerpoint to create them.

### Mobility data comparison

To generate the analysis comparing mobility data to posterior SEIR model distributions for relevant parameters, use the markdown file *Mobility Accuracy.Rmd* in the Mobility Metrics folder, which generates the figure file *MobilityFits.vs.Posterior.Distributions.pdf*, and serves as Figure S9.
