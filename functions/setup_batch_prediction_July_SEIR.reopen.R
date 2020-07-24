library(tidyverse)
library(covid19us)
library(jsonlite)
library(rvest)
library(data.table)
library(RCurl)
functiondir <- "functions"
modeldir <- "model"
datezero <- "2019-12-31"
source(file.path(functiondir,"get_fips_function.R"))
source(file.path(functiondir,"get_testdata_functions.R"))
source(file.path(functiondir,"get_reopendata_function.R"))
source(file.path(functiondir,"make_infile_functions.R"))

mdir <- "MCSim"
source(here::here(mdir,"setup_MCSim.R"))
# Make mod.exe (used to create mcsim executable from model file)
makemod(here::here(mdir)) 
model_file<- "SEIR.reopen.model.R"
exe_file<-makemcsim(model_file,modeldir=modeldir)

run_chains <- function(infile_template,
                         exe_file="mcsim.SEIR.reopen.model.R.exe",
                         chains=1:4,
                         randomseed=exp(1)) {
  set.seed(randomseed)
  outdat.list <- list()
  for (chainnum in chains) {
    outdat.list <- c(outdat.list,mcsim(exe_file = exe_file,
                          in_file = infile_template,
                          chainnum = chainnum))
  }
  return(outdat.list)
}

make_jobfile <- function(state_abbr="TX",
                         pathdir = state_abbr,
                         folder = "SEIR",
                         exe_file="mcsim.SEIR.reopen.model.R",
                         domulticheck=TRUE,
                         functiondir="functions") {
  exe_file <- basename(exe_file)
  exe_file <- gsub(".exe","",exe_file)
  exe_file <- paste0("./",exe_file)
  checkinfiles <- list.files(path=pathdir,pattern=".check.in")
  infiles <- sub(".check.in",".in",checkinfiles)
  outfiles <- sub(".check.in",".out",checkinfiles)
  checkoutfiles <- sub(".check.in",".check.out",checkinfiles)
  jobfilename <- paste0("RunSEIR_",state_abbr,".jobfile")
  jobfilepath <- file.path(pathdir,jobfilename)
  # filetext <- readLines("RunSEIR_template.jobfile")
  filetext <- readLines(file.path(functiondir,"RunSEIR_ada_template.jobfile"))
  filetext <- gsub("testjob",jobfilename,filetext)
  cat(filetext,sep="\n",file=jobfilepath)
  cat("cd /scratch/user/wchiu/COVIDModeling/",
      folder,"/",state_abbr,"\npwd\n",sep="",
      file=jobfilepath,append=TRUE)
  for (j in 1:length(infiles)) {
    cat(exe_file,infiles[j],
        outfiles[j],"&\n",
        file=jobfilepath,append=TRUE)
  }
  for (j in 1:length(infiles)) {
    cat("wait\n",file=jobfilepath,append=TRUE)
  }
  for (j in 1:length(checkinfiles)) {
    cat(exe_file,checkinfiles[j],
        checkoutfiles[j],"&\n",
        file=jobfilepath,append=TRUE)
  }
  cat("module load R_tamu/3.6.2-intel-2019b-recommended-mt\n",
      file=jobfilepath,append=TRUE)
  cat("cp ../plot_parameter_results.R ./\n",file=jobfilepath,append=TRUE)
  cat("Rscript plot_parameter_results.R\n",file=jobfilepath,append=TRUE)
  if (domulticheck) {
    cat("cp ../run_batch_rhat_multicheck.R ./\n",file=jobfilepath,append=TRUE)
    cat("Rscript run_batch_rhat_multicheck.R\n",file=jobfilepath,append=TRUE)
  }
  #  cat("cp ../run_batch_scenarios.R ./\n",file=jobfilepath,append=TRUE)
  #  cat("Rscript run_batch_scenarios.R\n",file=jobfilepath,append=TRUE)
  return(jobfilename)
}

# ## Prediction - Run through 6/20 with re-opening - state-specific priors
# statenow <- "ALL"
# restartdir<-""
# useposterior <- FALSE
# batchdir <- "SEIR.reopen.state.2020.06.20"
# priorfile <- "SEIR.reopen_state_priors_MCMC.in.R"
# X_iter <- "200000"
# X_print <- "100"
# domulticheck <- TRUE
# valid <- TRUE
# validdate <- "2020-06-20"
# usemobility <- TRUE

