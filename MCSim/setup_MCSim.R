# Download all files form this repository (the current version of MCSim is 6.0.1)
# Check the chek whether the compiler is in the PATH by using
# Sys.getenv("PATH") 

# set_PATH <- function(PATH = "c:/Rtools/mingw_32/bin"){
#   
#   if (Sys.info()[['sysname']] == "Windows") {
#     if(Sys.which("gcc") == ""){ # echo $PATH
#       Sys.setenv(PATH = paste(PATH, Sys.getenv("PATH"), sep=";"))
#     } # PATH=$PATH:/c/Rtools/mingw_32/bin; export PATH
#   } # PATH=$PATH:/c/MinGW/msys/1.0/local/bin
#   
#   # The macos used clang as default, the following command is used to switch to GCC
#   # Sys.setenv(PATH = paste("/usr/local/bin", Sys.getenv("PATH"), sep=";"))
#   # port select --list gcc
#   # sudo port select --set gcc mp-gcc8
#   
#   # Check the GCC compiler 
#   Sys.which("gcc")
#   system('gcc -v')
# }

makemod <- function(mdir="MCSim") {
  if(Sys.which("gcc") == ""){
    stop("Please set the PATH of compiler")
  }
  system(paste("gcc -o",file.path(mdir,"mod.exe"),
               file.path(mdir,"mod/*.c")))
  
  if(file.exists(file.path(mdir,"mod.exe"))){
    message("The mod.exe had been created.")
  }
}

# Create mcsim executable from model file in working director
makemcsim <- function(model_file,modeldir="model",mdir="MCSim") {
  exe_file <- file.path(modeldir,paste0("mcsim.", model_file, ".exe"))
  c_file <- paste0(file.path(modeldir,model_file), ".c")
  system(paste(file.path(mdir,"mod.exe"),
               file.path(modeldir,model_file), 
               c_file))
  system(paste0("gcc -O3 -I.. -I",file.path(mdir,"sim")," -o ",
               exe_file," ",
               c_file," ",
               file.path(mdir,"sim","*.c")," ",
               "-lm"))
  if(file.exists(exe_file)) {
    message(paste0("* Created executable program '", exe_file, "'.")) 
  }
  return(exe_file)
}

