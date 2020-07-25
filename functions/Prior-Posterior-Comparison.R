library(ggplot2)
library(stringr)
library(data.table)

datezero <- '2019-12-31'
val.folder <- "SEIR.reopen.2020.04.30"
cal.folder <- "SEIR.reopen.state.2020.06.20"
pred.folder <- "SEIR.reopen.state.2020.07.22"

## FIPS table for reference
fips_table <- read.csv(file.path(val.folder,"FIPS_TABLE.csv"),colClasses=c(
  rep("character",4),rep("numeric",2)
))
rownames(fips_table) <- fips_table$Alpha.code
state_abbr <- fips_table$Alpha.code[2:52]

## Read generic prior
val.prior <- fread(file.path(val.folder,"simMTC0.out"))
val.prior.tmp.df <- 
  data.table(t(apply(val.prior,2,quantile,
          prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975))),
          keep.rownames = TRUE)
names(val.prior.tmp.df)[1]<-"Parameter"
val.prior.tmp.df$State.abbr <- "Pr"
val.prior.tmp.df$Date <- "2020-04-30"
val.prior.df <- data.frame()
for (statenow in state_abbr) {
  val.prior.tmp.df$State.abbr <- statenow
  val.prior.df <- rbind(val.prior.df,val.prior.tmp.df)
}

## Read state-specific priors
cal.prior.df <- data.frame()
pred.prior.df <- data.frame()
for (statenow in state_abbr) {
  cal.prior.tmp<-fread(file.path(cal.folder,statenow,paste0("SEIR_",statenow,"_MTC.out")))
  cal.prior.tmp <- cal.prior.tmp[,1:(ncol(cal.prior.tmp)-1)]
  cal.prior.tmp.df <- data.table(t(apply(cal.prior.tmp,2,quantile,
                          prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975))),
                          keep.rownames=TRUE)
  names(cal.prior.tmp.df)[1]<-"Parameter"
  cal.prior.tmp.df$State.abbr <- statenow
  cal.prior.df <- rbind(cal.prior.df,cal.prior.tmp.df)
  
  pred.prior.tmp<-fread(file.path(pred.folder,statenow,paste0("SEIR_",statenow,"_MTC.out")))
  pred.prior.tmp <- pred.prior.tmp[,1:(ncol(pred.prior.tmp)-1)]
  pred.prior.tmp.df <- data.table(t(apply(pred.prior.tmp,2,quantile,
                              prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975))),
                              keep.rownames=TRUE)
  names(pred.prior.tmp.df)[1]<-"Parameter"
  pred.prior.tmp.df$State.abbr <- statenow
  pred.prior.df <- rbind(pred.prior.df,pred.prior.tmp.df)
}
cal.prior.df$Date <- "2020-06-20"
pred.prior.df$Date <- "2020-07-22"

## Get state-by-state file names
val.csvfiles <- character()
cal.csvfiles <- character()
pred.csvfiles <- character()
for (statenow in state_abbr) {
  val.csvfiles <- c(val.csvfiles,
                list.files(path=file.path(val.folder,statenow),
                           pattern="*parameter.quantiles.csv",
                           full.names=TRUE))
  cal.csvfiles <- c(cal.csvfiles,
                    list.files(path=file.path(cal.folder,statenow),
                               pattern="*parameter.quantiles.csv",
                               full.names=TRUE))
  pred.csvfiles <- c(pred.csvfiles,
                    list.files(path=file.path(pred.folder,statenow),
                               pattern="*parameter.quantiles.csv",
                               full.names=TRUE))
}
val.csvfiles <- val.csvfiles[!grepl("Scen",val.csvfiles)]
cal.csvfiles <- cal.csvfiles[!grepl("Scen",cal.csvfiles)]
pred.csvfiles <- pred.csvfiles[!grepl("Scen",pred.csvfiles)]

