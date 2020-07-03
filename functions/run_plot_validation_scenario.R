functiondir <- "functions"
figuredir <- "Figures"
modeldir <- "model"
datezero <- "2019-12-31"
datadatemax <- "2020-06-20"
source(file.path(functiondir,"get_testdata_functions.R"))
source(file.path(functiondir,"scenarios_functions.R"))


folder<-"SEIR.reopen.2020.04.30"
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
pdf(file=file.path(figuredir,"FigS4_ValidationResults.pdf"),height=4,width=6)
for (j in 1:nrow(scen.df[1,])) {
  scenrow<-scen.df[j,]
  dat.df <- subset(alldat.df,state==scenrow$state)
  names(dat.df)[names(dat.df)=="variable"]<-"Output_Var"
  dat.df$Output_Var<-as.character(dat.df$Output_Var)
  output <- run_setpoints(fips_table,
                           state_abbr=scenrow$state,
                           pathdir=folder,
                           scenariostemplate=
                             "SEIR.reopen_setpoints_MCMC.in.R",
                           scenarioname = scenrow$scenarioname,
                           nruns = 0,
                          mu_C = scenrow$mu_C,
                          mu_Lambda = scenrow$mu_Lambda,
                           DeltaDelta = scenrow$DeltaDelta,
                          rampuptime=14,
                           keepoutfile = FALSE,
                          exe_file = exe_file)
  pred.df <- subset(output$out_dat.df,Output_Var %in% c("alpha_Pos","alpha_Death","N_pos","D_pos"))
  obspred.df <- data.frame()
  set.seed(3.1415927)
  for (i in unique(pred.df$Iter)) {
    predtmp <- subset(pred.df,i == Iter)
    predtmp$numDate <- predtmp$Time+60
    predtmp$date <- as.Date(predtmp$numDate,origin=datezero)
    alpha_Pos <- subset(predtmp,Output_Var=="alpha_Pos")$Prediction
    alpha_Death <- subset(predtmp,Output_Var=="alpha_Death")$Prediction
    obspredtmp1 <- subset(dat.df,Output_Var=="positiveIncrease")
    obspredtmp1$Output_Var <- as.character("N_pos")
    obspredtmp1 <- merge(obspredtmp1,predtmp)
    obspredtmp1$RandPred <- rnbinom(nrow(obspredtmp1),alpha_Pos,
                                    alpha_Pos/(alpha_Pos+obspredtmp1$Prediction))
    obspredtmp2 <- subset(dat.df,Output_Var=="deathIncrease")
    obspredtmp2$Output_Var <- as.character("D_pos")
    obspredtmp2 <- merge(obspredtmp2,predtmp)
    obspredtmp2$RandPred <- rnbinom(nrow(obspredtmp2),alpha_Death,
                                    alpha_Death/(alpha_Death+obspredtmp2$Prediction))
    obspred.df <- rbind(obspred.df,obspredtmp1,obspredtmp2)
  }
  obspred.quant <-as.data.table(aggregate(RandPred~date+numDate+Output_Var+state+value,
                                          obspred.df,
                                          quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
  obspred.quant$p95 <- (obspred.quant$value >= obspred.quant$RandPred.2.5.) & (obspred.quant$value <= obspred.quant$RandPred.97.5.)
  obspred.quant$training <- "Validation"
  obspred.quant$training[obspred.quant$date <= as.Date("2020-04-30")] <- "Training"
  p95.cases.train <- subset(obspred.quant,date <= as.Date("2020-04-30") & Output_Var=="N_pos")
  scenrow$p95.cases.train <- sum(p95.cases.train$p95)/nrow(p95.cases.train)
  p95.deaths.train <- subset(obspred.quant,date <= as.Date("2020-04-30") & Output_Var=="D_pos")
  scenrow$p95.deaths.train <- sum(p95.deaths.train$p95)/nrow(p95.deaths.train)
  p95.cases.valid <- subset(obspred.quant,date > as.Date("2020-04-30") & date <= as.Date("2020-06-20") & Output_Var=="N_pos")
  scenrow$p95.cases.valid <- sum(p95.cases.valid$p95)/nrow(p95.cases.valid)
  p95.deaths.valid <- subset(obspred.quant,date > as.Date("2020-04-30") & date <= as.Date("2020-06-20") & Output_Var=="D_pos")
  scenrow$p95.deaths.valid <- sum(p95.deaths.valid$p95)/nrow(p95.deaths.valid)
  plt<-ggplot(obspred.quant)+
    geom_col(aes(x=date,y=value,fill=training))+
    geom_ribbon(aes(x=date,ymin=RandPred.2.5.,ymax=RandPred.97.5.),alpha=0.4)+
    facet_wrap(~Output_Var,scales="free")+
    ggtitle(paste(scenrow$state,"Coverage\nTraining:",
                  signif(scenrow$p95.cases.train,3),"(c)",
                  signif(scenrow$p95.deaths.train,3),"(d)",
                  "/ Validation:",
                  signif(scenrow$p95.cases.valid,3),"(c)",
                  signif(scenrow$p95.deaths.valid,3),"(d)"))+
    scale_fill_viridis_d(begin=0.8,end=0.2)+
    labs(fill="")+theme(legend.position = "bottom")+
    geom_vline(xintercept=as.Date("2020-04-30"))
  print(plt)
  scennew.df<-rbind(scennew.df,scenrow)
}
dev.off()
write.csv(scennew.df,file.path(figuredir,"FigS4_ValidationCoverage.csv"))
