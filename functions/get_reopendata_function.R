get_reopendata <- function(datadir="data",
                           datezero="2019-12-31") {
  reopendat <- read.csv(file.path(datadir,"ReopeningData.csv"),as.is=TRUE)
  names(reopendat)[2]<-"State.Abbr"
  reopendat[reopendat==""]<-NA
  for (j in 4:10) reopendat[[j]]<-as.Date(reopendat[[j]])
  reopendat.df <- melt(as.data.table(reopendat),id.vars=1:3)
  names(reopendat.df)[4]<-"ReopenType"
  reopendat.df$numDate <- as.numeric(reopendat.df$value)-
    as.numeric(as.Date(datezero))
  return(reopendat.df)
}
