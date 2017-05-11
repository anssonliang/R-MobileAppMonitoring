library(stringr)

# calculate months from unix Time in number
months <- function(date = Sys.Date()){
  ct <- seq(as.POSIXct(Sys.Date() - dateBack_Start), by = 400, length.out = 10)[10]
  start_month <- length(seq(from = unixTime,to = ct, by = 'month'))-1
  start_month
}

# prot_name <- function(){
#   csv  <- read.csv("z_CFG_APP_PROTOCOL.csv", header = TRUE, stringsAsFactors = FALSE)
#   name <- as.character(t(csv["PROTOCOL"]))
#   prot_length <<- length(name) 
#   name <- paste0("\'", name, "\'")
#   paste(name, collapse = ",")
# }

# replace pattern in SQL script
replace_date <- function(sql, st_date, end_date, start_month = character(), end_month = character()){
  if(class(st_date) == class(numeric()) && class(end_date) == class(numeric())){
    sql <- gsub(pattern = "%st_date" , replacement = st_date , sql)
    sql <- gsub(pattern = "%end_date", replacement = end_date, sql)
    sql <- gsub(pattern = "%start_month", replacement = start_month, sql)
    sql <- gsub(pattern = "%end_month", replacement = end_month, sql)
    sql
  }else{
    LogMsg("Start or end date is not a number")
  }
}

# replace_param <- function(sql, prot_name = character()){
#   sql <- gsub(pattern = "%prot_name", replacement = prot_name, sql)
#   sql
# }

# standardized decreasing traffic
scaleDown <- function(dataSeries) {

  scaleData <- scale(dataSeries)
  
  sumDown = 0
  
  for (i in 1:length(diff(scaleData))) {
    sumDown <- ifelse (diff(scaleData)[i]<=(-2.5) 
                       && (dataSeries[i+1] <= 0.5*dataSeries[i]) 
                       && dataSeries[i+1] <= min(dataSeries[1:i])
                       && mean(dataSeries) >= 100,
                       sumDown +1, sumDown
    )
  }
  sumDown
}

# standardized decreasing traffic
scaleUp <- function(dataSeries) {
  
  scaleData <- scale(dataSeries)
  
  sumUp = 0
  
  for (i in 1:length(diff(scaleData))) {
    sumUp <- ifelse (diff(scaleData)[i]>=(2.5) 
                       && (dataSeries[i+1] >= 1.5*dataSeries[i]) 
                       && dataSeries[i+1] >= max(dataSeries[1:i])
                       && mean(dataSeries) >= 100,
                       sumUp +1, sumUp
    )
  }
  sumUp
}

delete <- function() { 
  fileName <- list.files(paste0(getwd(),'/dashboard'),paste("^[A-Z].*",".*RData$", sep=""))
  fileDir   <- paste0(getwd(),"/dashboard")
  filePath  <- file.path(fileDir,fileName)
  if (unique(file.exists(filePath))) file.remove(filePath)
}