get_testdata <- function(remove_zero_negative=TRUE,
                         remove_zero_value=FALSE,
                         datezero="2019-12-31",
                         mindate="2020-03-19",
                         mincases=10) {
  download <- getURL("https://covidtracking.com/api/v1/states/daily.csv")
  dat <- read.csv(text = download,as.is=TRUE)
  dat$date <- as.Date(as.character(dat$date),tryFormats = c("%Y%m%d"))
  dat$numDate <- as.numeric(dat$date)-as.numeric(as.Date(datezero))
  if (remove_zero_negative) dat <- subset(dat,negative>0)
  dat <- subset(dat,positive >= mincases)
  dat <- subset(dat,date >= as.Date(mindate))
  dat.df <- melt(as.data.table(dat[,c(
    "date","numDate","state","fips",
    "positiveIncrease",
    "deathIncrease")]),
    id.vars=1:4)
  dat.df <- dat.df[order(dat.df$variable,dat.df$numDate),]
  dat.df <- subset(dat.df,value>=0) # Get rid of negative values
  if (remove_zero_value) dat.df <- subset(dat.df,value>0)
  return(dat.df)
}

get_meantestdata <- function(datezero="2019-12-31",
                         mindate="2020-03-19",
                         nmean=7) {
  download <- getURL("https://covidtracking.com/api/v1/states/daily.csv")
  dat <- read.csv(text = download,as.is=TRUE)
  dat$date <- as.Date(as.character(dat$date),tryFormats = c("%Y%m%d"))
  dat$numDate <- as.numeric(dat$date)-as.numeric(as.Date(datezero))
  meandat <- data.frame()
  for (statenow in unique(dat$state)) {
    tmpdat <- subset(dat,state==statenow)
    tmpdat <- tmpdat[order(tmpdat$numDate),]
    tmpdat$meanpositiveIncrease <- 
      frollmean(tmpdat$positiveIncrease,nmean,align="center",na.rm=TRUE)
    tmpdat$meandeathIncrease <- 
      frollmean(tmpdat$deathIncrease,nmean,align="center",na.rm=TRUE)
    meandat <- rbind(meandat,tmpdat)
  }
  dat<-meandat
  dat <- subset(dat,date >= as.Date(mindate))
  dat.df <- melt(as.data.table(dat[,c(
    "date","numDate","state","fips",
    "meanpositiveIncrease",
    "meandeathIncrease")]),
    id.vars=1:4)
  dat.df <- dat.df[order(dat.df$variable,dat.df$numDate),]
  return(dat.df)
}

get_testdata_usa <- function(remove_zero_negative=TRUE,
                             remove_zero_value=TRUE,
                             datezero="2019-12-31") {
  download <- getURL("https://covidtracking.com/api/v1/us/daily.csv")
  dat <- read.csv(text = download,as.is=TRUE)
  dat$date <- as.Date(as.character(dat$date),tryFormats = c("%Y%m%d"))
  dat$numDate <- as.numeric(dat$date)-as.numeric(as.Date(datezero))
  if (remove_zero_negative) dat <- subset(dat,negative>0)
  dat.df <- melt(as.data.table(dat[,c(
    "date","numDate",
    "positiveIncrease",
    "deathIncrease")]),
    id.vars=1:2)
  dat.df <- dat.df[order(dat.df$variable,dat.df$numDate),]
  if (remove_zero_value) dat.df <- subset(dat.df,value>0)
  return(dat.df)
}

get_cumul_testdata <- function(remove_zero_negative=TRUE,
                               remove_zero_value=TRUE,
                               datezero="2019-12-31",
                               mindate="2020-03-19",
                               mincases=10) {
  download <- getURL("https://covidtracking.com/api/v1/states/daily.csv")
  dat <- read.csv(text = download,as.is=TRUE)
  dat$date <- as.Date(as.character(dat$date),tryFormats = c("%Y%m%d"))
  dat$numDate <- as.numeric(dat$date)-as.numeric(as.Date(datezero))
  if (remove_zero_negative) dat <- subset(dat,negative>0)
  dat <- subset(dat,positive >= mincases)
  dat <- subset(dat,date >= as.Date(mindate))
  dat.df <- melt(as.data.table(dat[,c(
    "date","numDate","state","fips",
    "positive",
    "death")]),
    id.vars=1:4)
  dat.df <- dat.df[order(dat.df$variable,dat.df$numDate),]
  if (remove_zero_value) dat.df <- subset(dat.df,value>0)
  return(dat.df)
}

get_cumul_testdata_usa <- function(remove_zero_negative=TRUE,
                                   remove_zero_value=TRUE,
                                   datezero="2019-12-31") {
  download <- getURL("https://covidtracking.com/api/v1/us/daily.csv")
  dat <- read.csv(text = download,as.is=TRUE)
  dat$date <- as.Date(as.character(dat$date),tryFormats = c("%Y%m%d"))
  dat$numDate <- as.numeric(dat$date)-as.numeric(as.Date(datezero))
  if (remove_zero_negative) dat <- subset(dat,negative>0)
  dat.df <- melt(as.data.table(dat[,c(
    "date","numDate",
    "positive",#"negative",
    "death")]),
    id.vars=1:2)
  dat.df <- dat.df[order(dat.df$variable,dat.df$numDate),]
  if (remove_zero_value) dat.df <- subset(dat.df,value>0)
  return(dat.df)
}