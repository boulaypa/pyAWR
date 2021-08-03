WITH snaps AS
(
    SELECT s.* /*+ materialize */
    FROM dba_hist_snapshot s , dba_hist_database_instance i
    WHERE s.begin_interval_time >= __START_DATE__
    AND s.end_interval_time <= __END_DATE__
    AND s.dbid = i.dbid
    AND s.instance_number = i.instance_number
    AND s.startup_time = i.startup_time
),
data as (
    SELECT /*+ materialize */
        begin_interval_time,
        CASE WHEN value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) < 0 
            THEN value 
        ELSE value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) 
        END value
    FROM
        dba_hist_sysstat ss , snaps s
    WHERE  ss.stat_name = '__METRICS_NAME__'
    AND    ss.snap_id = s.snap_id
    AND    ss.dbid = s.dbid
    AND    ss.instance_number = s.instance_number
)
SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time,
       value
FROM data