## Read parameter files
val.parmdat.df <- data.frame()
cal.parmdat.df <- data.frame()
pred.parmdat.df <- data.frame()
for (j in 1:length(val.csvfiles)) {
  parmdat.tmp <- fread(val.csvfiles[[j]])
  names(parmdat.tmp)[1]<-"Parameter"
  parmdat.tmp <- subset(parmdat.tmp,Parameter != "iter" &
                          !grepl("Ln",Parameter) &
                          Parameter != "IndexT")
  parmdat.tmp$State.abbr <- state_abbr[j]
  parmdat.tmp$Parameter<-gsub(".1.","",parmdat.tmp$Parameter)
  val.parmdat.df <- rbind(val.parmdat.df,parmdat.tmp)
  
  parmdat.tmp <- fread(cal.csvfiles[[j]])
  names(parmdat.tmp)[1]<-"Parameter"
  parmdat.tmp <- subset(parmdat.tmp,Parameter != "iter" &
                          !grepl("Ln",Parameter) &
                          Parameter != "IndexT")
  parmdat.tmp$State.abbr <- state_abbr[j]
  parmdat.tmp$Parameter<-gsub(".1.","",parmdat.tmp$Parameter)
  cal.parmdat.df <- rbind(cal.parmdat.df,parmdat.tmp)
  
  parmdat.tmp <- fread(pred.csvfiles[[j]])
  names(parmdat.tmp)[1]<-"Parameter"
  parmdat.tmp <- subset(parmdat.tmp,Parameter != "iter" &
                          !grepl("Ln",Parameter) &
                          Parameter != "IndexT")
  parmdat.tmp$State.abbr <- state_abbr[j]
  parmdat.tmp$Parameter<-gsub(".1.","",parmdat.tmp$Parameter)
  pred.parmdat.df <- rbind(pred.parmdat.df,parmdat.tmp)
}
val.parmdat.df$Date <- "2020-04-30"
cal.parmdat.df$Date <- "2020-06-20"
pred.parmdat.df$Date <- "2020-07-22"

## Plot by parameter
pdf(file="AllPriorPost.pdf",height=8,width=10)
parms <- unique(pred.parmdat.df$Parameter)
for (parmnow in parms) {
  priors <- rbind(subset(val.prior.df,Parameter==parmnow),
                  subset(cal.prior.df,Parameter==parmnow),
                  subset(pred.prior.df,Parameter==parmnow))
  priors$Type="Prior"
  posteriors <- rbind(subset(val.parmdat.df,Parameter==parmnow),
                      subset(cal.parmdat.df,Parameter==parmnow),
                      subset(pred.parmdat.df,Parameter==parmnow))
  posteriors$Type="Posterior"
  priorpost <- rbind(priors,posteriors)
  plt<-ggplot(priorpost)+
    geom_boxplot(aes(x=Date,lower=`25%`,upper=`75%`,
                     min=`2.5%`,max=`97.5%`,middle=`50%`,
                     fill=Type),stat="identity")+
    coord_flip()+
    scale_fill_viridis_d(limits=c("Prior","Posterior"))+
    scale_x_discrete(limits = rev(unique(priorpost$Date)))+
    ggtitle(parmnow)+
    facet_wrap(~State.abbr)
  if (parmnow %in% c("GM_NInit","GM_IFR"))
    plt <- plt+scale_y_log10()
  print(plt)
}
dev.off()

pdf(file="Calib-Under-PriorPost.pdf",height=8,width=10)
#Calib_under_states <- c("AK","FL","HI","ID","LA","MT","SD","VT","WV")
Calib_under_states <- c("AK","HI","MT","SD","VT","WV")
parms <- unique(pred.parmdat.df$Parameter)
for (parmnow in parms) {
  priors <- rbind(subset(val.prior.df,Parameter==parmnow),
                  subset(cal.prior.df,Parameter==parmnow))
  priors$Type="Prior"
  posteriors <- rbind(subset(val.parmdat.df,Parameter==parmnow),
                      subset(cal.parmdat.df,Parameter==parmnow))
  posteriors$Type="Posterior"
  priorpost <- subset(rbind(priors,posteriors),State.abbr %in% Calib_under_states)
  plt<-ggplot(priorpost)+
    geom_boxplot(aes(x=Date,lower=`25%`,upper=`75%`,
                     min=`2.5%`,max=`97.5%`,middle=`50%`,
                     fill=Type),stat="identity")+
    coord_flip()+
    scale_fill_viridis_d(limits=c("Prior","Posterior"))+
    scale_x_discrete(limits = rev(unique(priorpost$Date)))+
    ggtitle(paste("Underpredicted States:",parmnow))+
    facet_wrap(~State.abbr)
  if (parmnow %in% c("GM_NInit","GM_IFR"))
    plt <- plt+scale_y_log10()
  print(plt)
}
dev.off()

