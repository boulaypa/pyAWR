WITH pga_data as
(
  SELECT /*+ MATERIALIZED */
      sample_time,    
      snap_id,    
      username,
      sql_id,
      session_id,
      session_serial#,
      ash.pga_allocated/1024/1024 AS pga_mb
  FROM
      dba_hist_active_sess_history ash,
      dba_users u
  WHERE ash.user_id = u.user_id
  AND username NOT IN ('SYS','SYSTEM')
  AND sample_time >= __START_DATE__
  AND sample_time <= __END_DATE__
),
top as (
   SELECT * FROM 
   (
       SELECT username,sql_id,snap_id,session_id,session_serial#,
              SUM(pga_mb)
       FROM pga_data
       GROUP BY username,sql_id,snap_id,session_id,session_serial#
       ORDER BY SUM(pga_mb) DESC
   )
   WHERE rownum <= __TOP__
)
SELECT * from top
