SELECT s.snap_id, TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time,
       (cast(s.end_interval_time as date) - cast(s.begin_interval_time as date))*24*3600 ela
FROM DBA_HIST_SNAPSHOT S
WHERE s.end_interval_time >= __START_DATE__
and s.end_interval_time <= __END_DATE__
