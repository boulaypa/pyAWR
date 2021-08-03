WITH snaps AS
(
   SELECT
      *
   FROM
      dba_hist_snapshot 
   NATURAL JOIN
      dba_hist_database_instance
   WHERE
      db_name = '__DBNAME__'
   AND begin_interval_time > __START_DATE__
   AND begin_interval_time < __END_DATE__
),
obj_info AS (
    SELECT * 
    FROM  dba_hist_seg_stat_obj
    WHERE owner = '__OWNER__'
    AND object_name = '__OBJECT_NAME__'
),
ash_data AS (
   SELECT * 
   FROM dba_hist_active_sess_history 
   NATURAL JOIN 
       snaps 
),
ash_data_with_obj AS (
   SELECT ash_data.*
   FROM ash_data , obj_info
   WHERE ash_data.current_obj# =  obj_info.obj#
),
ash_sess_info AS
(
   SELECT
        ash.*,
        decode(session_state,'ON CPU',1,0) cpu,
        decode(session_state,'WAITING',1,0) -
        decode(session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0) wait ,
        decode(session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0) io ,
        decode(session_state,'ON CPU',1,1) total
   FROM ash_data_with_obj ash
   WHERE  SQL_ID is not NULL
)
SELECT TO_CHAR(SAMPLE_TIME,'YYYYMMDDHH24MI')||'00' AS snap_time,
       COUNT(1) AS count
FROM (
   SELECT SAMPLE_TIME,SESSION_ID,SESSION_SERIAL#
   FROM ash_sess_info 
   WHERE wait > 0 
)
GROUP BY TO_CHAR(SAMPLE_TIME,'YYYYMMDDHH24MI')||'00'
ORDER BY TO_CHAR(SAMPLE_TIME,'YYYYMMDDHH24MI')||'00'
