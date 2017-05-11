# replace patterns in SQL script
#substituteFun <- function(sql, st_date = Sys.Date() - 1, end_date = Sys.Date() - 0){ # change date heres
substituteFun <- function(sql, st_date_input, end_date_input){
  st_date  <- as.numeric(difftime(st_date_input , unixTime, units = "sec"))
  end_date <- as.numeric(difftime(end_date_input, unixTime, units = "sec"))
  
  sql <- replace_date (sql, st_date, end_date, start_month = months(), end_month = months()+1 )
  #sql <- replace_param(sql, prot_name = prot_name())
  print(sql)
  sql
}

# run SQL queries and restructure query results
queryKQIs <-  function(){
  
  # nested query functions for each sql element
  queryRes <<- getIqData(substituteFun(sql(), Sys.Date() - dateBack_Start, Sys.Date() - dateBack_End )) # date changed

  uniq_prot <- unique(queryRes["PROTOCOL"])
  protTraf <- list()
  
  for(i in 1:nrow(uniq_prot)){
    prot <- unique(queryRes["PROTOCOL"])[i,]
    protTraf[[prot]] <- subset(queryRes["TRAFFIC_GB"], queryRes["PROTOCOL"]==prot)
    names(protTraf[[prot]]) <- prot
  }
  protTraf
}