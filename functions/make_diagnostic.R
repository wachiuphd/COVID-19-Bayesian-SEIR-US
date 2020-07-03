make_diagnostic <- function(out_dat, dat.df, cumdat.df, burnin=0.1,
                            pdfname="") {
  out_mcmc.df <- melt(data.table(out_dat$df_out),id.vars=1)
  check_mcmc <- out_dat$df_check
  check_mcmc$Data[check_mcmc$Data < 0] <- NA
  numdatemax <- min(max(dat.df$numDate,na.rm=TRUE),
                    max(subset(check_mcmc,!is.na(Data))$Time))
  if (pdfname != "") pdf(file=pdfname)
  p0<- ggplot(subset(out_mcmc.df,iter>max(iter*burnin)))+
    geom_line(aes(x=iter,y=value))+
    facet_wrap(~variable,scales="free_y")
  print(p0+ggtitle(statenow))
  
  p1<-ggplot(subset(check_mcmc,!is.na(Data)),
             aes(x=Data,y=Prediction,color=Output_Var))+
    geom_point() + geom_abline()+scale_x_log10()+scale_y_log10()+
    annotation_logticks(sides="l")
  print(p1+ggtitle(statenow))

  
  tmpdf <-subset(check_mcmc,Output_Var == "D_pos" |
                   Output_Var == "N_pos")
  tmpdf$Output_Var<-as.character(tmpdf$Output_Var)
  tmpdf$Output_Var[tmpdf$Output_Var=="N_pos"]<-"positiveIncrease"
  tmpdf$Output_Var[tmpdf$Output_Var=="D_pos"]<-"deathIncrease"
  names(tmpdf)[names(tmpdf)=="Output_Var"]<-"variable"
  p2all<-ggplot(tmpdf)+
    geom_line(aes(x=Time,y=Prediction,color=variable))+
    geom_col(data=dat.df, 
               aes(x=numDate,y=value,color=variable),alpha=0.5)+
    geom_vline(xintercept = numdatemax)+
    facet_wrap(~variable,scales="free_y",ncol=1)
  print(p2all+ggtitle(statenow))
  print(p2all+annotation_logticks(sides="l")+scale_y_log10(limits=c(0.1,NA))+ggtitle(statenow))
  
  tmpdf <-subset(check_mcmc,Output_Var == "CumPosTest" |
                   Output_Var == "CumDeath")
  tmpdf$Output_Var<-as.character(tmpdf$Output_Var)
  tmpdf$Output_Var[tmpdf$Output_Var=="CumPosTest"]<-"positive"
  tmpdf$Output_Var[tmpdf$Output_Var=="CumDeath"]<-"death"
  names(tmpdf)[names(tmpdf)=="Output_Var"]<-"variable"
  p2cum<-ggplot(tmpdf)+
    geom_line(aes(x=Time,y=popnow*Prediction,color=variable))+
    geom_point(data=cumdat.df, 
               aes(x=numDate,y=value,color=variable),alpha=0.5)+
    geom_vline(xintercept = numdatemax)+
    ylim(1,NA)+
    facet_wrap(~variable,scales="free_y",ncol=1)
  print(p2cum+ggtitle(statenow))
  print(p2cum+annotation_logticks(sides="l")+scale_y_log10()+ggtitle(statenow))
  
  p2s<-ggplot(subset(check_mcmc,Output_Var == "ThetaFit" |
                       Output_Var == "HygieneFit" |
                       Output_Var == "c" | 
                       Output_Var == "beta" |
                       Output_Var == "rho" |
                       Output_Var == "Rt" | 
                       Output_Var == "Refft" | 
                       Output_Var == "lambda" |
                       Output_Var == "delta"))+
    geom_point(aes(x=Time,y=Data,color=Output_Var))+
    geom_line(aes(x=Time,y=Prediction,color=Output_Var))+
    geom_vline(xintercept = numdatemax)+
    facet_wrap(~Output_Var,nrow=3,scales="free")
  print(p2s+ggtitle(statenow))
  
  p3<-ggplot(subset(check_mcmc,Output_Var == "S" |
                       Output_Var == "E" |
                       Output_Var == "I_U" | 
                       Output_Var == "R_U"))+
    geom_line(aes(x=Time,y=Prediction*popnow,color=Output_Var))+
    geom_vline(xintercept = numdatemax)+
    facet_wrap(~Output_Var,nrow=2,scales="free")
  print(p3+ggtitle(statenow))
  
  if (pdfname != "") dev.off()
}
