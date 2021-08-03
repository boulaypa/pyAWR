SELECT * FROM (
    SELECT TO_CHAR(s.begin_interval_time, 'YYYYMMDDHH24MISS') "SNAP_TIME",
           ROUND(SUM(DECODE(v.stat_name,'OS Swaps', value))) "Swap Util"
    FROM dba_hist_SYSSTAT v, 
         dba_hist_snapshot s
    WHERE s.snap_id=v.snap_id 
    AND v.stat_name in ('OS Swaps')
    AND s.begin_interval_time >= __START_DATE__
    AND s.end_interval_time <= __END_DATE__
    GROUP BY TO_CHAR(s.begin_interval_time, 'YYYYMMDDHH24MISS')
    ORDER BY TO_CHAR(s.begin_interval_time, 'YYYYMMDDHH24MISS')
)
