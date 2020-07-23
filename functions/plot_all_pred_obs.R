library(ggplot2)
library(stringr)
library(data.table)
library(RCurl)
functiondir <- "functions"
source(file.path(functiondir,"get_fips_function.R"))
source(file.path(functiondir,"get_reopendata_function.R"))
source(file.path(functiondir,"get_testdata_functions.R"))

datezero <- '2019-12-31'
cumpreddatemax <- "2020-08-31"

# folder <- "SEIR.constant.valid"
# calibdate <- "2020-04-01"
# novalid <- FALSE
# validdate <- "2020-04-30"
# folder <- "SEIR.constant.shelter"
# novalid <- FALSE
# calibdate <- ""
# validdate <- "2020-06-06"

# folder <- "SEIR.reopen.2020.06.05"
# calibdate <- "2020-06-05"
# novalid <- FALSE
# validdate <- "2020-06-10"

# folder <- "SEIR.reopen.2020.04.30"
# calibdate <- "2020-04-30"
# novalid <- FALSE
# validdate <- "2020-06-13"

# folder <- "SEIR.reopen.2020.05.15"
# calibdate <- "2020-05-15"
# novalid <- FALSE
# validdate <- "2020-06-13"

# folder <- "SEIR.reopen.2020.06.13"
# calibdate <- "2020-06-13"
# novalid <- FALSE
# validdate <- "2020-06-13"

# folder <- "SEIR.reopen.state.2020.04.30"
# calibdate <- "2020-04-30"
# novalid <- FALSE
# validdate <- "2020-06-20"

# folder <- "SEIR.reopen.state.2020.06.20"
# calibdate <- "2020-06-20"
# novalid <- FALSE
# validdate <- "2020-06-20"

# folder <- "SEIR.reopen.state.2020.05.15"
# calibdate <- "2020-05-15"
# novalid <- FALSE
# validdate <- "2020-06-20"

# folder <- "SEIR.reopen.state.alt.2020.04.30"
# calibdate <- "2020-04-30"
# novalid <- FALSE
# validdate <- "2020-06-20"

# folder <- "SEIR.reopen.state.alt.2020.06.20"
# calibdate <- "2020-06-20"
# novalid <- FALSE
# validdate <- "2020-06-20"

# folder <- "SEIR.reopen.alt.2020.04.30"
# calibdate <- "2020-04-30"
# novalid <- FALSE
# validdate <- "2020-06-20"
# 
folder <- "SEIR.reopen.state.2020.06.20"
calibdate <- "2020-06-20"
novalid <- FALSE
validdate <- "2020-07-22"

# folder <- "SEIR.reopen.alt2.2020.04.30"
# calibdate <- "2020-04-30"
# novalid <- FALSE
# validdate <- "2020-06-20"

fips_table <- read.csv(file.path(folder,"FIPS_TABLE.csv"),colClasses=c(
  rep("character",4),rep("numeric",2)
))

reopen.df <- get_reopendata()

## Read prediction files
csvfiles <- character()
for (statenow in fips_table$Alpha.code[2:52]) {
  csvfiles <- c(csvfiles,
                list.files(path=file.path(folder,statenow),
                           pattern="*prediction.quantiles.csv",
                         full.names=TRUE))
}
csvfiles <- csvfiles[!grepl("Scen",csvfiles)]
preddat.list <- list()
for (j in 1:length(csvfiles)) {
  preddat.list[[j]] <- read.csv(csvfiles[[j]],as.is=TRUE)
}
## Read data files
dat.df <- get_testdata(remove_zero_value = FALSE)
#dat.df <- read.csv(file.path(folder,"DAILYTESTDATA.csv"))
dat.df$Date <- as.Date(dat.df$numDate,origin=as.Date(datezero))
names(dat.df)[names(dat.df)=="variable"] <- "Output_Var"
names(dat.df)[names(dat.df)=="value"] <- "Data"

meandat.df <- get_meantestdata()
meandat.df$Date <- as.Date(meandat.df$numDate,origin=as.Date(datezero))
names(meandat.df)[names(meandat.df)=="variable"] <- "Output_Var"
names(meandat.df)[names(meandat.df)=="value"] <- "Data"

