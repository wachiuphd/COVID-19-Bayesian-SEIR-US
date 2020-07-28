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
for (statenow in statesvec) {
  output <- run_setpoints1(fips_table,
                           state_abbr=statenow,
                           pathdir=folder,
                           scenariostemplate=
                             "SEIR.reopen_state_setpoints1_MCMC.in.R",
                           scenarioname = "OneTime",
                           nruns = 0,
                           TPrint=datadatemax,
                           keepoutfile = TRUE,
                           exe_file = exe_file)
}
