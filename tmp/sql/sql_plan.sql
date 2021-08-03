WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00'
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
)
SELECT end_interval_time,
       sql_id,
       plan_hash_value,
       ROUND(elapsed_time_total/1000000,2) AS ElapsedTotal,
       executions_total,
       ROUND((elapsed_time_total/1000000)/executions_total,2) AS ElapsedPerExec
FROM dba_hist_sqlstat NATURAL JOIN snaps
WHERE sql_id IN =''
AND executions_total       > 0
ORDER BY end_interval_time,