# udata.df <- read.csv(file.path(folder,"UDATA.csv"),as.is=TRUE)
# udata.df$Date <- as.Date(udata.df$numDate,origin=as.Date(datezero))
# names(udata.df)[names(udata.df)=="value"]<-"Data"
cumdat.df <- read.csv(file.path(folder,"CUMULTESTDATA.csv"))
cumdat.df$Date <- as.Date(cumdat.df$numDate,origin=as.Date(datezero))
names(cumdat.df)[names(cumdat.df)=="variable"] <- "Output_Var"
names(cumdat.df)[names(cumdat.df)=="value"] <- "Data"
if (novalid) {
  dat.df <- subset(dat.df,Date <= as.Date(datadatemax))
  cumdat.df <- subset(cumdat.df,Date <= as.Date(datadatemax))
} else {
  dat.df <- subset(dat.df,Date <= as.Date(validdate))
  cumdat.df <- subset(cumdat.df,Date <= as.Date(validdate))
}

## Observed/predicted daily
obsnames <- c("Daily reported cases","Daily confirmed deaths")
names(obsnames) <- c("positiveIncrease","deathIncrease")
calibvalid.dat <- data.frame()
pdf(file=file.path(folder,"Daily-obs-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="N_pos"] <- "positiveIncrease"
  preddat$Output_Var[preddat$Output_Var=="D_pos"] <- "deathIncrease"
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  obsdat<-subset(dat.df,state==statenow & (
    Output_Var == "positiveIncrease" | Output_Var == "deathIncrease" ))
  obsdat$Training <- obsdat$Date <= datadatemax
  tmpdat<-subset(preddat,Output_Var=="positiveIncrease" | Output_Var=="deathIncrease")
  tmpdat$Prediction.2.5.[tmpdat$Prediction.2.5.<0.1]<-0.1
  tmpdat$Prediction.25.[tmpdat$Prediction.25.<0.1]<-0.1
  tmpdat$Prediction.50.[tmpdat$Prediction.50.<0.1]<-0.1
  tmpdat$Prediction.75.[tmpdat$Prediction.75.<0.1]<-0.1
  tmpdat$Prediction.97.5.[tmpdat$Prediction.97.5.<0.1]<-0.1
  p<-ggplot(tmpdat)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+
       facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
                  labeller = labeller(Output_Var = obsnames)) +
    ggtitle(paste(statenow,"Daily Predicted-Observed"))
  if (datadatemax < max(dat.df$Date)) {
    print(p + geom_point(aes(x=Date,y=Data,
                                 alpha=Training),data=obsdat)+
            geom_vline(xintercept=as.Date(datadatemax),
                         linetype="dotted",color="grey") +
            scale_alpha_discrete(range=c(0.4,1))+scale_y_log10()+
            labs(fill="",linetype="Prediction")+
            guides(alpha = guide_legend(order=1),
                   linetype = guide_legend(order = 2),
                   fill = guide_legend(order = 3)))
  } else {
    print(p + geom_point(aes(x=Date,y=Data,shape=""),data=obsdat)+
            scale_y_log10()+
            labs(fill="",shape="Data",linetype="Prediction")+
            guides(shape = guide_legend(order = 1),
                   linetype = guide_legend(order = 2),
                   fill = guide_legend(order = 3)))
  }
  meanobsdat<-subset(meandat.df,state==statenow & (
    Output_Var == "meanpositiveIncrease" | Output_Var == "meandeathIncrease" ))
  meanobsdat$Training <- meanobsdat$Date <= datadatemax
  meanobsdat$Output_Var <- gsub("mean","",meanobsdat$Output_Var)
  calibvalid.dat <- rbind(calibvalid.dat,
                     merge(meanobsdat[,c("state","Date","Output_Var","Data","Training")],
                           preddat[,c("Date","Output_Var","Prediction.2.5.",
                                      "Prediction.25.",
                                      "Prediction.50.",
                                      "Prediction.75.",
                                      "Prediction.97.5.")]))
}
dev.off()