## Prediction - Run through 7/22 with re-opening - state-specific priors
statenow <- "ALL"
restartdir<-""
useposterior <- FALSE
batchdir <- "SEIR.reopen.state.2020.07.22"
priorfile <- "SEIR.reopen_state_priors_MCMC.in.R"
X_iter <- "200000"
X_print <- "100"
domulticheck <- TRUE
valid <- TRUE
validdate <- "2020-07-22"
usemobility <- TRUE
mobilityfile <- "MobilityParmsSummaryByState-2020-07-21.csv"
###################
if (!dir.exists(batchdir)) system(paste("mkdir",batchdir))
# Model file
if (!file.exists(file.path(batchdir,model_file))) {
  system(paste("cp",file.path(modeldir,model_file),batchdir))
}
###################
# Run priors
resultsdir <- "TestRuns"
out_file0 <- file.path(resultsdir,"simMTC0.out")
if (!file.exists(out_file0)) {
  set.seed(exp(1))
  in_file0 <- "SEIR_Testing_MTC0.in.R" 
  out_dat0 <- mcsim(exe_file = exe_file,
                    in_file = in_file0,
                    out_file = out_file0,
                    resultsdir = resultsdir,
                    ignore.stdout = TRUE)
}
system(paste("cp",out_file0,batchdir,"\n"))
###################
# get FIPS
if (!file.exists(file.path("data","FIPS_TABLE.csv"))) {
  fips_table <- get_fips()
  write.csv(fips_table,file=file.path("data","FIPS_TABLE.csv"),row.names = FALSE)
}
system(paste("cp",file.path("data","FIPS_TABLE.csv"),batchdir))
fips_table <- read.csv(file.path(batchdir,"FIPS_TABLE.csv"),colClasses=c(
  rep("character",4),rep("numeric",2)
))
###################
# get reopening data
reopen.df <- get_reopendata()
###################
# get testing data
if (!file.exists(file.path(batchdir,"DAILYTESTDATA.csv"))) {
  dat.df <- get_testdata()
  write.csv(dat.df,file.path(batchdir,"DAILYTESTDATA.csv"),row.names = FALSE)
}
dat.df <- read.csv(file.path(batchdir,"DAILYTESTDATA.csv"),
                   colClasses=c("Date","numeric","character",
                                "numeric","character","numeric"))
if (!file.exists(file.path(batchdir,"CUMULTESTDATA.csv"))) {
  cumdat.df <- get_cumul_testdata()
  write.csv(cumdat.df,file.path(batchdir,"CUMULTESTDATA.csv"),row.names = FALSE)
}
cumdat.df <- read.csv(file.path(batchdir,"CUMULTESTDATA.csv"),
                      colClasses=c("Date","numeric","character",
                                   "numeric","character","numeric"))
###################
# Make shell file and everything else
shellfile <- file.path(batchdir,"SEIR_run_all.sh")
cat("#!/bin/bash\n",file=shellfile)
# cat("cp ../*.R ./\ncp ../FIPS_TABLE.csv ./\n",file=shellfile,append=TRUE)
if (restartdir != "") { # Don't use previous restart kernel!
  cat("rm ../",basename(restartdir),"/*/*.kernel\n",sep="",
      file=shellfile,append=TRUE)
}
if (statenow == "ALL") statevec <- fips_table$Alpha.code[2:52] else statevec <- statenow
for (statenow in statevec) {
  if (valid) {
    datadatemax <- validdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  prior_template <- make_infile_template(dat.df,
                                         fips_table,
                                         state_abbr=statenow,
                                         usestatename = TRUE,
                                         createdir = TRUE,
                                         pathdir = file.path(batchdir,statenow),
                                         X_iter = X_iter,
                                         X_print = X_print,
                                         datadatemax=datadatemax,             
                                         priorfile = gsub("MCMC","MTC",priorfile),
                                         usemobility = usemobility,
                                         mobilitydir = "MobilityMetrics",
                                         mobilityfile = mobilityfile,
                                         isprior = TRUE
  )
  set.seed(exp(1))
  prior_dat <- mcsim(exe_file = exe_file,
                     in_file = prior_template,
                     out_file = file.path(batchdir,statenow,
                                          gsub(".in.R",".out",prior_template)),
                     resultsdir = file.path(batchdir,statenow)
                     )
  # infile_template <- make_infile_template(dat.df,
  #                                         fips_table,
  #                                         state_abbr=statenow,
  #                                         usestatename = TRUE,
  #                                         createdir = TRUE,
  #                                         pathdir = file.path(batchdir,statenow),
  #                                         X_iter = X_iter,
  #                                         X_print = X_print,
  #                                         datadatemax=datadatemax,
  #                                         priorfile = priorfile
  #                                         )
  infile_template <- make_infile_template(dat.df,
                                          fips_table,
                                          state_abbr=statenow,
                                          usestatename = TRUE,
                                          createdir = TRUE,
                                          pathdir = file.path(batchdir,statenow),
                                          X_iter = X_iter,
                                          X_print = X_print,
                                          datadatemax=datadatemax,
                                          priorfile = priorfile,
                                          usemobility = usemobility,
                                          mobilitydir = "MobilityMetrics",
                                          mobilityfile = mobilityfile
  )
  make_infiles(infile_template,
               restartdir = restartdir,
               exe_file=exe_file,
               chains=1:4,
               useposterior=useposterior,
               resultsdir=file.path(batchdir,statenow),
               randomseed=3.1415927)
  jobfilename <- make_jobfile(state_abbr=statenow,
                              pathdir = file.path(batchdir,statenow),
                              folder = batchdir,
                              exe_file=exe_file,
                              domulticheck=domulticheck)
  cat("cp mcsim.SEIR.reopen.model.R",statenow,"\n",
      file=shellfile,append=TRUE)
  cat("cd",statenow,"\n","bsub <",jobfilename,"\n","cd ..\n",
      file=shellfile,append=TRUE)

}

system(paste("cp",file.path(modeldir,model_file),batchdir))
system(paste("cp",file.path(functiondir,"run_batch_rhat_multicheck.R"),batchdir))
system(paste("cp",file.path(functiondir,"plot_parameter_results.R"),batchdir))
system(paste("tar -czvf",paste0(batchdir,".tgz"),batchdir))
system(paste("mv",paste0(batchdir,".tgz"),"/Users/wchiu/Desktop/COVID-SendToRun"))

