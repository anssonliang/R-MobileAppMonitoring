sql <- function() {
  "SELECT DATETIME,PROTOCOL,TRAFFIC_GB
  FROM(
  SELECT CAST(DATEADD(dd,cast((STARTTIME + 2*3600)/3600/24 as int),'19700101') AS date) DATETIME
  ,PROT.PROTOCOL
  ,SUM(ISNULL(l4_ul_throughput,0) + ISNULL(l4_dw_throughput,0))/(1024*1024*1024) TRAFFIC_GB
  from PS.SDR_FLOW_CELL_1DAY_%start_month VOL,
  (select PROTOCOL_ID, PROTOCOL from NETHOUSE.Z_CFG_APP_PROTOCOL
--where PROTOCOL in ('Cmore_Streaming')
--where PROTOCOL in (%prot_name)
  ) PROT
  WHERE PROT.PROTOCOL_ID = VOL.prot_type 
  AND VOL.STARTTIME >= %st_date
  AND VOL.STARTTIME < %end_date
  GROUP BY DATETIME,PROT.PROTOCOL
  UNION
  SELECT CAST(DATEADD(dd,cast((STARTTIME + 2*3600)/3600/24 as int),'19700101') AS date) DATETIME
  ,PROT.PROTOCOL
  ,SUM(ISNULL(l4_ul_throughput,0) + ISNULL(l4_dw_throughput,0))/(1024*1024*1024) TRAFFIC_GB
  from PS.SDR_FLOW_CELL_1DAY_%end_month VOL,
  (select PROTOCOL_ID, PROTOCOL from NETHOUSE.Z_CFG_APP_PROTOCOL
--where PROTOCOL in ('Cmore_Streaming')
--where PROTOCOL in (%prot_name)
  ) PROT
  WHERE PROT.PROTOCOL_ID = VOL.prot_type
  AND VOL.STARTTIME >= %st_date
  AND VOL.STARTTIME < %end_date
  GROUP BY DATETIME,PROT.PROTOCOL
  ) COMB
  --WHERE DATEPART(WEEKDAY,DATETIME) IN (2,3,4,5,6)
  ORDER BY DATETIME
  ;COMMIT;"
}