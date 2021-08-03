WITH snaps AS 
(
   SELECT
      * 
   FROM
      dba_hist_snapshot NATURAL 
      join
         dba_hist_database_instance 
   WHERE
      db_name = 'NTOP00' 
      and begin_interval_time > SYSDATE - 30 
)
select
   sn.END_INTERVAL_TIME,
   (
      after.total_waits - before.total_waits
   )
   "number of waits",
   (
      after.time_waited_micro - before.time_waited_micro
   )
    / (after.total_waits - before.total_waits) "ave microseconds",
   before.event_name "wait name" 
from
   DBA_HIST_SYSTEM_EVENT before,
   DBA_HIST_SYSTEM_EVENT after,
   snaps sn 
where
   before.event_name = '' 
   and after.event_name = before.event_name 
   and after.snap_id = before.snap_id + 1 
   and after.instance_number = 1 
   and before.instance_number = after.instance_number 
   and after.snap_id = sn.snap_id 
   and after.instance_number = sn.instance_number 
order by
   after.snap_id;
