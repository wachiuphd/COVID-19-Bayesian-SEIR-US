functiondir <- "functions"
figuredir <- "Figures"
modeldir <- "model"
datezero <- "2019-12-31"
folder<-"SEIR.reopen.state.2020.07.22"
datadatemax <- "2020-07-22"
datemaxplot <- "2020-09-30"
scenstartdate <- "2020-08-01"
rampuptime<-14
source(file.path(functiondir,"get_testdata_functions.R"))
source(file.path(functiondir,"scenarios_functions.R"))


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

scen.df <- data.frame(state=sort(rep(statesvec,20)),
                      mu_C = rep(rep(c(1,1,2,2),5),length(statesvec)),
                      mu_Lambda = rep(rep(c(1,2,1,2),5),length(statesvec)),
                      DeltaDelta = rep(c(rep(0,4),rep(0.25,4),rep(0.5,4),rep(-0.25,4),rep(-0.5,4)),length(statesvec)),
                      stringsAsFactors = FALSE
)
scen.df$scenarioname <- paste("TimeSeries",scen.df$mu_C,scen.df$mu_Lambda,
                              scen.df$DeltaDelta,sep=".")
scen.df$scenariodesc <- paste0(scen.df$mu_C,"X Contact Tracing, ",
                               scen.df$mu_Lambda,"X Testing, ",
                               ifelse(sign(scen.df$DeltaDelta)==1,
                                      paste0("+",100*scen.df$DeltaDelta,"%"),
                                      ifelse(sign(scen.df$DeltaDelta)== -1,
                                      paste0(100*scen.df$DeltaDelta,"%"),
                                      ifelse(sign(scen.df$DeltaDelta)==0,
                                      "Current",""
                                      )))," Reopening")
pdf(file=file.path(figuredir,paste0("FigS8_Scenarios_Results_All_",datadatemax,".pdf")),height=4,width=6)
for (j in 1:nrow(scen.df)) {
  scenrow<-scen.df[j,]
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
                          scenstartdate = scenstartdate,
                          TPrint=datemaxplot,
                          rampuptime=rampuptime,
                           keepoutfile = FALSE,
                          exe_file = exe_file)
  plot_scenario(alldat.df, output$out_quant,scenrow$state,
                logy=FALSE,
                datadatemax=datadatemax,
                datemaxplot=datemaxplot,
                scenarioname = scenrow$scenariodesc)
}
dev.off()
