functiondir <- "functions"
figuredir <- "Figures"
modeldir <- "model"
datezero <- "2019-12-31"
datadatemax <- "2020-07-22"
source(file.path(functiondir,"get_testdata_functions.R"))
source(file.path(functiondir,"scenarios_functions.R"))


folder<-"SEIR.reopen.state.2020.06.20"
fips_table <- read.csv(file.path(folder,"FIPS_TABLE.csv"),colClasses=c(
  rep("character",4),rep("numeric",2)
))
alldat.df <- get_testdata()
statesvec <- fips_table$Alpha.code[2:52]

# Make model executable
mdir <- "MCSim"
source(here::here(mdir,"setup_MCSim.R"))
# Make mod.exe (used to create mcsim executable from model file)
makemod(here::here(mdir)) 
model_file<- "SEIR.scenarios.model.R"
exe_file<-makemcsim(model_file,modeldir=modeldir)

scen.df <- data.frame(state=statesvec,
                      mu_C = rep(1,length(statesvec)),
                      mu_Lambda = rep(1,length(statesvec)),
                      DeltaDelta = rep(0,length(statesvec)),
                      stringsAsFactors = FALSE
)
scen.df$scenarioname <- "Validation"
scen.df$scenariodesc <- "Validation"
scennew.df<-data.frame()
pdf(file=file.path(figuredir,"FigS2_Validation.2.Results.pdf"),height=6,width=8)
for (j in 1:nrow(scen.df)) {
  scenrow<-scen.df[j,]
  dat.df <- subset(alldat.df,state==scenrow$state)
  names(dat.df)[names(dat.df)=="variable"]<-"Output_Var"
  dat.df$Output_Var<-as.character(dat.df$Output_Var)
  output <- run_setpoints(fips_table,
                          state_abbr=scenrow$state,
                          pathdir=folder,
                          scenariostemplate=
                            "SEIR.reopen_state_setpoints_MCMC.in.R",
                          scenarioname = scenrow$scenarioname,
                          nruns = 0,
                          mu_C = scenrow$mu_C,
                          mu_Lambda = scenrow$mu_Lambda,
                          DeltaDelta = scenrow$DeltaDelta,
                          rampuptime=14,
                          keepoutfile = FALSE,
                          exe_file = exe_file)
  pred.df <- subset(output$out_dat.df,Output_Var %in% c("alpha_Pos","alpha_Death","N_pos","D_pos"))
  pred.df$Output_Var[pred.df$Output_Var=="N_pos"]<-"Reported Cases"
  pred.df$Output_Var[pred.df$Output_Var=="D_pos"]<-"Confirmed Deaths"
  obspred.df <- data.frame()
  set.seed(3.1415927)
  for (i in unique(pred.df$Iter)) {
    predtmp <- subset(pred.df,i == Iter)
    predtmp$numDate <- predtmp$Time+60
    predtmp$date <- as.Date(predtmp$numDate,origin=datezero)
    alpha_Pos <- subset(predtmp,Output_Var=="alpha_Pos")$Prediction
    alpha_Death <- subset(predtmp,Output_Var=="alpha_Death")$Prediction
    obspredtmp1 <- subset(dat.df,Output_Var=="positiveIncrease")
    obspredtmp1$Output_Var <- as.character("Reported Cases")
    obspredtmp1 <- merge(obspredtmp1,predtmp)
    obspredtmp1$RandPred <- rnbinom(nrow(obspredtmp1),alpha_Pos,
                                    alpha_Pos/(alpha_Pos+obspredtmp1$Prediction))
    obspredtmp2 <- subset(dat.df,Output_Var=="deathIncrease")
    obspredtmp2$Output_Var <- as.character("Confirmed Deaths")
    obspredtmp2 <- merge(obspredtmp2,predtmp)
    obspredtmp2$RandPred <- rnbinom(nrow(obspredtmp2),alpha_Death,
                                    alpha_Death/(alpha_Death+obspredtmp2$Prediction))
    obspred.df <- rbind(obspred.df,obspredtmp1,obspredtmp2)
  }
  obspred.pred.quant <-as.data.table(aggregate(Prediction~date+numDate+Output_Var+state+value,
                                               obspred.df,
                                               quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
  obspred.quant <-as.data.table(aggregate(RandPred~date+numDate+Output_Var+state+value,
                                          obspred.df,
                                          quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
  obspred.quant$p95 <- (obspred.quant$value >= obspred.quant$RandPred.2.5.) & (obspred.quant$value <= obspred.quant$RandPred.97.5.)
  obspred.quant$training <- "Validation"
  obspred.quant$training[obspred.quant$date <= as.Date("2020-06-20")] <- "Training"
  p95.cases.train <- subset(obspred.quant,date <= as.Date("2020-06-20") & Output_Var=="Reported Cases")
  scenrow$p95.cases.train <- sum(p95.cases.train$p95)/nrow(p95.cases.train)
  p95.deaths.train <- subset(obspred.quant,date <= as.Date("2020-06-20") & Output_Var=="Confirmed Deaths")
  scenrow$p95.deaths.train <- sum(p95.deaths.train$p95)/nrow(p95.deaths.train)
  p95.cases.valid <- subset(obspred.quant,date > as.Date("2020-06-20") & date <= as.Date("2020-07-22") & Output_Var=="Reported Cases")
  scenrow$p95.cases.valid <- sum(p95.cases.valid$p95)/nrow(p95.cases.valid)
  p95.deaths.valid <- subset(obspred.quant,date > as.Date("2020-06-20") & date <= as.Date("2020-07-22") & Output_Var=="Confirmed Deaths")
  scenrow$p95.deaths.valid <- sum(p95.deaths.valid$p95)/nrow(p95.deaths.valid)
  obspred.quant <- subset(obspred.quant,date <= as.Date("2020-07-22"))
  obspred.pred.quant <- subset(obspred.pred.quant,date <= as.Date("2020-07-22"))
  plt<-ggplot(obspred.quant)+
    geom_col(aes(x=date,y=value,alpha=training))+
    geom_ribbon(aes(x=date,ymin=RandPred.2.5.,ymax=RandPred.97.5.,fill="CrI+Dispersion"),alpha=0.2)+
    geom_ribbon(aes(x=date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CrI"),alpha=0.4,
                data=obspred.pred.quant)+
    geom_ribbon(aes(x=date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"),alpha=0.4,
                data=obspred.pred.quant)+
    geom_line(aes(x=date,y=Prediction.50.,color="Median"),
              data=obspred.pred.quant)+
    facet_wrap(~Output_Var,scales="free")+
    ggtitle(paste(scenrow$state,"\nTraining Coverage:",
                  signif(scenrow$p95.deaths.train,3),"(Deaths)",
                  signif(scenrow$p95.cases.train,3),"(Cases)",
                  "\nValidation Coverage:",
                  signif(scenrow$p95.deaths.valid,3),"(Deaths)",
                  signif(scenrow$p95.cases.valid,3),"(Cases)"))+
    scale_alpha_discrete(range=c(1,0.4))+
    scale_fill_viridis_d(begin=0.8,end=0.2,option="magma",
                         breaks=c("IQR","CrI","CrI+Dispersion"))+
    scale_x_date(date_minor_breaks = "1 day")+
    xlab("Date")+
    ylab("Deaths or Cases")+
    labs(fill="",alpha="Data",color="Prediction")+
    theme_bw()+
    guides(alpha = guide_legend(order = 1),
           color = guide_legend(order = 2),
           fill = guide_legend(order = 3))+
    theme(legend.position = "bottom")+
    geom_vline(xintercept=as.Date("2020-06-20"))
  print(plt)
  scennew.df<-rbind(scennew.df,scenrow)
}
dev.off()
write.csv(scennew.df,file.path(figuredir,"FigS2_Validation.2.Coverage.csv"))
