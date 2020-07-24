library(tidyverse)
library(covid19us)
library(jsonlite)
library(rvest)
library(data.table)
library(RCurl)

run_setpoints1 <- function(fips_table,
                                    state_abbr="TX",
                                    TPrint="2020-06-20",
                                    pathdir="SEIR.reopen.state.2020.06.20",
                                    scenariosdir="scenarios",
                                    scenariostemplate=
                                      "SEIR.reopen_state_setpoints1_MCMC.in.R",
                                    scenarioname = "OneTime",
                                    nruns = 0,
                                    keepoutfile = TRUE,
                                    datezero = "2019-12-31",
                           exe_file="mcsim.SEIR.scenarios.model.R.exe") {
  
  numDate <- as.numeric(as.Date(TPrint))-as.numeric(as.Date(datezero))
  popnow <- fips_table[fips_table$Alpha.code==state_abbr,"pop"]
  
  template <- readLines(file.path(scenariosdir,scenariostemplate))
  
  # File names
  in_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_",scenarioname,".in"))
  out_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_",scenarioname,".out"))
  quantfile <-paste0(gsub(".in",".quantiles.csv",in_file))
  setpoints_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_MCMC1234.samps.out"))
  template <- gsub(pattern = "X_outfile",out_file,x=template)
  template <- gsub(pattern = "X_setpoints",setpoints_file,x=template)
  template <- gsub(pattern = "X_nRuns",nruns,x=template)
  # State and population
  template <- gsub(pattern = "X_State",replacement = state_abbr, x=template)
  template <- gsub(pattern = "X_Npop",replacement = popnow, x=template)
  template <- gsub(pattern = "T_Print",replacement = numDate, x=template)

  # Write infile
  writeLines(template, con=paste0(in_file))
  simfiles<-c(in_file,out_file,setpoints_file)
  names(simfiles)<-c("in_file","out_file","setpoints_file")
  # Run model
  out_dat <- mcsim(exe_file = exe_file,
                   in_file = simfiles["in_file"],
                   out_file = simfiles["out_file"],
                   setpoints_file = simfiles["setpoints_file"],
                   resultsdir = ".")
  if (!keepoutfile) system(paste("rm",simfiles["out_file"]))
  # convert output to data frame
  varlist <- data.table(cbind(names(out_dat),
                              str_split(names(out_dat),"_1.",simplify = TRUE)))
  names(varlist)<-c("variable","Output_Var","Time")
  varlist$Time<-as.numeric(varlist$Time)
  setkey(varlist,variable)
  out_dat.df <- melt(as.data.table(out_dat),id.vars=1,variable.factor = FALSE)
  out_dat.df$Output_Var <- varlist[out_dat.df$variable,"Output_Var"]
  out_dat.df$Time <- varlist[out_dat.df$variable,"Time"]
  names(out_dat.df)[names(out_dat.df)=="value"] <- "Prediction"
  # Output list
  output <- list(simfiles=simfiles,out_dat=out_dat,out_dat.df=out_dat.df)
  out_quant <-as.data.table(aggregate(Prediction~Time+Output_Var,
                                      output$out_dat.df,
                                      quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
  write.csv(out_quant,file=paste0(
    gsub(".in",".quantiles.csv",output$simfiles["in_file"])),row.names = FALSE)
  output <- c(output,list(out_quant=out_quant))
  return(output)
}

run_setpoints <- function(fips_table,
                           state_abbr="TX",
                           TPrint="2020-08-31",
                           pathdir="SEIR.reopen.state.2020.06.20",
                           scenariosdir="scenarios",
                           scenariostemplate=
                             "SEIR.reopen_state_setpoints_MCMC.in.R",
                           scenarioname = "TimeSeries",
                           nruns = 0,
                           keepoutfile = TRUE,
                           scenstartdate = "2020-07-01",
                           rampuptime = 14,
                           mu_Lambda = 1,
                           mu_C = 1,
                           DeltaDelta = 0,
                           datezero = "2019-12-31",
                          exe_file="mcsim.SEIR.scenarios.model.R.exe") {
  
  numDate <- as.numeric(as.Date(TPrint))-as.numeric(as.Date(datezero))
  scennumDate <- as.numeric(as.Date(scenstartdate))-as.numeric(as.Date(datezero))
  popnow <- fips_table[fips_table$Alpha.code==state_abbr,"pop"]
  
  template <- readLines(file.path(scenariosdir,scenariostemplate))
  
  # File names
  in_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_",scenarioname,".in"))
  out_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_",scenarioname,".out"))
  quantfile <-paste0(gsub(".in",".quantiles.csv",in_file))
  setpoints_file <- file.path(
    pathdir,state_abbr,paste0("SEIR_",state_abbr,"_MCMC1234.samps.out"))
  template <- gsub(pattern = "X_outfile",out_file,x=template)
  template <- gsub(pattern = "X_setpoints",setpoints_file,x=template)
  template <- gsub(pattern = "X_nRuns",nruns,x=template)
  # State and population
  template <- gsub(pattern = "X_State",replacement = state_abbr, x=template)
  template <- gsub(pattern = "X_Npop",replacement = popnow, x=template)

  Tvec <- c(0,seq(scennumDate,scennumDate+rampuptime))
  strTvec <- paste(Tvec,collapse=" , ")
  Nvec <- length(Tvec)
  strNvec <- as.character(Nvec)
  muLvec <- c(-1, 1 + (mu_Lambda-1)*seq(0,1,length.out=(Nvec-1)))
  muCvec <- c(-1, 1 + (mu_C-1)*seq(0,1,length.out=(Nvec-1)))
  DeltaDeltavec <- c(-1, DeltaDelta*seq(0,1,length.out=(Nvec-1)))
  strmuLvec <- paste(muLvec,collapse=" , ")
  strmuCvec <- paste(muCvec,collapse=" , ")
  strDeltaDeltavec <- paste(DeltaDeltavec,collapse=" , ")
  template <- gsub(pattern = "N_MuLambda", replacement = strNvec, x = template)
  template <- gsub(pattern = "N_MuC", replacement = strNvec, x = template)
  template <- gsub(pattern = "N_DeltaDelta", replacement = strNvec, x = template)
  template <- gsub(pattern = "Y_MuLambda", replacement = strmuLvec,  x = template)
  template <- gsub(pattern = "Y_MuC", replacement = strmuCvec, x = template)
  template <- gsub(pattern = "Y_DeltaDelta", replacement = strDeltaDeltavec, x = template)
  template <- gsub(pattern = "T_MuLambda", replacement = strTvec, x = template)
  template <- gsub(pattern = "T_MuC", replacement = strTvec, x = template)
  template <- gsub(pattern = "T_DeltaDelta", replacement = strTvec,  x = template)
  
  template <- gsub(pattern = "T_Print",replacement = numDate, x=template)
  
  # Write infile
  writeLines(template, con=paste0(in_file))
  simfiles<-c(in_file,out_file,setpoints_file)
  names(simfiles)<-c("in_file","out_file","setpoints_file")
  # Run model
  out_dat <- mcsim(exe_file = exe_file,
                   in_file = simfiles["in_file"],
                   out_file = simfiles["out_file"],
                   setpoints_file = simfiles["setpoints_file"],
                   resultsdir = ".")
  if (!keepoutfile) system(paste("rm",simfiles["out_file"]))
  # convert output to data frame
  varlist <- data.table(cbind(names(out_dat),
                              str_split(names(out_dat),"_1.",simplify = TRUE)))
  names(varlist)<-c("variable","Output_Var","Time")
  varlist$Time<-as.numeric(varlist$Time)
  setkey(varlist,variable)
  out_dat.df <- melt(as.data.table(out_dat),id.vars=1,variable.factor = FALSE)
  out_dat.df$Output_Var <- varlist[out_dat.df$variable,"Output_Var"]
  out_dat.df$Time <- varlist[out_dat.df$variable,"Time"]
  names(out_dat.df)[names(out_dat.df)=="value"] <- "Prediction"
  # Output list
  output <- list(simfiles=simfiles,out_dat=out_dat,out_dat.df=out_dat.df)
  out_quant <-as.data.table(aggregate(Prediction~Time+Output_Var,
                                      output$out_dat.df,
                                      quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
  write.csv(out_quant,file=paste0(
    gsub(".in",".quantiles.csv",output$simfiles["in_file"])),row.names = FALSE)
  output <- c(output,list(out_quant=out_quant))
  return(output)
}


plot_scenario <- function(alldat.df,out_quant,state_abbr="TX",
                          datezero="2019-12-31",
                          datadatemax="2020-06-20",
                          datemaxplot="2020-08-31",
                          scenarioname="",
                          tstart=60,logy=TRUE) {
  obsnames <- c("Daily reported cases","Daily confirmed deaths")
  names(obsnames) <- c("positiveIncrease","deathIncrease")
  out_quant$Output_Var[out_quant$Output_Var=="N_pos"] <- "positiveIncrease"
  out_quant$Output_Var[out_quant$Output_Var=="D_pos"] <- "deathIncrease"
  out_quant$Date <- as.Date(out_quant$Time+tstart,origin=as.Date(datezero))
  dat.df <- subset(alldat.df,state==state_abbr)
  names(dat.df)[names(dat.df)=="variable"] <- "Output_Var"
  names(dat.df)[names(dat.df)=="value"] <- "Data"
  obsdat<-subset(dat.df,state==state_abbr & (
    Output_Var == "positiveIncrease" | Output_Var == "deathIncrease"
  )) 
  # clip
  out_quant$Prediction.2.5.[out_quant$Prediction.2.5.<0.1]<-0.1
  out_quant$Prediction.97.5.[out_quant$Prediction.97.5.<0.1]<-0.1
  out_quant$Prediction.25.[out_quant$Prediction.25.<0.1]<-0.1
  out_quant$Prediction.50.[out_quant$Prediction.50.<0.1]<-0.1
  out_quant$Prediction.75.[out_quant$Prediction.75.<0.1]<-0.1
  p<-ggplot(subset(out_quant,Output_Var=="positiveIncrease" | Output_Var=="deathIncrease"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    #geom_point(aes(x=date,y=Data),data=obsdat)+
    geom_col(aes(x=date,y=Data),data=obsdat)+
    geom_vline(xintercept=as.Date(datadatemax),
               linetype="dotted",color="grey")+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    labs(fill="",linetype="Prediction")+
    scale_x_date(date_minor_breaks = "1 day",
                 date_breaks="1 month",
                 date_labels = "%b",
                 limits=c(min(obsdat$date),as.Date(datemaxplot)))+
    facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
               labeller = labeller(Output_Var = obsnames)) +
    theme_bw()+theme(legend.position = "bottom") +
    ggtitle(paste(state_abbr,scenarioname))
  if (logy) {
    p<-p+scale_y_log10(breaks=10^(-1:10),limits=c(0.1,NA),
                       expand = expand_scale(mult = 0))+
            annotation_logticks(sides="l")
  }
  print(p)
  return(p)
}





