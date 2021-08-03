WITH ssf AS
(
   SELECT
      *
   FROM
      dba_hist_snapshot JOIN
         dba_hist_database_instance
   USING(dbid,instance_number,startup_time)
   WHERE begin_interval_time > __START_DATE__
   AND end_interval_time < __END_DATE__
),
sqlstat AS   (    SELECT stat.dbid,  
                         stat.instance_number,  
                         stat.snap_id,  
                         stat.parsing_user_id,
                         ssf.begin_interval_time,  
                         stat.sql_id,  
                         stat.plan_hash_value,  
                         stat.end_of_fetch_count_delta,  
                         stat.sorts_delta,  
                         stat.px_servers_execs_delta,  
                         stat.loads_delta,  
                         stat.invalidations_delta,  
                         stat.physical_read_bytes_delta,  
                         stat.physical_write_bytes_delta,  
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
                         ssf  
                  WHERE  stat.snap_id = ssf.snap_id  
                         AND stat.dbid = ssf.dbid  
                         AND stat.sql_id='__SQL_ID__'
                         AND stat.instance_number = ssf.instance_number  
                         AND stat.dbid = ssf.dbid  
                         ),  
 data AS ( 
    SELECT   TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') SNAP_TIME, 
             TO_CHAR(plan_hash_value, '999999999999999') AS  SRC,  
             NVL(__METRICS_NAME__,0) METRICS  
    FROM     sqlstat
 )
SELECT * FROM data
