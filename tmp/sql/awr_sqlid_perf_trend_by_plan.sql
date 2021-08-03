WITH snaps AS
(
   SELECT
      *
   FROM
      dba_hist_snapshot NATURAL
      JOIN
         dba_hist_database_instance
   WHERE
      db_name = '__DBNAME__'
   AND begin_interval_time > SYSDATE - __DAYS__
)
select to_char(trunc(sysdate-__DAYS__+1)+trunc((cast(hs.begin_interval_time as date)-(trunc(sysdate-__DAYS__+1)))*24/(__INTERVAL__))*(__INTERVAL__)/24,'dd.mm.yyyy hh24:mi:ss') time,
plan_hash_value,
sum(hss.executions_delta) executions,
round(sum(hss.elapsed_time_delta)/1000000,3) elapsed_time_s,
round(sum(hss.cpu_time_delta)/1000000,3) cpu_time_s,
round(sum(hss.iowait_delta)/1000000,3) iowait_s,
round(sum(hss.clwait_delta)/1000000,3) clwait_s,
round(sum(hss.apwait_delta)/1000000,3) apwait_s,
round(sum(hss.ccwait_delta)/1000000,3) ccwait_s,
round(sum(hss.rows_processed_delta),3) rows_processed,
round(sum(hss.buffer_gets_delta),3) buffer_gets,
round(sum(hss.disk_reads_delta),3) disk_reads,
round(sum(hss.direct_writes_delta),3) direct_writes
from dba_hist_sqlstat hss, snaps hs
where hss.sql_id='__SQL_ID__'
and hss.snap_id=hs.snap_id
and hs.begin_interval_time>=trunc(sysdate)-__DAYS__+1
group by hss.instance_number, trunc(sysdate-__DAYS__+1)+trunc((cast(hs.begin_interval_time as date)-(trunc(sysdate-__DAYS__+1)))*24/(__INTERVAL__))*(__INTERVAL__)/24, plan_hash_value
having sum(hss.executions_delta)>0
order by hss.instance_number, trunc(sysdate-__DAYS__+1)+trunc((cast(hs.begin_interval_time as date)-(trunc(sysdate-__DAYS__+1)))*24/(__INTERVAL__))*(__INTERVAL__)/24, 4 desc
