select snap_id, TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time, 
       sum(delta_value) enq_deadlocks from
    (select hs.snap_id, begin_interval_time, stat_name,
        value-(lag(value,1) over(partition by hs.startup_time, stat_name order by hss.snap_id)) delta_value
    from dba_hist_sysstat hss, dba_hist_snapshot hs
    where hs.begin_interval_time >= __START_DATE__
        and hs.end_interval_time <= __END_DATE__
        and hss.snap_id=hs.snap_id
        and hss.instance_number=hs.instance_number
        and hss.stat_name in ('enqueue deadlocks'))
group by snap_id, TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI'), stat_name
order by TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI')
