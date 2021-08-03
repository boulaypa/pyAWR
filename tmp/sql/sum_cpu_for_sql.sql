WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 3 ),
cpu_usage AS ( 
    SELECT begin_interval_time,
           SUM(cpu_time_delta) AS cpu
    FROM dba_hist_sqlstat  
         NATURAL JOIN  snaps
    GROUP BY begin_interval_time
)
SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') begin_time,
       ROUND(cpu/(1024*1024)) value
FROM cpu_usage
ORDER BY begin_interval_time ASC
