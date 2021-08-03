WITH snaps AS
(
    SELECT s.snap_id,s.snap_time,i.dbid  /*+ materialize */
    FROM perfstat.STATS$SNAPSHOT s , perfstat.STATS$DATABASE_INSTANCE i
    WHERE s.snap_time BETWEEN __START_DATE__ AND __END_DATE__
    AND i.db_name = '__DBNAME__'
    AND i.instance_number = s.instance_number
    AND i.startup_time = s.startup_time
    AND s.dbid = i.dbid
),
data as (
    SELECT /*+ materialize */
        snap_time,
        CASE WHEN value - LAG(value) OVER (PARTITION BY name ORDER BY snap_time) < 0 
            THEN value 
        ELSE value - LAG(value) OVER (PARTITION BY name ORDER BY snap_time) 
        END value
    FROM
        perfstat.STATS$SYSSTAT NATURAL JOIN
     snaps
    WHERE  name = '__METRICS_NAME__'
)
SELECT TO_CHAR(snap_time,'YYYYMMDDHH24MI') AS snap_time,
       value
FROM data
