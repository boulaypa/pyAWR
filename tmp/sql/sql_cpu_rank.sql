SELECT *
FROM
  (SELECT s.sql_id,
          RANK() OVER ( ORDER BY (max(s.CPU_TIME_TOTAL/s.executions_total)) DESC) cpu_rank,
          RANK() OVER ( ORDER BY (max(s.ELAPSED_TIME_TOTAL/s.EXECUTIONS_TOTAL)) DESC) elapsed_rank
   FROM dba_hist_sqlstat s,
        dba_hist_snapshot sn
   WHERE sn.begin_interval_time BETWEEN to_date('06-aug-2014 0001', 'dd-mon-yyyy hh24mi') AND to_date('13-aug-2014 0600', 'dd-mon-yyyy hh24mi')
     AND sn.snap_id=s.snap_id
     AND s.executions_total >0
   GROUP BY s.sql_id)
WHERE cpu_rank <=100
  AND elapsed_rank<=100;

SELECT sql_id,
       RANK() OVER ( ORDER BY (max(CPU_TIME_TOTAL/executions_total)) DESC) cpu_rank
FROM dba_hist_snapshot NATURAL JOIN
    dba_hist_sqlstat NATURAL JOIN
    dba_hist_database_instance
WHERE db_name = 'NTOP00' AND begin_interval_time > SYSDATE - 3;

WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 10 )
SELECT s.sql_id,
       RANK() OVER ( ORDER BY (max(s.CPU_TIME_TOTAL/s.executions_total)) DESC) cpu_rank,
       RANK() OVER ( ORDER BY (max(s.ELAPSED_TIME_TOTAL/s.EXECUTIONS_TOTAL)) DESC) elapsed_rank
FROM dba_hist_sqlstat s,
     snaps sn
WHERE sn.snap_id=s.snap_id
AND sn.dbid=s.dbid
AND s.executions_total >0
GROUP BY s.sql_id
ORDER BY cpu_rank DESC;
