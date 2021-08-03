select a.plan_hash_value, to_char(begin_interval_time,'dd-mon-yy hh24:mi') btime, 
       abs(extract(minute from (end_interval_time-begin_interval_time)) + extract(hour from (end_interval_time-begin_interval_time))*60 + extract(day from (end_interval_time-begin_interval_time))*24*60) minutes,
       executions_delta executions, round(ELAPSED_TIME_delta/1000000/greatest(executions_delta,1),4) "avg_duration_(sec)" 
from dba_hist_SQLSTAT a, dba_hist_snapshot b
where sql_id='4z2wwkah8702f' and a.snap_id=b.snap_id
and a.instance_number=b.instance_number
order by b.snap_id asc
