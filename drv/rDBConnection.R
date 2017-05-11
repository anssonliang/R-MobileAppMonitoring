library (RJDBC)

# JDBC driver
driverClass <- "com.sybase.jdbc4.jdbc.SybDriver"
classPath   <- file.path("./drv/jconnect16.jar")

# Connection credentials
ip        <- "127.0.0.1"
port      <- "8888"
userName  <- "nethouse"
password  <- "NetViewCommon2012"
url       <- paste0("jdbc:sybase:Tds:", ip, ":", port)

LogMsg    <- function(...){
  print (paste(Sys.time(), paste0("'", userName, ":'"), paste0(...), sep = " ")) # show log
}

# Connect to IQ DB and do query
getIqData <- function(sql){
  
  sql
  # open jdbc
  iq_db_init      <- function(){
    .jinit()
    jdbcDriver <- JDBC(driverClass, classPath)
    jdbcDriver
  }
  # conncect to IQ database
  iq_dbConnection <- function(){
    
    jdbcConnection <- function(){}
    
    jdbcConnection <- tryCatch({
      dbConnect(iq_db_init(), url, userName, password)
    },
    warning = function (w){
      LogMsg("DB Connection Warning: ", w$message)
    },
    error   = function (e) {
      LogMsg("DB Connection Error: "  , e$message)
    }
    )
    jdbcConnection
  }
  # disconnect to IQ database
  iq_dbDisconect  <- function(conn){
    LogMsg(
      tryCatch({
        dbDisconnect(conn)
        "DB connection closed"
      },
      warning = function (w){
        paste0("DB disconnection warning: ", w)
      },
      error = function (e) {
        paste0("DB disconnection error: "  , e)
      }
      )
    )
  }
  # run query
  do_query <- function(conn, sql, ...){
    
    LogMsg("Starting query...")
    
    sqlResult <- tryCatch({
      dbGetQuery(conn, sql, ...) # apply for each sql elements
    },
    warning = function (w){
      LogMsg("warning: Query failed to get data", w$message)
      data.frame()
    },
    error = function (e) {
      LogMsg("error: Query failed to get data", e$message)
      data.frame()
    })
    LogMsg("Ending query...")
    
    sqlResult ## output is data frame
  }
  
  IqConn <- iq_dbConnection()
  
  df <- do_query(IqConn, sql)
  
  iq_dbDisconect(IqConn)
  
  print(df)
  df
  
}