## Observed/predicted daily bar nolog
obsnames <- c("Daily reported cases","Daily confirmed deaths")
names(obsnames) <- c("positiveIncrease","deathIncrease")
pdf(file=file.path(folder,"Daily-obs-pred-barchart.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="N_pos"] <- "positiveIncrease"
  preddat$Output_Var[preddat$Output_Var=="D_pos"] <- "deathIncrease"
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  obsdat<-subset(dat.df,state==statenow & (
    Output_Var == "positiveIncrease" | Output_Var == "deathIncrease"
  )) 
  obsdat$Training <- obsdat$Date <= datadatemax
  tmpdat<-subset(preddat,Output_Var=="positiveIncrease" | Output_Var=="deathIncrease")
  tmpdat$Prediction.2.5.[tmpdat$Prediction.2.5.<0.1]<-0.1
  tmpdat$Prediction.25.[tmpdat$Prediction.25.<0.1]<-0.1
  tmpdat$Prediction.50.[tmpdat$Prediction.50.<0.1]<-0.1
  tmpdat$Prediction.75.[tmpdat$Prediction.75.<0.1]<-0.1
  tmpdat$Prediction.97.5.[tmpdat$Prediction.97.5.<0.1]<-0.1
  tmpdat$Training <- tmpdat$Date <= datadatemax
  p<-ggplot(tmpdat)+
    geom_col(aes(x=Date,y=Data,alpha=Training),data=obsdat)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"),
                alpha=0.6)+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"),
                alpha=0.6)+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"),
              alpha=0.6)+
    geom_vline(xintercept=as.Date(datadatemax),
               linetype="dotted") +
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+
    scale_alpha_discrete(range=c(0.4,0.9))+
    facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
               labeller = labeller(Output_Var = obsnames)) +
    labs(fill="",linetype="Prediction")+
    guides(alpha = guide_legend(order=1),
           linetype = guide_legend(order = 2),
           fill = guide_legend(order = 3))+
    ggtitle(paste(statenow,"Daily Predicted-Observed"))
  print(p)
}
dev.off()

if (!novalid) {
  ## Observed/predicted daily - coverage
  calibvalid.dat$Training<-ifelse(calibvalid.dat$Training,"Training",
                                     "Validation")
  calibvalid.dat$Training<-factor(calibvalid.dat$Training,levels=c("Training",
                                                                         "Validation"))
  calibvalid.dat$in.IQR <- calibvalid.dat$Data >= calibvalid.dat$Prediction.25. & 
    calibvalid.dat$Data <= calibvalid.dat$Prediction.75.
  calibvalid.dat$in.CI <- calibvalid.dat$Data >= calibvalid.dat$Prediction.2.5. & 
    calibvalid.dat$Data <= calibvalid.dat$Prediction.97.5.
  write.csv(calibvalid.dat,file=file.path(folder,"DailyTrainingValidation.csv"))
  vplotCI <- ggplot(calibvalid.dat)+geom_bar(aes(x=Date,fill=in.CI,
                                                 alpha=Training),position="fill")+
    ylab("Fraction")+scale_fill_viridis_d(end=0.7) + geom_hline(yintercept=0.95,color="grey")+
    scale_alpha_discrete(range=c(1,0.4))+
    facet_wrap(~Output_Var)
  vplotIQR <- ggplot(calibvalid.dat)+geom_bar(aes(x=Date,fill=in.IQR,
                                                  alpha=Training),position="fill")+
    ylab("Fraction")+scale_fill_viridis_d(end=0.7) + geom_hline(yintercept=0.5,color="grey")+
    scale_alpha_discrete(range=c(1,0.4))+facet_wrap(~Output_Var)
  pdf(file=file.path(folder,"DailyTrainingValidation.pdf"),height=4,width=6)
  print(vplotCI)
  print(vplotIQR)
  dev.off()
}

