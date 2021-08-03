with hist as  (
  select
       sn.snap_id,
       sn.dbid,
       to_char(trunc(cast(begin_interval_time as date ))+ (ROUND ((cast(begin_interval_time as  date) - TRUNC (cast(begin_interval_time as date))) * 24) / 24), 'YYYYMMDDHH24MI') btime,
       h.event_name,
       h.wait_time_milli,
       h.wait_count
  from dba_hist_event_histogram  h,
       dba_hist_snapshot sn
  where
         h.instance_number = 1
     and sn.instance_number = 1
     and h.event_name like 'db file seq%'
     and sn.snap_id=h.snap_id
     and sn.dbid=h.dbid
   )
select  a.btime SNAP_TIME,
        a.wait_time_milli,
        sum(b.wait_count - a.wait_count) wait_count
from hist a,
     hist b
where a.dbid=b.dbid
  and a.snap_id=b.snap_id-1
  and a.wait_time_milli = b.wait_time_milli
group by a.btime, a.wait_time_milli
having  sum(b.wait_count - a.wait_count) > 0
