make_infile_template <- function(alldat.df,
                                 fips_table,
                                 state_abbr="TX",
                                 X_iter = "200000",
                                 X_print = "100",
                                 dayspredict = 90,
                                 datezero = "2019-12-31",
                                 datadatemax = "", 
                                 pathdir = state_abbr,
                                 usestatename = TRUE,
                                 createdir = TRUE,
                                 priordir = "priors",
                                 priorfile = "SEIR.reopen_priors_MCMC.in.R",
                                 usemobility = FALSE,
                                 mobilitydir = "MobilityMetrics",
                                 mobilityfile = "MobilityParmsSummaryByState.csv",
                                 isprior = FALSE,
                                 ### For scenarios
                                 check_template=FALSE,
                                 check_key="Scenario1"
)
{
  if (state_abbr != "US") {
    dat.df <- subset(alldat.df,state==state_abbr)
  } else {
    dat.df <- alldat.df
  }
  if (datadatemax != "") { # make data past datadatemax -1
    dat.df$value[dat.df$date > datadatemax] <- -1
  }
  firsttest <- min(dat.df$numDate)-1;
  numDates <- seq(1,max(dat.df$numDate))
  popnow <- fips_table[fips_table$Alpha.code==state_abbr,"pop"]
  statevars <- c("S","S_C",
                 "E","E_C",
                 "I_U","I_C","I_T",
                 "R_U","R_T","F_T");
  timedepvars <- c(
    "ThetaFit",
    "HygieneFit",
    "c",
    "beta",
    "rho",
    "lambda",
    "delta",
    "Rt",
    "Refft"
  )
  cumuls <- c("CumInfected", "CumPosTest", "CumDeath",
              "dtCumInfected", "dtCumPosTest", "dtCumDeath",
              "Tot"
  )
  if (!createdir) {
    pathdir = "."
  } else if (!dir.exists(pathdir)) {
    dir.create(pathdir)
  }
  if (!check_template) {
    if (usestatename) {
      infile_template <- file.path(
        pathdir,paste0("SEIR_",state_abbr,"_MCMC.in.R"))
    } else {
      infile_template <- file.path(
        pathdir,paste0("SEIR_onestate_MCMC.in.R"))
    }
  } else {
    if (usestatename) {
      infile_template <- file.path(
        pathdir,paste0("SEIR_",state_abbr,"_MCMC.",check_key,"check.in.R"))
    } else {
      infile_template <- file.path(
        pathdir,paste0("SEIR_onestate_MCMC.",check_key,"check.in.R"))
    }
  }
  if (isprior) {
    infile_template <- gsub("MCMC","MTC",infile_template)
  }
  priors <- readLines(file.path(priordir,priorfile))
  priors <- gsub(pattern = "X_iter",replacement = X_iter, x=priors)
  priors <- gsub(pattern = "X_print",replacement = X_print, x=priors)
  if (usemobility) {
    mobdat <- read.csv(file.path(mobilitydir,mobilityfile),as.is=TRUE)
    mobdat <- subset(mobdat,State.Abbr==state_abbr)
    rownames(mobdat)<-mobdat$variable
    parmnames <- data.frame(mobname=c("thetamin","tautheta","ntheta","taus","taur","rmax"),
                            priorname=c("ThetaMin","TauTheta","PwrTheta","TauS","TauR","rMax"),
                            stringsAsFactors = FALSE)
    statnames <- data.frame(mobname=c("value.mean","value.sd","value.0.","value.100."),
                            priorname=c("M","SD","MIN","MAX"),
                            stringsAsFactors = FALSE)
    for (j in 1:nrow(parmnames)) {
      for (k in 1:nrow(statnames)) {
        val <- mobdat[parmnames$mobname[j],statnames$mobname[k]]
        val <- max(val,0) # cannot be negative
        priors <- gsub(pattern = paste("X",statnames$priorname[k],
                                       parmnames$priorname[j],sep="_"),
                       replacement = signif(val,3),
                       x=priors)
      }
    }
  }
  cat(priors,sep="\n",file=infile_template)
  cat("    Simulation { #",state_abbr,"\n\n",file=infile_template,append=T);
  cat("      Npop =",popnow,";\n",file=infile_template,append=T);
  cat("      StartTime(60);\n\n",file=infile_template,append=T);
  if (isprior) {
    cat("      Print(NInit, 60.01);\n}\n",
        file=infile_template,append=T)
  } else {
    cat("      Print(N_pos,",subset(dat.df,variable=="positiveIncrease" &
                                      !is.na(value))$numDate,");\n",
        file=infile_template,append=T)
    cat("      Data(N_pos,",subset(dat.df,variable=="positiveIncrease" &
                                     !is.na(value))$value,");\n",
        file=infile_template,append=T)
    cat("      Print(p_N_pos,",subset(dat.df,variable=="positiveIncrease" &
                                        !is.na(value))$numDate,");\n",
        file=infile_template,append=T)
    cat("      Print(D_pos,",subset(dat.df,variable=="deathIncrease" &
                                      !is.na(value))$numDate,");\n",
        file=infile_template,append=T)
    cat("      Data(D_pos,",subset(dat.df,variable=="deathIncrease" &
                                     !is.na(value))$value,");\n",
        file=infile_template,append=T)
    cat("      Print(p_D_pos,",subset(dat.df,variable=="deathIncrease" &
                                        !is.na(value))$numDate,");\n",
        file=infile_template,append=T)
    for (v in c(statevars,cumuls,timedepvars)) {
      cat("      PrintStep(",v,", 60, ",max(numDates)+dayspredict,", 1);\n",
          file=infile_template,append=T)
    }
    cat("\n    }\n  }\n}\n",
        file=infile_template,append=T)
  }
  return(basename(infile_template))
}


make_infiles <- function(infile_template,
                         exe_file="mcsim.SEIR.model.R.exe",
                         chains=1:4,
                         randomseed=exp(1),
                         restartdir="",
                         useposterior=FALSE,
                         resultsdir="") {
  set.seed(randomseed)
  for (chainnum in chains) {
    tmp <- mcsim(exe_file = exe_file,
                 in_file = infile_template,
                 chainnum = chainnum,
                 runmodel=FALSE,
                 restartdir=restartdir,
                 resultsdir=resultsdir,
                 useposterior=useposterior)
  }
}
