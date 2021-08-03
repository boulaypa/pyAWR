SELECT
  TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') begin_time
  , metric_unit
  , value
FROM dba_hist_snapshot NATURAL JOIN
    dba_hist_sysmetric_history NATURAL JOIN
    dba_hist_database_instance 
WHERE
    metric_name IN ('__METRICS_NAME__')
AND begin_interval_time > SYSDATE - 300
AND db_name = 'NTOP00'
ORDER BY metric_name , begin_time
