WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00'
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
)
SELECT t1.plan_hash_value plan_hash_value, 
       t2.avg_et_secs avg_et_secs, 
       t2.avg_px, 
       t1.cost cost, 
       t1.timestamp timestamp, 
       parsing_schema_name
FROM ( dba_hist_sql_plan natural join snaps ) t1,
     (
                SELECT sql_id, plan_hash_value, 
                round(SUM(elapsed_time_total)/decode(SUM(executions_total),0,1,SUM(executions_total))/1e6/
                decode(SUM(px_servers_execs_total),0,1,SUM(px_servers_execs_total))/decode(SUM(executions_total),0,1,SUM(executions_total)),2)  avg_et_secs,
                SUM(px_servers_execs_total)/decode(SUM(executions_total),0,1,SUM(executions_total)) avg_px
                FROM dba_hist_sqlstat NATURAL JOIN snaps
                WHERE executions_total > 0
                GROUP BY sql_id, plan_hash_value
        ) t2
WHERE t1.sql_id = 'c4jv0rj7bcnb4'
AND t1.depth = 0
AND t1.sql_id = t2.sql_id(+)
AND t1.plan_hash_value = t2.plan_hash_value(+)
order by avg_et_secs, cost
/
