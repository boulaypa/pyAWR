select snap_id, TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time, stat_name,  sum(delta_value) value from 
    (select hs.snap_id, begin_interval_time, stat_name,
        value-(lag(value,1) over(partition by hs.startup_time, stat_name order by hss.snap_id)) delta_value
    from dba_hist_sysstat hss, dba_hist_snapshot hs
    where hss.snap_id=hs.snap_id 
        and hss.instance_number=hs.instance_number
        and hs.begin_interval_time >= __START_DATE__
        and hs.end_interval_time <= __END_DATE__
        and hss.stat_name = '__METRICS_NAME__') 
group by snap_id, TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI'), stat_name
order by TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI')
