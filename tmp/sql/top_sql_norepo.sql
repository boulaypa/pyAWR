WITH snaps AS
(
   SELECT
      *
   FROM
      dba_hist_snapshot
   WHERE begin_interval_time > __START_DATE__
   AND end_interval_time < __END_DATE__
   AND extract(hour from BEGIN_INTERVAL_TIME) >= __STIME__
   AND extract(hour from END_INTERVAL_TIME) <= __ETIME__
),
sqlstat AS   (    SELECT stat.dbid,  
                         stat.instance_number,  
                         stat.snap_id,  
                         stat.parsing_user_id,
                         snaps.begin_interval_time,  
                         stat.sql_id,  
                         stat.plan_hash_value,  
                         stat.end_of_fetch_count_delta,  
                         stat.sorts_delta,  
                         stat.px_servers_execs_delta,  
                         stat.loads_delta,  
                         stat.invalidations_delta,  
                         stat.buffer_gets_delta,  
                         stat.disk_reads_delta,  
                         stat.cpu_time_delta,  
                         stat.elapsed_time_delta,  
                         stat.fetches_delta,  
                         stat.rows_processed_delta,  
                         stat.executions_delta,  
                         stat.parse_calls_delta,  
                         stat.iowait_delta,  
                         stat.clwait_delta,  
                         stat.apwait_delta,  
                         stat.ccwait_delta,  
                         stat.direct_writes_delta,  
                         stat.plsexec_time_delta,  
                         stat.javexec_time_delta,  
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.buffer_gets_delta / stat.executions_delta  
                           ELSE 0  
                         END                       buffer_gets_x_delta,  
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.disk_reads_delta / stat.executions_delta  
                           ELSE 0  
                         END                       disk_reads_x_delta,  
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.cpu_time_delta / stat.executions_delta  
                           ELSE 0  
                         END                       cpu_time_x_delta,  
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.elapsed_time_delta / stat.executions_delta  
                           ELSE 0  
                         END                       elapsed_time_x_delta,  
                         CASE  
                           WHEN stat.buffer_gets_delta > 0 THEN  
                           stat.disk_reads_delta / stat.buffer_gets_delta  
                           ELSE 0  
                         END                       plio_ratio_delta,  
                         CASE  
                           WHEN stat.elapsed_time_delta > 0 THEN  
                           stat.cpu_time_delta / stat.elapsed_time_delta  
                           ELSE 0  
                         END                       cpu_ela_ratio_delta,  
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.rows_processed_delta / stat.executions_delta  
                           ELSE 0  
                         END                       rows_processed_x_delta,
                         CASE  
                           WHEN stat.executions_delta > 0 THEN  
                           stat.parse_calls_delta / stat.executions_delta  
                           ELSE 0  
                         END                       parse_calls_x_delta  
                  FROM   dba_hist_sqlstat stat,  
                         snaps  
                  WHERE  stat.snap_id = snaps.snap_id  
                         AND PARSING_SCHEMA_NAME = '__SCHEMA__'
                         AND stat.dbid = snaps.dbid  
                         AND stat.instance_number = snaps.instance_number  
                         ),  
 top  
      AS (SELECT dbid, sql_id, plan_hash_value, parsing_user_id, top_delta, top_pct, top_total, RANK() OVER ( ORDER BY top_delta DESC ) rank  
          FROM   (SELECT   DISTINCT dbid, sql_id,  
                                    plan_hash_value,  
                                    parsing_user_id,
                                    delta top_delta,  
                                    (delta / total) * 100 AS top_pct,  
                                    total AS top_total  
                  FROM     (SELECT dbid, sql_id,  
                                   plan_hash_value,  
                                   parsing_user_id,  
                                   SUM(NVL(__METRICS_NAME__,0)) OVER (PARTITION BY 1) total,
                                   SUM(NVL(__METRICS_NAME__,0)) OVER (PARTITION BY dbid,sql_id,plan_hash_value,parsing_user_id) delta  
                            FROM sqlstat WHERE plan_hash_value > 0  
                                   ) x  
                  ORDER BY top_pct DESC)  
          WHERE  ROWNUM <= __TOP__ ),  
top_w_user as (
    select top.*,
           d.username
    from top, dba_users d
    where d.user_id=top.parsing_user_id
),
plandate  
      AS (SELECT *  
          FROM   (SELECT DISTINCT sql_id, plan_hash_value, operation,  
                         MIN(TIMESTAMP) OVER(PARTITION BY sql_id, plan_hash_value, operation ) plan_date
                  FROM   dba_hist_sql_plan p  
                  WHERE  id=0  
                  AND    (sql_id,plan_hash_value) IN ( select sql_id,plan_hash_value FROM top ) and plan_hash_value > 0 )),  
snap_top_cp AS (  
    SELECT snaps.*, 
           top_w_user.username,
           top_w_user.sql_id, 
           top_w_user.plan_hash_value, 
           top_w_user.top_pct, 
           top_w_user.top_delta, 
           top_w_user.top_total, 
           top_w_user.rank, 
           plandate.operation, 
           plandate.plan_date
    FROM snaps,top_w_user,plandate WHERE top_w_user.sql_id=plandate.sql_id(+) AND top_w_user.plan_hash_value=plandate.plan_hash_value(+) ),  
 data AS ( SELECT   sh.dbid,sh.snap_id,sh.begin_interval_time, 
          stat.sql_id,  
          stat.plan_hash_value,  
          NVL(stat.__METRICS_NAME__,0) delta  
 FROM     top_w_user top,  
          sqlstat stat,  
          snaps sh  
          WHERE    stat.sql_id (+)  = top.sql_id  
          AND      stat.plan_hash_value (+)  = top.plan_hash_value  
          AND      stat.dbid = sh.dbid  
          AND      stat.instance_number = sh.instance_number  
          AND      stat.snap_id = sh.snap_id  
          )  
 SELECT s.begin_interval_time time ,  
        s.sql_id,
        s.plan_hash_value,
        s.plan_date,
        TO_CHAR(rank, '09' ) ||' '|| 
        TO_CHAR(top_pct, '09' )||' '||
        s.sql_id ||' '||TO_CHAR(s.plan_hash_value, '999999999999999')||' '||username as src,  
        s.rank as rank,  
        NVL(p.delta,0) as metrics,  
        NVL(s.top_delta,0) as top_delta,  
        NVL(s.top_pct,0) as top_pct,  
        NVl(s.top_total,0) as top_total,  
        s.operation,
        s.username
 FROM (  
     SELECT data.snap_id,
            data.begin_interval_time,  
            data.dbid,  
            data.sql_id,  
            data.plan_hash_value,  
            data.delta  
     FROM   data  
       ) p ,  snap_top_cp s  
     WHERE p.snap_id (+) = s.snap_id  
     AND   p.dbid (+) = s.dbid  
     AND   p.sql_id (+) = s.sql_id  
     AND   p.plan_hash_value (+) = s.plan_hash_value  
 ORDER BY s.top_pct,s.begin_interval_time DESC
