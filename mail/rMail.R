## GENERATE ALERT COMMENTS BY PROTOCOL CHANGE
alertComment <- function(){
  res <- queryKQIs()
  
  ## DETECT SUBSTANTIAL DECREASE
  downScale_count <- function(prot){
    ifelse(scaleDown(as.vector(t(prot)))>0,paste0(names(prot),' dropped remarkably ',scaleDown(as.vector(t(prot))),' times!','<p></p>'),'')
  }
  
  downScale_prot <- lapply(res,downScale_count)%>%
    (function(x){x[!is.na(x)]})%>%
    (function(x){x[x!='']})
  
  if(length(downScale_prot)>0){
  downScale_subName  <- names(do.call("cbind",downScale_prot)[1,])
  
  downScale_subset   <- data.frame()
  
  for(i in 1:length(downScale_subName)){
    tmp <- subset(queryRes,PROTOCOL==downScale_subName[i])   
    downScale_subset <- rbind(downScale_subset,tmp)
  }
  ## CONVERT TO TIME-SERIES                      ##
  downScale_prot_traf <- cast(downScale_subset, DATETIME ~ PROTOCOL, sum, value = 'TRAFFIC_GB')
  downScale_subset_ts <- xts(downScale_prot_traf[,-1], order.by = as.Date(downScale_prot_traf[,1], format = "%Y-%m-%d"))
  names(downScale_subset_ts) <- downScale_subName
  ## GENERATE COMMENT   ##
  downScale_comment <<- paste(c(do.call("cbind",downScale_prot)),collapse = '')
  }
  else downScale_comment <<- paste0('<p>NULL</p>')
  
  ## DETECT SUBSTANTIAL INCREASE
  upScale_count <- function(prot){
    ifelse(scaleUp(as.vector(t(prot)))>0,paste0(names(prot),' rised remarkably ',scaleUp(as.vector(t(prot))),' times!','<p></p>'),'')
  }
  
  upScale_prot <- lapply(res,upScale_count)%>%
    (function(x){x[!is.na(x)]})%>%
    (function(x){x[x!='']})
  
  if(length(upScale_prot)>0){
    upScale_subName  <- names(do.call("cbind",upScale_prot)[1,])
    
    upScale_subset   <- data.frame()
    
    for(i in 1:length(upScale_subName)){
      tmp <- subset(queryRes,PROTOCOL==upScale_subName[i])   
      upScale_subset <- rbind(upScale_subset,tmp)
    }
    ## CONVERT TO TIME-SERIES                      ##
    upScale_prot_traf <- cast(upScale_subset, DATETIME ~ PROTOCOL, sum, value = 'TRAFFIC_GB')
    upScale_subset_ts <- xts(upScale_prot_traf[,-1], order.by = as.Date(upScale_prot_traf[,1], format = "%Y-%m-%d"))
    names(upScale_subset_ts) <- upScale_subName
    ## GENERATE COMMENT   ##
    upScale_comment <<- paste(c(do.call("cbind",upScale_prot)),collapse = '')
  }
  else upScale_comment <<- paste0('<p>NULL</p>')
  
  ## GENERATE TITLES
  downScale_title <<- paste0('<p><span style="font-size: 15px"><b>Remarkable Decrement Alerts*</b></span></p>')
  upScale_title   <<- paste0('<p><span style="font-size: 15px"><b>Remarkable Increment Alerts*</b></span></p>')

  ## SAVE TIME SERIES DATA FOR DASHBOARD         ##
  if(length(downScale_prot)>0) {save(downScale_subset_ts, file="./dashboard/DOWNSCALE.RData")}
  if(length(upScale_prot)>0) {save(upScale_subset_ts, file="./dashboard/UPSCALE.RData")}
  
}

# create an email with embeded HTLM contents
attachAll <- function(){
  ## init com api for outlook
  outApp  <- COMCreate("Outlook.Application")
  ## create an email
  outMail = outApp$CreateItem(0)
  
  ## configure  email parameter
  outMail[["To"]] = "anson.liang@huawei.com;Hng.Chun.Hua@huawei.com;Erik.Gade.Nielsen@huawei.com;shanni.gao@huawei.com;yelin.wang@huawei.com;lyubcho.toshev@huawei.com;"
  outMail[["Cc"]] = "suyu@huawei.com;heqibing.he@huawei.com;"
  #outMail[["To"]] = "anson.liang@huawei.com"
  
  outMail[["subject"]] = paste0("Traffic Monitoring on App-based Protocols ", Sys.Date() - dateBack_Start)
  
  # get outlook signiture
  outMail$GetInspector()
  signature = outMail[["HTMLBody"]]
  
  # attach html file
  dirHtml <- paste0(getwd(),"/dashboard/dashboard.html")
  outMail[["Attachments"]]$Add(dirHtml)

  # html body
  outMail[["HTMLBody"]] = paste0(
    '<p>This traffic monitoring detects abnormal trend on each app-based protocol from <i>z_CFG_APP_PROTOCOL</i> table.</p>',
    '<p>If you are interested in the graphical abnormal traffic, please refer to the attached <i>dashboard.html</i>.</p>',
    downScale_title,
    downScale_comment,
    upScale_title,
    upScale_comment,
    '<p>*One of the criteria to measure substantial change is taking the distance of actual data from the average by <a href="https://en.wikipedia.org/wiki/Standard_score">Standardized Variables</a>.</p>',
    signature
  )
  
  ## send email
  LogMsg(
    tryCatch({
      outMail$Send()
      "Email Sent!" # Log
    },
    warning = function (w){
      paste0("email sent warning: ", w) # Log
    },
    error = function (e) {
      paste0("email sent error: "  , e) # Log
    }
    )
  )
}