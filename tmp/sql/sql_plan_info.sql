WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00'
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
)
SELECT begin_interval_time AS snap_time,
       plan_hash_value,
       To_char(begin_interval_time, 'dd-mon-yy hh24:mi') btime,
       Abs(Extract(minute FROM ( end_interval_time - begin_interval_time )) +
               Extract(hour FROM ( end_interval_time - begin_interval_time )) *
               60 +
           Extract(day FROM ( end_interval_time - begin_interval_time )) * 24 *
           60)
                                                         minutes,
       executions_delta                                  executions,
       Round(elapsed_time_delta / 1000000 / Greatest(executions_delta, 1), 4) "avg duration (sec)"
FROM   dba_hist_sqlstat NATURAL JOIN snaps
WHERE  sql_id = '__SQL_ID__'
ORDER  BY begin_interval_time
