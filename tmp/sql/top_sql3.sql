 SELECT T1.*, DBA_HIST_SQLTEXT.sql_text,dba_hist_snapshot.BEGIN_INTERVAL_TIME
FROM(
SELECT
sub.module, parsing_schema_name,
ROUND(sub.seconds_since_date/60,2) elapsed_time_delta_mins,
sub.execs_since_date,
sub.gets_since_date,
sub.snap_id,
ROUND(sub.seconds_since_date/DECODE(execs_since_date,0,1,
execs_since_date)/60,2) avg_exec_time,
sub.sql_id
FROM
( -- sub to sort before rownum
SELECT module, parsing_schema_name,
sql_id,
ROUND(SUM(elapsed_time_delta)/1000000) AS seconds_since_date,
SUM(executions_delta) AS execs_since_date,
SUM(buffer_gets_delta) AS gets_since_date,
snap_id
FROM
dba_hist_snapshot NATURAL JOIN dba_hist_sqlstat
WHERE
dba_hist_sqlstat.parsing_schema_name ='&USER_NAME'
AND begin_interval_time BETWEEN sysdate-1 AND sysdate
AND module NOT LIKE '%exp%' AND module NOT LIKE '%imp%'
AND module NOT LIKE '%TOAD%'
GROUP BY
module,sql_id,snap_id,parsing_schema_name
ORDER BY snap_id DESC
) sub
WHERE ROWNUM <=10
)T1 , DBA_HIST_SQLTEXT , dba_hist_snapshot
WHERE T1.sql_id=DBA_HIST_SQLTEXT.sql_id
AND T1.snap_id=dba_hist_snapshot.snap_id
--AND ( LOWER(DBA_HIST_SQLTEXT.sql_text) LIKE '%delete%' --OR
-- LOWER(DBA_HIST_SQLTEXT.sql_text) LIKE '%insert%' OR LOWER(DBA_HIST_SQLTEXT.sql_text) LIKE '%delete%')
AND sql_text NOT LIKE '%DBMS_STATS%'
AND sql_text NOT LIKE  '%parallel(t,2)%'
AND sql_text NOT LIKE '%maxbkt%'
AND sql_text NOT LIKE '%substrb%'
ORDER BY elapsed_time_delta_mins ;--T1.snap_id
