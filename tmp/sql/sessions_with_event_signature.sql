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
ash_data AS (
   SELECT * 
   FROM dba_hist_active_sess_history 
   NATURAL JOIN snaps 
),
ash_sess_info AS
(
   SELECT
        ash.*
   FROM ash_data ash
   WHERE  SQL_ID is not NULL
   AND event = '__EVENT_NAME__'
)
SELECT TO_CHAR(SAMPLE_TIME,'YYYYMMDDHH24') AS snap_time,
       COUNT(1) AS count
FROM ash_sess_info
GROUP BY TO_CHAR(SAMPLE_TIME,'YYYYMMDDHH24')
ORDER BY 2 DESC
