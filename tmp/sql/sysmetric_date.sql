WITH snaps AS
(
    SELECT *
    FROM dba_hist_snapshot NATURAL JOIN dba_hist_database_instance
    WHERE begin_interval_time > __START_DATE__
    AND end_interval_time < __END_DATE__
    AND db_name = '__DBNAME__'
)
SELECT
  TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS begin_time , 
  SUM(value) AS value
FROM dba_hist_sysmetric_history NATURAL JOIN snaps 
WHERE metric_name IN ('__METRICS_NAME__')
GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI')
ORDER BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI')