pdf(file="Calib-Over-PriorPost.pdf",height=8,width=10)
#Calib_over_states <- c("IL","IN","IA","MA","MI","MN","OH","WY")
Calib_over_states <- c("IL","IN","IA","KS","MI","MN","NE")
parms <- unique(pred.parmdat.df$Parameter)
for (parmnow in parms) {
  priors <- rbind(subset(val.prior.df,Parameter==parmnow),
                  subset(cal.prior.df,Parameter==parmnow))
  priors$Type="Prior"
  posteriors <- rbind(subset(val.parmdat.df,Parameter==parmnow),
                      subset(cal.parmdat.df,Parameter==parmnow))
  posteriors$Type="Posterior"
  priorpost <- subset(rbind(priors,posteriors),State.abbr %in% Calib_over_states)
  plt<-ggplot(priorpost)+
    geom_boxplot(aes(x=Date,lower=`25%`,upper=`75%`,
                     min=`2.5%`,max=`97.5%`,middle=`50%`,
                     fill=Type),stat="identity")+
    coord_flip()+
    scale_fill_viridis_d(limits=c("Prior","Posterior"))+
    scale_x_discrete(limits = rev(unique(priorpost$Date)))+
    ggtitle(paste("Overpredicted States:",parmnow))+
    facet_wrap(~State.abbr)
  if (parmnow %in% c("GM_NInit","GM_IFR"))
    plt <- plt+scale_y_log10()
  print(plt)
}
dev.off()

pdf(file="Pred-Under-PriorPost.pdf",height=8,width=10)
Pred_under_states <- c("GA","ID","IL","IA","LA","MD","MN","MS","ND","OH","PA","VA","WA","WV","WI")
parms <- unique(pred.parmdat.df$Parameter)
for (parmnow in parms) {
  priors <- rbind(subset(cal.prior.df,Parameter==parmnow),
                  subset(pred.prior.df,Parameter==parmnow))
  priors$Type="Prior"
  posteriors <- rbind(subset(cal.parmdat.df,Parameter==parmnow),
                      subset(pred.parmdat.df,Parameter==parmnow))
  posteriors$Type="Posterior"
  priorpost <- subset(rbind(priors,posteriors),State.abbr %in% Pred_under_states)
  plt<-ggplot(priorpost)+
    geom_boxplot(aes(x=Date,lower=`25%`,upper=`75%`,
                     min=`2.5%`,max=`97.5%`,middle=`50%`,
                     fill=Type),stat="identity")+
    coord_flip()+
    scale_fill_viridis_d(limits=c("Prior","Posterior"))+
    scale_x_discrete(limits = rev(unique(priorpost$Date)))+
    ggtitle(paste("Underpredicted 7/22 States:",parmnow))+
    facet_wrap(~State.abbr)
  if (parmnow %in% c("GM_NInit","GM_IFR"))
    plt <- plt+scale_y_log10()
  print(plt)
}
dev.off()

pdf(file="Pred-Accur-PriorPost.pdf",height=8,width=10)
parms <- unique(pred.parmdat.df$Parameter)
for (parmnow in parms) {
  priors <- rbind(subset(cal.prior.df,Parameter==parmnow),
                  subset(pred.prior.df,Parameter==parmnow))
  priors$Type="Prior"
  posteriors <- rbind(subset(cal.parmdat.df,Parameter==parmnow),
                      subset(pred.parmdat.df,Parameter==parmnow))
  posteriors$Type="Posterior"
  priorpost <- subset(rbind(priors,posteriors),!(State.abbr %in% Pred_under_states))
  plt<-ggplot(priorpost)+
    geom_boxplot(aes(x=Date,lower=`25%`,upper=`75%`,
                     min=`2.5%`,max=`97.5%`,middle=`50%`,
                     fill=Type),stat="identity")+
    coord_flip()+
    scale_fill_viridis_d(limits=c("Prior","Posterior"))+
    scale_x_discrete(limits = rev(unique(priorpost$Date)))+
    ggtitle(paste("Accurate 7/22 States:",parmnow))+
    facet_wrap(~State.abbr)
  if (parmnow %in% c("GM_NInit","GM_IFR"))
    plt <- plt+scale_y_log10()
  print(plt)
}
dev.off()
