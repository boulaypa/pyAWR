WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 30 ),
cpu_usage AS ( 
    SELECT snap_id,
           SUM(cpu_time_delta) AS cpu
    FROM dba_hist_sqlstat  
         NATURAL JOIN  snaps
    WHERE sql_id='00whjfj8n052v'
    GROUP BY snap_id
)
SELECT * 
FROM cpu_usage
ORDER BY snap_id
/
