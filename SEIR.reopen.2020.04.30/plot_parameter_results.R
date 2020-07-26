library(stringr)
library(data.table)
library(ggplot2)
library(gridExtra)
library(coda)
library(covid19us)
library(xml2)
library(jsonlite)
library(rvest)
library(dplyr)
## Preliminaries
chainvec <- 1:4
burnin <- 0.2
nsamp <- 500
datezero <- '2019-12-31'

fips_table <- read.csv("../FIPS_TABLE.csv")
dat.df <- read.csv("../DAILYTESTDATA.csv")
cumdat.df <- read.csv("../CUMULTESTDATA.csv")

in_file <- first(list.files(pattern="in.R"))
statenow <- last(str_split(dirname(normalizePath(in_file)),"/",simplify=TRUE))

## Functions
get_results <- function(in_file,chainnum=1,out_file="",
                        ...) {
  tx  <- readLines(in_file)
  MCMC_line <- grep("MCMC \\(", x=tx)
  MonteCarlo_line <- grep("MonteCarlo \\(", x=tx)
  SetPoints_line <- grep("SetPoints \\(", x=tx)
  
  if (length(MCMC_line) != 0) {
    file_prefix <- str_split(in_file,".in.R",simplify=TRUE)[1]
    
    # Chain input and output file
    chain_file <- paste0(file_prefix,chainnum,".in")
    if (out_file == "") out_file <- paste0(file_prefix,chainnum,".out")
    df_out <- read.delim(out_file)
    # Check files
    check_infile <- paste0(file_prefix,chainnum,".check.in")
    check_outfile <- paste0(file_prefix,chainnum,".check.out")
    if (sum(grepl(pattern = ",0,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Metropolis"
      restart_file <- out_file
    } else if (sum(grepl(pattern = ",3,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Tempered"
      restart_file <- paste0(file_prefix,chainnum,".posterior.out")
      maxIndexT <- max(df_out$IndexT)
      df_post <- subset(df_out,IndexT==maxIndexT)
      write.table(df_post,restart_file,row.names = FALSE,sep="\t")
    } else if (sum(grepl(pattern = ",4,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Thermodynamic"
      restart_file <- paste0(file_prefix,chainnum,".posterior.out")
      maxIndexT <- max(df_out$IndexT)
      df_post <- subset(df_out,IndexT==maxIndexT)
      write.table(df_post,restart_file,row.names = FALSE,sep="\t")
      df_prior <- subset(df_out,IndexT==0)
      if (nrow(df_prior)>0) write.table(df_prior,paste0(file_prefix,chainnum,".prior.out"))
    }
    if (mcmctype=="Metropolis") {
      df <- list(df_out=df_out)
    } else if (mcmctype == "Tempered") {
      df <- list(df_out=df_post,df_out_all=df_out)
    } else if (mcmctype == "Thermodynamic") {
      df <- list(df_out=df_post,df_out_prior=df_prior,df_out_all=df_out)
    }
  } else if (length(MonteCarlo_line) != 0){
    df <- read.delim(out_file)
  } else if (length(SetPoints_line) != 0){
    df <- read.delim(out_file)
  } else {
    df <- read.delim(out_file, skip = 1)
  }
  return(df)
}

## Get results and plots
dfchains <- list()
for (j in chainvec) dfchains[[j]]<-get_results(in_file,chainnum = j)

## Traces and diagnostics
parmslist <- list()
for (i in chainvec) {
  tmp <- dfchains[[i]]$df_out
  parmslist <- c(parmslist,list(tmp[floor(nrow(tmp)*burnin):(nrow(tmp)),]))
}
mcmclist <- list()
nmin <- min(unlist(lapply(parmslist,nrow)))
parms<-data.table()
for (i in chainvec) {
  indx <- sort(sample.int(nrow(parmslist[[i]]),nmin))
  tmp <- parmslist[[i]][indx,!grepl("Pseudo",names(as.data.table(parmslist[[i]])))]
  mcmclist[[i]] <- mcmc(tmp[,-1])
  tmp$chain <- i
  tmp$iter <- 1:nrow(tmp)
  parms<-rbind(parms,tmp)
}
parms.df <- melt(parms,id.vars=c(1,ncol(parms)))
ptrace<-ggplot(parms.df)+geom_line(aes(x=iter,y=value,
                                        color=factor(chain)),
                                   alpha=0.25)+
  facet_wrap(~variable,scales="free_y")+ggtitle(paste(in_file,"Posterior"))

mcmclist <- as.mcmc.list(mcmclist)
if (length(chainvec)>1) {
  rhat <- gelman.diag(mcmclist,multivariate=FALSE,autoburnin = FALSE)
  rhat.vec <- as.numeric(rhat$psrf[,1])
  names(rhat.vec) <- names(rhat$psrf[,1])
  print((as.matrix(rhat.vec)))
  parmssum<-do.call(cbind, lapply(parms[,2:(ncol(parms)-1)], summary))
  parmssum<-rbind(parmssum,rhat.vec)
} else {
  parmssum<-do.call(cbind, lapply(parms[,2:(ncol(parms)-1)], summary))
}
write.csv(parmssum,file=paste0(
  gsub(".in.R",".Summary.Rhat.csv",in_file)))

parms.df <- melt(as.data.table(parms[,1:(ncol(parms)-5)]),id.vars = 1)
parmsmeds <- setDT(parms.df)[,list(Median=as.numeric(median(value)),
                                   GSD=as.numeric(exp(sd(log(value))))), by=variable]
## Priors 
priors<-read.delim(file.path("..","simMTC0.out"))
names(priors)[1]<-"iter"
priors <- priors[,1:(ncol(priors)-1)]
names(priors)[2:ncol(priors)]<-paste0(names(priors)[2:ncol(priors)],".1.")
priors.df <- melt(priors[,1:(ncol(priors)-1)],id.vars=1)
priorsmeds <- setDT(priors.df)[,list(Median=as.numeric(median(value)),
                                     GSD=as.numeric(exp(sd(log(value))))), by=variable]

priortmp <- priors.df
priortmp$Type <- "Prior"
posttmp <- parms.df
posttmp$Type <- "Posterior"
priorpost <- rbind(priortmp,posttmp)
priormedstmp <- priorsmeds
priormedstmp$Type <- "Prior"
postmedstmp <- parmsmeds
postmedstmp$Type <- "Posterior"
priorpostmeds <- rbind(priormedstmp,postmedstmp)
priorpostplot<-ggplot(priorpost) + 
  geom_boxplot(aes(x=Type,y=value,color=Type)) + scale_y_log10() + 
  facet_wrap(~variable,scales="free",ncol=2)+coord_flip()+
  geom_text(data=priorpostmeds,aes(x=Type,y = Median, group=Type,
                                   label = signif(Median,2)),size = 3, hjust = 1.1) + 
  geom_text(data=priorpostmeds,aes(x=Type,y = Median, group=Type,
                                   label = paste0("GSD\n",signif(GSD,3))),
            size = 3, hjust = -0.1)+theme(legend.position = "none")+
  ggtitle(paste(in_file,"Prior-Posterior"))

plotspdf <- sub(".in.R",".parameter.plots.pdf",in_file)
pdf(plotspdf,onefile = TRUE,height = 8.5,width=11)
print(ptrace)
print(priorpostplot)
dev.off()

# # multicheck <- mcsim.multicheck(model_file_exe, in_file,burnin = burnin,nsamp = nsamp) 
# 
# ### Pred vs observed daily
# pred<-as.data.table(aggregate(Prediction~Time+Output_Var,
#                               subset(multicheck$df_check,
#                                      Output_Var == "D_pos" |
#                                        Output_Var == "N_pos" | 
#                                        Output_Var == "N_neg" |
#                                        Output_Var == "SocDist"),
#                               quantile,prob=c(0.025,0.25,0.5,0.75,0.975)))
# preddat<-merge(pred,as.data.table(aggregate(Data~Time+Output_Var,
#                                             subset(multicheck$df_check,
#                                                    Output_Var == "D_pos" |
#                                                      Output_Var == "N_pos" | 
#                                                      Output_Var == "N_neg" |
#                                                      Output_Var == "SocDist"),
#                                             median)))
# obsnames <- c("Daily Positive Tests","Daily Negative Tests","Daily Confirmed Deaths",
#               "Social Distancing (Unacast)"
# )
# names(obsnames) <- c("N_pos","N_neg","D_pos","SocDist")
# preddat$Date <- as.Date(preddat$Time,origin=as.Date(datezero))
# preddat$Output_Var <- factor(preddat$Output_Var,levels=names(obsnames))
# predplot <- ggplot(preddat)+
#   geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CI"))+
#   geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
#   geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
#   geom_point(aes(x=Date,y=Data,shape=""))+#scale_y_log10()+
#   labs(fill="",shape="Data",linetype="Prediction")+
#   ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
#   scale_x_date(date_minor_breaks = "1 day")+
#   facet_wrap(~Output_Var,scales="free",ncol=2,dir="v",
#              labeller = labeller(Output_Var = obsnames)) +
#   ggtitle(paste(in_file,"Predicted-Observed"))
# 
# ### Pred vs observed cumulative
# cumdat<-obsdat[,c("date","positive","death")] 
# names(cumdat) <- c("date","CumPos","CumPosDeath")
# cumdat$Date <- as.Date(cumdat$date)
# cumdat.df <- melt(as.data.table(cumdat),id.vars=c(1,4))
# names(cumdat.df) <- c("date","Date","Output_Var","Data")
# 
# predcum<-as.data.table(aggregate(Prediction~Time+Output_Var,
#                                  subset(multicheck$df_check,
#                                         Output_Var == "CumPosDeath" |
#                                           Output_Var == "CumPos" ),
#                                  quantile,prob=c(0.025,0.25,0.5,0.75,0.975)))
# obsnames <- c("Cumulative Positive Tests","Cumulative Confirmed Deaths"
# )
# names(obsnames) <- c("CumPos","CumPosDeath")
# predcum$Date <- as.Date(predcum$Time,origin=as.Date(datezero))
# predcum$Output_Var <- factor(predcum$Output_Var,levels=names(obsnames))
# cumdat.df$Output_Var <- factor(cumdat.df$Output_Var,levels=names(obsnames))
# cumplot <- ggplot(predcum)+
#   geom_ribbon(aes(x=Date,ymin=popnow*Prediction.2.5.,ymax=popnow*Prediction.97.5.,fill="CI"))+
#   geom_ribbon(aes(x=Date,ymin=popnow*Prediction.25.,ymax=popnow*Prediction.75.,fill="IQR"))+
#   geom_line(aes(x=Date,y=popnow*Prediction.50.,linetype="Median"))+
#   geom_point(aes(x=Date,y=Data,shape=""),data=cumdat.df)+#scale_y_log10()+
#   labs(fill="",shape="Data",linetype="Prediction")+
#   ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
#   scale_x_date(date_minor_breaks = "1 day")+
#   facet_wrap(~Output_Var,ncol=2,scales="free",
#              labeller = labeller(Output_Var = obsnames))+
#   ggtitle(paste(in_file,"Predicted-Observed-Cumulative"))
# 
# #### Compare to actual total
# totdat<-obsdat[,c("date","positive","death")] 
# names(totdat) <- c("date","CumInfected","D_T")
# totdat$Date <- as.Date(totdat$date)
# totdat.df <- melt(as.data.table(totdat),id.vars=c(1,4))
# names(totdat.df) <- c("date","Date","Output_Var","Data")
# 
# predtot<-as.data.table(aggregate(Prediction~Time+Output_Var,
#                                  subset(multicheck$df_check,
#                                         Output_Var == "D_T" |
#                                           Output_Var == "CumInfected" ),
#                                  quantile,prob=c(0.025,0.25,0.5,0.75,0.975)))
# totnames <- c("Total Infected","Total Deaths"
# )
# names(totnames) <- c("CumInfected","D_T")
# predtot$Date <- as.Date(predtot$Time,origin=as.Date(datezero))
# predtot$Output_Var <- factor(predtot$Output_Var,levels=names(totnames))
# totdat.df$Output_Var <- factor(totdat.df$Output_Var,levels=names(totnames))
# 
# totplot <- ggplot(predtot)+
#   geom_ribbon(aes(x=Date,ymin=popnow*Prediction.2.5.,ymax=popnow*Prediction.97.5.,fill="CI"))+
#   geom_ribbon(aes(x=Date,ymin=popnow*Prediction.25.,ymax=popnow*Prediction.75.,fill="IQR"))+
#   geom_line(aes(x=Date,y=popnow*Prediction.50.,linetype="Median"))+
#   geom_point(aes(x=Date,y=Data,shape=""),data=totdat.df)+
#   labs(fill="",shape="Data",linetype="Prediction")+
#   ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
#   scale_x_date(date_minor_breaks = "1 day")+
#   facet_wrap(~Output_Var,ncol=2,scales="free",
#              labeller = labeller(Output_Var = totnames))+
#   ggtitle(paste(in_file,"Predicted Totals"))
# 
# 
# R0pred<-as.data.table(aggregate(Prediction~Time+Output_Var,
#                                  subset(multicheck$df_check,
#                                         Output_Var == "R0_s" ),
#                                  quantile,prob=c(0.025,0.25,0.5,0.75,0.975)))
# R0pred$Date <- as.Date(R0pred$Time,origin=as.Date(datezero))
# R0plot <- ggplot(subset(R0pred,Date>min(obsdat$date) &
#                           Date<max(obsdat$date)))+
#   geom_ribbon(aes(x=Date,ymin=Prediction.2.5.,ymax=Prediction.97.5.,fill="CI"))+
#   geom_ribbon(aes(x=Date,ymin=Prediction.25.,ymax=Prediction.75.,fill="IQR"))+
#   geom_line(aes(x=Date,y=Prediction.50.,linetype="Median"))+
#   labs(fill="",linetype="Prediction")+
#   ylab("")+scale_fill_viridis_d(option="magma",begin = 0.6,end=0.95) +
#   ylim(0,NA)+geom_hline(yintercept = 1,color="grey")+
#   scale_x_date(date_minor_breaks = "1 day")+
#   ggtitle(paste(in_file,"R0 Estimated"))
# 
# 

### ALL PLOTS

# plotspdf <- sub(".in.R",".plots.pdf",in_file)
# pdf(plotspdf,onefile = TRUE,height = 8.5,width=11)
# print(ptrace)
# grid.arrange(tableGrob((signif(as.matrix(t(parmssum)),3))))
# print(priorpostplot)
# print(predplot)
# print(cumplot)
# print(totplot)
# print(R0plot)
# dev.off()