## Predicted daily 
pdf(file=file.path(folder,"Daily-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="dtCumInfected"] <- "infected"
  preddat$Output_Var[preddat$Output_Var=="dtCumDeath"] <- "death"
  prednames <- c("Daily Infected","Daily Deaths")
  names(prednames) <- c("infected","death")
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  popnow <- fips_table$pop[fips_table$Alpha.code==statenow]
  preddat$Prediction.2.5. <- preddat$Prediction.2.5.* popnow
  preddat$Prediction.25. <- preddat$Prediction.25.* popnow
  preddat$Prediction.50. <- preddat$Prediction.50.* popnow
  preddat$Prediction.75. <- preddat$Prediction.75.* popnow
  preddat$Prediction.97.5. <- preddat$Prediction.97.5.* popnow
  preddat$Prediction.2.5.[preddat$Prediction.2.5.<1] <- 1
  preddat$Prediction.25.[preddat$Prediction.25.<1] <- 1
  preddat$Prediction.50.[preddat$Prediction.50.<1] <- 1
  preddat$Prediction.75.[preddat$Prediction.75.<1] <- 1
  preddat$Prediction.97.5.[preddat$Prediction.97.5.<1] <- 1
  tmp<-subset(preddat,Output_Var=="infected" | Output_Var=="death")
  p<-ggplot(tmp)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",shape="Data",linetype="Prediction")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+
    geom_vline(xintercept = as.Date(datadatemax),color="grey",linetype="dotted")+
    facet_wrap(~Output_Var,ncol=2,dir="v",scales="free_y",
               labeller = labeller(Output_Var = prednames)) +
    ggtitle(paste(statenow,"Daily Predicted"))
  print(p)
  print(p+scale_y_log10())
}
dev.off()


## Observed/predicted cumulative 
cumnames <- c("Total Positive Tests","Total Confirmed Deaths")
names(cumnames) <- c("positive","death")
cumcalibvalid.dat <- data.frame()
pdf(file=file.path(folder,"Cumulative-obs-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="CumPosTest"] <- "positive"
  preddat$Output_Var[preddat$Output_Var=="CumDeath"] <- "death"
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  preddat <- subset(preddat,Date <= cumpreddatemax)
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  popnow <- fips_table$pop[fips_table$Alpha.code==statenow]
  preddat$Prediction.2.5. <- preddat$Prediction.2.5.* popnow
  preddat$Prediction.25. <- preddat$Prediction.25.* popnow
  preddat$Prediction.50. <- preddat$Prediction.50.* popnow
  preddat$Prediction.75. <- preddat$Prediction.75.* popnow
  preddat$Prediction.97.5. <- preddat$Prediction.97.5.* popnow
  preddat$Prediction.2.5.[preddat$Prediction.2.5.<0.1] <- 0.1
  preddat$Prediction.25.[preddat$Prediction.25.<0.1] <- 0.1
  preddat$Prediction.50.[preddat$Prediction.50.<0.1] <- 0.1
  preddat$Prediction.75.[preddat$Prediction.75.<0.1] <- 0.1
  preddat$Prediction.97.5.[preddat$Prediction.97.5.<0.1] <- 0.1
  obsdat<-subset(cumdat.df,state==statenow & (
    Output_Var == "positive" | Output_Var == "death"
  )) 
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  obsdat$Training <- obsdat$Date <= datadatemax
  p<-ggplot(subset(preddat,Output_Var=="positive" | Output_Var=="death"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",shape="Data",linetype="Prediction")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+
    facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
               labeller = labeller(Output_Var = cumnames)) +
    ggtitle(paste(statenow,"Cumulative Observed-Predicted"))
  if (datadatemax < max(dat.df$Date)) {
    print(p + geom_point(aes(x=Date,y=Data,
                             alpha=Training),data=obsdat)+
            geom_vline(xintercept=as.Date(datadatemax),
                       linetype="dotted",color="grey") +
            scale_alpha_discrete(range=c(0.1,1))+scale_y_log10(limits=c(1,NA))+
            labs(fill="",linetype="Prediction")+
            guides(alpha = guide_legend(order=1),
                   linetype = guide_legend(order = 2),
                   fill = guide_legend(order = 3)))
  } else {
    print(p + geom_point(aes(x=Date,y=Data,shape=""),data=obsdat)+
            scale_y_log10(limits=c(1,NA))+
            labs(fill="",shape="Data",linetype="Prediction")+
            guides(shape = guide_legend(order=1),
                   linetype = guide_legend(order = 2),
                   fill = guide_legend(order = 3)))
  }
  cumcalibvalid.dat <- rbind(cumcalibvalid.dat,
                        merge(obsdat[,c("state","Date","Output_Var","Data","Training")],
                              preddat[,c("Date","Output_Var","Prediction.2.5.",
                                         "Prediction.25.",
                                         "Prediction.50.",
                                         "Prediction.75.",
                                         "Prediction.97.5.")]))
}
dev.off()

## Observed/predicted cumulative barchart
cumnames <- c("Total Positive Tests","Total Confirmed Deaths")
names(cumnames) <- c("positive","death")
cumcalibvalid.dat <- data.frame()
pdf(file=file.path(folder,"Cumulative-obs-pred-barchart.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="CumPosTest"] <- "positive"
  preddat$Output_Var[preddat$Output_Var=="CumDeath"] <- "death"
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  preddat <- subset(preddat,Date <= cumpreddatemax)
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  popnow <- fips_table$pop[fips_table$Alpha.code==statenow]
  preddat$Prediction.2.5. <- preddat$Prediction.2.5.* popnow
  preddat$Prediction.25. <- preddat$Prediction.25.* popnow
  preddat$Prediction.50. <- preddat$Prediction.50.* popnow
  preddat$Prediction.75. <- preddat$Prediction.75.* popnow
  preddat$Prediction.97.5. <- preddat$Prediction.97.5.* popnow
  preddat$Prediction.2.5.[preddat$Prediction.2.5.<0.1] <- 0.1
  preddat$Prediction.25.[preddat$Prediction.25.<0.1] <- 0.1
  preddat$Prediction.50.[preddat$Prediction.50.<0.1] <- 0.1
  preddat$Prediction.75.[preddat$Prediction.75.<0.1] <- 0.1
  preddat$Prediction.97.5.[preddat$Prediction.97.5.<0.1] <- 0.1
  obsdat<-subset(cumdat.df,state==statenow & (
    Output_Var == "positive" | Output_Var == "death"
  )) 
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  obsdat$Training <- obsdat$Date <= datadatemax
  
  p<-ggplot(subset(preddat,Output_Var=="positive" | Output_Var=="death"))+
    geom_col(aes(x=Date,y=Data,alpha=Training),data=obsdat)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"),
                alpha=0.5)+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"),
                alpha=0.5)+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    geom_vline(xintercept=as.Date(datadatemax),
               linetype="dotted") +
    labs(fill="",linetype="Prediction")+
    guides(alpha = guide_legend(order=1),
           linetype = guide_legend(order = 2),
           fill = guide_legend(order = 3))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+
    scale_alpha_discrete(range=c(0.4,1.0))+
    facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
               labeller = labeller(Output_Var = cumnames)) +
    ggtitle(paste(statenow,"Cumulative Observed-Predicted"))
  print(p)
  cumcalibvalid.dat <- rbind(cumcalibvalid.dat,
                             merge(obsdat[,c("state","Date","Output_Var","Data","Training")],
                                   preddat[,c("Date","Output_Var","Prediction.2.5.",
                                              "Prediction.25.",
                                              "Prediction.50.",
                                              "Prediction.75.",
                                              "Prediction.97.5.")]))
}
dev.off()



## Observed/predicted cumulative - Training & validation
if (!novalid) {
  cumcalibvalid.dat$Training<-ifelse(cumcalibvalid.dat$Training,"Training",
                                     "Validation")
  cumcalibvalid.dat$Training<-factor(cumcalibvalid.dat$Training,levels=c("Training",
                                                                         "Validation"))
  cumcalibvalid.dat$in.IQR <- cumcalibvalid.dat$Data >= cumcalibvalid.dat$Prediction.25. & 
    cumcalibvalid.dat$Data <= cumcalibvalid.dat$Prediction.75.
  cumcalibvalid.dat$in.CI <- cumcalibvalid.dat$Data >= cumcalibvalid.dat$Prediction.2.5. & 
    cumcalibvalid.dat$Data <= cumcalibvalid.dat$Prediction.97.5.
  write.csv(cumcalibvalid.dat,file=file.path(folder,"CumulativeTrainingValidation.csv"))
  vplotCI <- ggplot(cumcalibvalid.dat)+geom_bar(aes(x=Date,fill=in.CI,
                                                 alpha=Training),position="fill")+
    ylab("Fraction")+scale_fill_viridis_d(end=0.7) + geom_hline(yintercept=0.95,color="grey")+
    scale_alpha_discrete(range=c(1,0.4))+
    facet_wrap(~Output_Var)
  vplotIQR <- ggplot(cumcalibvalid.dat)+geom_bar(aes(x=Date,fill=in.IQR,
                                                  alpha=Training),position="fill")+
    ylab("Fraction")+scale_fill_viridis_d(end=0.7) + geom_hline(yintercept=0.5,color="grey")+
    scale_alpha_discrete(range=c(1,0.4))+facet_wrap(~Output_Var)
  pdf(file=file.path(folder,"CumulativeTrainingValidation.pdf"),height=4,width=6)
  print(vplotCI)
  print(vplotIQR)
  dev.off()
}

## Predicted total cumulative
pdf(file=file.path(folder,"Cumulative-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Output_Var[preddat$Output_Var=="CumInfected"] <- "infected"
  preddat$Output_Var[preddat$Output_Var=="CumDeath"] <- "death"
  cumnames <- c("Total Infected","Total Deaths")
  names(cumnames) <- c("infected","death")
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(subset(reopen.df,State.Abbr==statenow)$value,
                                    na.rm=TRUE))
  }
  popnow <- fips_table$pop[fips_table$Alpha.code==statenow]
  preddat$Prediction.2.5. <- preddat$Prediction.2.5.* popnow
  preddat$Prediction.25. <- preddat$Prediction.25.* popnow
  preddat$Prediction.50. <- preddat$Prediction.50.* popnow
  preddat$Prediction.75. <- preddat$Prediction.75.* popnow
  preddat$Prediction.97.5. <- preddat$Prediction.97.5.* popnow
  preddat$Prediction.2.5.[preddat$Prediction.2.5.<1] <- 1
  preddat$Prediction.25.[preddat$Prediction.25.<1] <- 1
  preddat$Prediction.50.[preddat$Prediction.50.<1] <- 1
  preddat$Prediction.75.[preddat$Prediction.75.<1] <- 1
  preddat$Prediction.97.5.[preddat$Prediction.97.5.<1] <- 1
  tmp<-subset(preddat,Output_Var=="infected" | Output_Var=="death")
  p<-ggplot(tmp)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",shape="Data",linetype="Prediction")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day")+scale_y_log10()+
    #coord_cartesian(ylim=c(1,popnow))+#max(tmp$Prediction.97.5.)))+
    geom_vline(xintercept = as.Date(datadatemax),color="grey",linetype="dotted")+
    facet_wrap(~Output_Var,ncol=2,dir="v",scales="free_y",
               labeller = labeller(Output_Var = cumnames)) +
    ggtitle(paste(statenow,"Cumulative Predicted"))
  print(p)
}
dev.off()

