# set a number that dates back to historical data
dateBack_Start <- 14 # change date here
dateBack_End   <- 0

# get the start of unix time (summer time 03:00, winter time 02:00)
unixTime <- strptime('1970-01-01 03:00:00', format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Stockholm")