SELECT
   TO_CHAR(sample_time, 'YYYYMMDDHH24') SNAP_TIME,
   round(decode(session_state, 'WAITING', count(*), 0) / 360, 2) AAS_WAIT,
   round(decode(session_state, 'ONCPU', count(*), 0) / 360, 2) AAS_CPU,
   round(count(*) / 360, 2) AAS
FROM dba_hist_active_sess_history
WHERE sample_time >= __START_DATE__
AND sample_time <= __END_DATE__
GROUP BY to_char(sample_time, 'YYYYMMDDHH24'),
   session_state
ORDER BY TO_CHAR(sample_time, 'YYYYMMDDHH24')
