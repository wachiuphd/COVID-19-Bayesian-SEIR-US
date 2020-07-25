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
model_file_exe <- list.files(pattern="mcsim.")
model_file <- last(str_split(model_file_exe,"mcsim.",simplify=TRUE))
model_file <- gsub(".exe","",model_file)
in_file <- first(list.files(pattern="in.R"))

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

mcsim.multicheck <- function(model_file_exe, in_file, 
                             check_in_file = "",
                             chainnum.vec=1:4, warmup = NA, 
                             burnin = 0.5,
                             nsamp = 100,
                             randseed = exp(1)) {
  exe_file <- paste0("./",model_file_exe) # paste0("./mcsim.", model_file)
  
  tx  <- readLines(in_file)
  MCMC_line <- grep("MCMC \\(", x=tx)
  if (length(MCMC_line) != 0){
    file_prefix <- str_split(in_file,".in.R",simplify=TRUE)[1]
    if (check_in_file != "") {
      check_file_prefix <- str_split(check_in_file,".in.R",simplify=TRUE)[1]
    } else {
      check_file_prefix <- file_prefix
    }
    if (sum(grepl(pattern = ",0,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Metropolis"
      chainfile <- paste0(file_prefix,chainnum.vec[1],".out")
      niter_perchain <- length(readLines(chainfile))-1
      if (is.na(warmup)) warmup <- floor(niter_perchain*burnin)
    } else if (sum(grepl(pattern = ",3,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Tempered"
      chainfile <- paste0(file_prefix,chainnum.vec[1],".posterior.out")
    } else if (sum(grepl(pattern = ",4,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Thermodynamic"
      chainfile <- paste0(file_prefix,chainnum.vec[1],".posterior.out")
    }
    allchains <- data.frame()
    for (chainnum in chainnum.vec) {
      if (mcmctype == "Metropolis") {
        chainfile <- paste0(file_prefix,chainnum.vec[chainnum],".out")
      } else if (mcmctype == "Tempered" | mcmctype == "Thermodynamic") {
        chainfile <- paste0(file_prefix,chainnum.vec[chainnum],".posterior.out")
      }
      niter_perchain <- length(readLines(chainfile))-1
      if (is.na(warmup)) warmup <- floor(niter_perchain*burnin)
      chainout <- read.delim(chainfile)[warmup:niter_perchain,]
      chainout <- chainout[,!grepl("Pseudo",names(as.data.table(chainout)))]
      allchains <- rbind(allchains,chainout)
    }
    set.seed(randseed)
    allchains.samp <- allchains[sample(nrow(allchains),
                                       min(nsamp,nrow(allchains))),]
    out_file <- paste0(check_file_prefix,paste0(chainnum.vec,collapse=""),".samps.out")
    write.table(allchains.samp,file=out_file,row.names = FALSE)
    out_file <- paste0(check_file_prefix,".tmp.out")
    check_infile <- paste0(check_file_prefix,".tmp.check.in")
    check_outfile <- paste0(check_file_prefix,".tmp.check.out")
    tx2 <- tx;
    if (mcmctype == "Metropolis") {
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",0,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
    } else if (mcmctype == "Tempered") {
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",3,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
    } else if (mcmctype == "Thermodynamic") {
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",4,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
    }
    tx3 <- tx2;
    tx3[MCMC_line] <-
      sub(pattern = paste0("\"\""),replace = paste0("\"", out_file, "\""),
          x = tx2[MCMC_line])
    writeLines(tx3, con=paste0(check_infile))
    df_check <- data.frame()
    for (snum in 1:nrow(allchains.samp)) {
      write.table(allchains.samp[snum,],file=out_file,row.names = FALSE)
      system(paste(exe_file,check_infile,check_outfile),
             ignore.stdout = TRUE, ignore.stderr = TRUE)
      try({ df_tmp <- read.delim(check_outfile);
      df_tmp$sampnum <- snum;
      df_check <- rbind(df_check,df_tmp);
      })
    }
    check_outfile <- paste0(check_file_prefix,paste0(chainnum.vec,collapse=""),".samps.check.out")
    write.table(df_check,file=check_outfile,row.names=FALSE)
  } else {
    message("in_file is not MCMC file... cannot do checks")
  }
  return(list(parms.samp=allchains.samp,df_check=df_check))
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
parms.df <- melt(as.data.table(parms[,1:(ncol(parms)-5)]),id.vars = 1)
parmsmeds <- setDT(parms.df)[,list(Median=as.numeric(median(value)),
                                   GSD=as.numeric(exp(sd(log(value))))), by=variable]

multicheck <- mcsim.multicheck(model_file_exe, in_file,burnin = burnin,nsamp = nsamp) 

parmquant <-t(apply(multicheck$parms.samp,2,quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
write.csv(parmquant,file=paste0(
  gsub(".in.R",".parameter.quantiles.csv",in_file)))
predquant <-as.data.table(aggregate(Prediction~Time+Output_Var,
                                          multicheck$df_check,
                                          quantile,prob=c(0.025,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.975)))
write.csv(predquant,file=paste0(
  gsub(".in.R",".prediction.quantiles.csv",in_file)))


