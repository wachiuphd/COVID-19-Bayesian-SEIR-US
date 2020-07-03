get_fips <- function(datadir="data") {
  fips_url<-"https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code"
  fips_table<-fips_url%>%
    read_html()%>%
    html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]')%>%
    html_table%>%
    as.data.frame()%>%
    filter(Alpha.code!="")%>%
    mutate(Numeric.code=as.character(Numeric.code))%>%
    mutate(Numeric.code=str_pad(Numeric.code, width=2, side="left", pad="0"))
  fips_table$numFIPS <- as.numeric(fips_table$Numeric.code)
  fips_table <- subset(fips_table,numFIPS<=56)
  pop<-read.csv(file.path(datadir,"SCPRC-EST2019-18+POP-RES.csv"))
  pop <- subset(pop,STATE <=56)
  rownames(pop) <- as.character(pop$STATE)
  fips_table$pop <- pop[as.character(fips_table$numFIPS),"POPESTIMATE2019"]
  fips_table <- rbind(data.frame(Name="United States",
                                 Alpha.code="US",
                                 Numeric.code="00",
                                 Status="Country",
                                 numFIPS=0,
                                 pop=pop$POPESTIMATE2019[
                                   pop$STATE==0
                                   ]),
                      fips_table)
  rownames(fips_table) <- fips_table$Alpha.code
  return(fips_table)
}
