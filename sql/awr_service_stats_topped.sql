WITH data AS (
    select TO_CHAR(snap_time,'YYYYMMDDHH24MISS') SNAP_TIME,
        service_name,
        stat_name,
        value,
        DeltaT_sec,
        Rate_value
    from ( 
        select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  
        ss.service_name,
        ss.stat_name,
        ss.value,
        ss.value - lag(ss.value) over (partition by ss.dbid,ss.instance_number,ss.stat_id,ss.service_name order by sn.snap_id nulls first) Delta_value,
        extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.stat_id,ss.service_name order by sn.snap_id nulls first) )*3600 
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time) DeltaT_sec,
        round((ss.value - lag(ss.value) over (partition by ss.dbid,ss.instance_number,ss.stat_id,ss.service_name order by sn.snap_id nulls first)) /
              (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.stat_id,ss.service_name order by sn.snap_id nulls first) )*3600 
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_value
from dba_hist_service_stat ss,
     dba_hist_snapshot sn
where
    sn.snap_id = ss.snap_id
and sn.dbid = ss.dbid
and sn.instance_number = ss.instance_number
and sn.begin_interval_time >= __START_DATE__
and sn.end_interval_time <= __END_DATE__
    )
), top AS (
    SELECT * FROM 
    (
        SELECT service_name,
               SUM(value)
        FROM data
        GROUP BY service_name
        ORDER BY 2 DESC
    ) 
    WHERE ROWNUM <= 10
)
SELECT * FROM data, top
WHERE data.service_name = top.service_name