mcsim <- function(exe_file, in_file, out_file="", 
                  setpoints_file = "",
                  modeldir = "model",
                  resultsdir = "results",
                  chainnum=1,
                  restartdir="",useposterior=FALSE,
                  runmodel=TRUE,...) {
  exe_file <- paste0("./",exe_file)
  in_file <- file.path(resultsdir,in_file)
  tx  <- readLines(in_file)
  MCMC_line <- grep("MCMC \\(", x=tx)
  MonteCarlo_line <- grep("MonteCarlo \\(", x=tx)
  SetPoints_line <- grep("SetPoints \\(", x=tx)
  
  if (length(MCMC_line) != 0){
    file_prefix <- str_split(in_file,".in.R",simplify=TRUE)[1]
	  # Chain input and output file
    chain_file <- paste0(file_prefix,chainnum,".in")
    RandomSeed <- exp(runif(1, min = 0, max = log(2147483646.0)))
    tx2 <- gsub(pattern = "10101010", replace = paste(RandomSeed), x = tx)
    if (restartdir!="") {
      firstdir <- str_split(resultsdir,"/",simplify=TRUE)[1]
      restart_file <- gsub(firstdir,restartdir,chain_file)
      if (useposterior) {
        restart_file <- sub(".in",".posterior.out",x=restart_file)
      } else {
        restart_file <- sub(".in",".out",x=restart_file)
      }
      tx2[MCMC_line] <- 
        sub(pattern = paste0("\"\""),replace = 
              paste0("\"",restart_file, "\""), 
            x = tx2[MCMC_line])
    }
    writeLines(tx2, con=paste0(chain_file))
    if (out_file == "") out_file <- paste0(file_prefix,chainnum,".out")
    if (runmodel) {
      message(paste("Execute MCMC:", exe_file, in_file, out_file))
      system(paste(exe_file,chain_file,out_file),...)
      if(file.exists(out_file)){
        message(paste0("* Created '", out_file, "'"))
      }
      df_out <- read.delim(out_file)
    } else {
      df_out <- data.frame()
    }
    
    # Check files
    check_infile <- paste0(file_prefix,chainnum,".check.in")
    check_outfile <- paste0(file_prefix,chainnum,".check.out")
    tx2 <- tx;
    if (sum(grepl(pattern = ",0,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Metropolis"
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",0,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
      restart_file <- out_file
    } else if (sum(grepl(pattern = ",3,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Tempered"
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",3,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
      restart_file <- paste0(file_prefix,chainnum,".posterior.out")
      if (runmodel) {
        maxIndexT <- max(df_out$IndexT)
        df_post <- subset(df_out,IndexT==maxIndexT)
        write.table(df_post,restart_file,row.names = FALSE,sep="\t")
      } else {
        df_post <- data.frame()
      }
    } else if (sum(grepl(pattern = ",4,",x = tx[MCMC_line:(MCMC_line+2)]))) {
      mcmctype <- "Thermodynamic"
      tx2[MCMC_line:(MCMC_line+2)] <- 
        sub(pattern = ",4,", replace = ",1,", x = tx[MCMC_line:(MCMC_line+2)])
      restart_file <- paste0(file_prefix,chainnum,".posterior.out")
      if (runmodel) {
        maxIndexT <- max(df_out$IndexT)
        df_post <- subset(df_out,IndexT==maxIndexT)
        write.table(df_post,restart_file,row.names = FALSE,sep="\t")
        df_prior <- subset(df_out,IndexT==0)
        if (nrow(df_prior)>0) write.table(df_prior,paste0(file_prefix,chainnum,".prior.out"))
      } else {
        df_post <- data.frame()
        df_prior <- data.frame()
      }
    }
    tx3 <- tx2;
    if (runmodel) {
      tx3[MCMC_line] <- 
        sub(pattern = paste0("\"\""),replace = 
              paste0("\"", restart_file, "\""), 
            x = tx2[MCMC_line])
    } else {
      tx3[MCMC_line] <- 
        sub(pattern = paste0("\"\""),replace = 
              paste0("\"", basename(restart_file), "\""), 
            x = tx2[MCMC_line])
    }
    writeLines(tx3, con=paste0(check_infile))
    if (runmodel) {
      message(paste("Execute MCMC Check:", exe_file, in_file, out_file))
      system(paste(exe_file,check_infile,check_outfile),...)
      if(file.exists(check_outfile)){
        message(paste0("* Created '", check_outfile, "' from the last iteration."))
      }
      df_check <- read.delim(check_outfile)
    } else {
      df_check <- data.frame()
    }
    if (mcmctype=="Metropolis") {
      df <- list(df_out=df_out,df_check=df_check)
    } else if (mcmctype == "Tempered") {
      df <- list(df_out=df_post,df_check=df_check,df_out_all=df_out)
    } else if (mcmctype == "Thermodynamic") {
      df <- list(df_out=df_post,df_check=df_check,df_out_prior=df_prior,df_out_all=df_out)
    }
  } else if (length(MonteCarlo_line) != 0){
    RandomSeed <- runif(1, 0, 2147483646)
    tx2 <- gsub(pattern = "10101010", replace = paste(RandomSeed), x = tx)
    writeLines(tx2, con=paste0(in_file))
    if (runmodel) {
      if (out_file == "") out_file <- file.path(resultsdir,"simmc.out")
      message(paste("Execute Monte Carlo:", exe_file, in_file, out_file))
      system(paste(exe_file, in_file, out_file),...)
      writeLines(tx, con=paste0(in_file))
      df <- read.delim(out_file)
    } else {
      df <- data.frame()
    }
  } else if (length(SetPoints_line) != 0){
    tx2 <- gsub(pattern = "X_setpoints",replace=setpoints_file,x=tx)
    writeLines(tx2, con = paste0(in_file))
    if (runmodel) {
      if (out_file == "") out_file <- file.path(resultsdir,"simSetPoints.out")
      message(paste("Execute Setpoints:", exe_file, in_file, out_file))
      system(paste(exe_file, in_file, out_file),...)
      df <- read.delim(out_file)
    } else {
      df <- data.frame()
    }
  } else {
    if (runmodel) {
      if (out_file == "") out_file <- file.path(resultsdir,"sim.out")
      message(paste("Execute:", exe_file, in_file, out_file))
      system(paste(exe_file, in_file, out_file),...)
      df <- read.delim(out_file, skip = 1)
    } else {
      df <- data.frame()
    }
  }
  return(df)
}

mcsim.multicheck <- function(model_file, in_file, 
                             chainnum.vec=1:4, warmup = NA, 
                             burnin = 0.5,
                             nsamp = 100) {
  exe_file <- paste0("./mcsim.", model_file, ".exe")
  
  tx  <- readLines(in_file)
  MCMC_line <- grep("MCMC \\(", x=tx)
  if (length(MCMC_line) != 0){
    file_prefix <- str_split(in_file,".in.R",simplify=TRUE)[1]
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
    allchains.samp <- allchains[sample(nrow(allchains),
                                       min(nsamp,nrow(allchains))),]
    out_file <- paste0(file_prefix,".tmp.out")
    check_infile <- paste0(file_prefix,".tmp.check.in")
    check_outfile <- paste0(file_prefix,".tmp.check.out")
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
      df_tmp <- read.delim(check_outfile)
      df_tmp$sampnum <- snum
      df_check <- rbind(df_check,df_tmp)
    }
    out_file <- paste0(file_prefix,paste0(chainnum.vec,collapse=""),".samps.out")
    write.table(allchains.samp,file=out_file,row.names = FALSE)
    check_outfile <- paste0(file_prefix,paste0(chainnum.vec,collapse=""),".samps.check.out")
    write.table(df_check,file=check_outfile,row.names=FALSE)
  } else {
    message("in_file is not MCMC file... cannot do checks")
  }
  return(list(parms.samp=allchains.samp,df_check=df_check))
}

# clear <- function(){
#   files <- c(dir(pattern = c("*.out")),
#              dir(pattern = c("sim.in")),
#              dir(pattern = c("*.R.exe")),
#              dir(pattern = c("*.R.so")),
#              dir(pattern = c("*.R.o")),
#              dir(pattern = c("*.R.dll")),
#              dir(pattern = c("*.R.c")),
#              dir(pattern = c("*.R_inits.R")),
#              dir(pattern = c("*.perks")))
#   invisible(file.remove(files))
# }
# 
# report <- function(){
#   cat("\n\n-----Report started line-----\n\n")
#   cat(Sys.getenv("PATH"), "\n")
#   print(Sys.which("gcc"))
#   system('gcc -v')
# }
# 
# readsims <- function(x, exp = 1){
#   ncols <- ncol(x)
#   index <- which(x[,1] == "Time")
#   str <- ifelse(exp == 1, 1, index[exp-1]+1)
#   end <- ifelse(exp == length(index)+1, nrow(x), index[exp]-2)
#   X <- x[c(str:end),]
#   ncolX <- ncol(X) 
#   X <- as.data.frame(matrix(as.numeric(as.matrix(X)), ncol = ncolX))
#   if (exp > 1) names(X) <- as.matrix(x[index[exp-1],])[1:ncols] else names(X) <- names(x)
#   X <- X[, colSums(is.na(X)) != nrow(X)]
#   return(X)  
# }
# 
# mcmc_array <- function(data, start_sampling = 0){
#   n_chains <- length(data)
#   sample_number <- dim(data[[1]])[1] - start_sampling
#   dim <- c(sample_number, n_chains, dim(data[[1]])[2])
#   n_iter <- dim(data[[1]])[1]
#   n_param <- dim(data[[1]])[2]
#   x <- array(sample_number:(n_iter * n_chains * n_param), dim = dim)
#   for (i in 1:n_chains) {
#     x[, i, ] <- as.matrix(data[[i]][(start_sampling + 1):n_iter, ])
#   }
#   dimnames(x)[[3]] <- names(data[[1]])
#   x
# }
