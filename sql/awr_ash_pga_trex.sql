WITH pga_data as
(
  SELECT /*+ MATERIALIZED */
      TO_CHAR(sample_time,'YYYYMMDD HH24MI'),    
      sql_id,
      session_id,
      session_serial#,
      ash.pga_allocated/1024/1024 AS pga_mb
  FROM
      dba_hist_active_sess_history ash,
      dba_users u
  WHERE ash.user_id = u.user_id
  AND username IN ('TREX_READ')
  AND sample_time >= __START_DATE__
  AND sample_time <= __END_DATE__
)
SELECT * from pga_data
ORDER  BY 1