# ## Estimated Rt
pdf(file=file.path(folder,"Rt-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  statedat <- subset(dat.df,state==statenow)
  reopennow <- subset(reopen.df,State.Abbr==statenow)
  reopennow$Date <- as.Date(reopennow$numDate,origin=as.Date(datezero))
  if (calibdate!="") {
    datadatemax <- calibdate
  } else {
    datadatemax <- as.character(min(reopennow$value,
                                    na.rm=TRUE))
  }
  reopennow <- subset(reopennow,Date < as.Date(datadatemax))
  p<-ggplot(subset(preddat,Output_Var=="Rt" &
                     Date <= max(statedat$Date) &
                     Date >= min(statedat$Date)))+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",linetype="Estimated")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day") +
    geom_hline(yintercept=1,color="grey")+ylim(0,5)+
    ggtitle(paste(statenow,"R(t) Estimated"))
  if (nrow(reopennow)>0) {
    p <- p + geom_point(aes(x=Date,y=0,shape=ReopenType),data=reopennow)
  }
  if (datadatemax < max(preddat$Date)) {
    print(p + geom_vline(xintercept=as.Date(datadatemax),
                         color="grey",linetype="dotted"))
  } else {
    print(p)
  }
}
dev.off()

## Estimated Refft
pdf(file=file.path(folder,"Refft-pred.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  statedat <- subset(dat.df,state==statenow)
  reopennow <- subset(reopen.df,State.Abbr==statenow)
  reopennow$Date <- as.Date(reopennow$numDate,origin=as.Date(datezero))
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(reopennow$value,
                                    na.rm=TRUE))
  }
  reopennow <- subset(reopennow,Date < as.Date(datadatemax))
  p<-ggplot(subset(preddat,Output_Var=="Refft" & 
                     Date <= max(statedat$Date) &
                     Date >= min(statedat$Date)))+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",linetype="Estimated")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day") +
    geom_hline(yintercept=1,color="grey")+ylim(0,5)+
    ggtitle(paste(statenow,"Reff(t) Estimated"))
  if (nrow(reopennow)>0) {
    p <- p + geom_point(aes(x=Date,y=0,shape=ReopenType),data=reopennow)
  }
  if (datadatemax < max(preddat$Date)) {
    print(p + geom_vline(xintercept=as.Date(datadatemax),
                         color="grey",linetype="dotted"))
  } else {
    print(p)
  }
}
dev.off()

