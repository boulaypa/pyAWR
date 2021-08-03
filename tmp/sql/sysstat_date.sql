WITH snaps AS
(
    SELECT * /*+ materialize */
    FROM dba_hist_snapshot NATURAL JOIN dba_hist_database_instance
    WHERE begin_interval_time >= __START_DATE__
    AND end_interval_time <= __END_DATE__
    AND db_name = '__DBNAME__'
),
data as (
    SELECT /*+ materialize */
        begin_interval_time,
        CASE WHEN value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) < 0 
            THEN value 
        ELSE value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) 
        END value
    FROM
        dba_hist_sysstat NATURAL JOIN
     snaps
    WHERE  stat_name = '__METRICS_NAME__'
)
SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time,
       value
FROM data
