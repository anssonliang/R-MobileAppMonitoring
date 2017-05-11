package <- c("xlsx","RDCOMClient","xts", "reshape", "rmarkdown")
lapply(package, require, character.only = TRUE)

source("./cfg.R")
source("./drv/rDBConnection.R")
source("./query/rSQL.R")
source("./query/rQuery.R")
source("./helper.R")
source("./mail/rMail.R")

alertComment()

render('./dashboard/dashboard.Rmd')

delete()

attachAll()