## Estimated I compartments
pdf(file=file.path(folder,"I_Compartments.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  statedat <- subset(dat.df,state==statenow)
  reopennow <- subset(reopen.df,State.Abbr==statenow)
  reopennow$Date <- as.Date(reopennow$numDate,origin=as.Date(datezero))
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(reopennow$value,
                                    na.rm=TRUE))
  }
  reopennow <- subset(reopennow,Date < as.Date(datadatemax))
  tmpdat<-subset(preddat,(Output_Var=="I_U" | Output_Var=="I_C" |
                            Output_Var=="I_T" ) & 
                   Date <= max(statedat$Date) &
                   Date >= min(statedat$Date))
  tmpdat$Output_Var<-factor(tmpdat$Output_Var,
                            levels=c("I_U","I_C","I_T"))
  p<-ggplot(tmpdat)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",linetype="Estimated")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day") + 
    facet_wrap(~Output_Var)+
    ggtitle(paste(statenow,"I(t) Estimated"))
  if (nrow(reopennow)>0) {
    p <- p + geom_point(aes(x=Date,y=min(tmpdat$Prediction.2.5.),
                                shape=ReopenType),data=reopennow)
  }
  if (datadatemax < max(preddat$Date)) {
    print(p + geom_vline(xintercept=as.Date(datadatemax),
                         color="grey",linetype="dotted"))
  } else {
    print(p)
  }
}
dev.off()


## Estimated S E 
pdf(file=file.path(folder,"S_E_Compartments.pdf"),height=4,width=6)
for (j in 1:length(csvfiles)) {
  preddat <- preddat.list[[j]]
  preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
  statenow<-str_split(csvfiles[[j]],"_")[[1]][2]
  statedat <- subset(dat.df,state==statenow)
  reopennow <- subset(reopen.df,State.Abbr==statenow)
  reopennow$Date <- as.Date(reopennow$numDate,origin=as.Date(datezero))
  if (calibdate!="") {
    datadatemax <- calibdate    
  } else {
    datadatemax <- as.character(min(reopennow$value,
                                    na.rm=TRUE))
  }
  reopennow <- subset(reopennow,Date < as.Date(datadatemax))
  tmpdat<-subset(preddat,(Output_Var=="S" | 
                            Output_Var=="S_C" | 
                            Output_Var=="E" | 
                            Output_Var=="E_C") & 
                   Date <= max(statedat$Date) &
                   Date >= min(statedat$Date))
  tmpdat$Output_Var<-factor(tmpdat$Output_Var,
                            levels=c("S","S_C","E","E_C"))
  p<-ggplot(tmpdat)+
    geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"))+
    geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
    geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
    labs(fill="",linetype="Estimated")+
    guides(linetype = guide_legend(order = 1),
           fill = guide_legend(order = 2))+
    ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
    scale_x_date(date_minor_breaks = "1 day") + 
    scale_y_log10() +
    annotation_logticks(sides="l")+
    facet_wrap(~Output_Var)+
    ggtitle(paste(statenow,"S(t), E(t) Estimated"))
  if (nrow(reopennow) > 0) {
    p <- p +     geom_point(aes(x=Date,y=min(tmpdat$Prediction.2.5.),
                                shape=ReopenType),data=reopennow)
  }
  if (datadatemax < max(preddat$Date)) {
    print(p + geom_vline(xintercept=as.Date(datadatemax),
                         color="grey",linetype="dotted"))
  } else {
    print(p)
  }
}
dev.off()

