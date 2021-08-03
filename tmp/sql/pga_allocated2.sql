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
)
SELECT TO_CHAR(begin_interval_time, 'YYYYMMDDHH24') AS snap_time,
       category,
       CEIL(allocated_total) AS total_pga
FROM dba_hist_process_mem_summary HIST_PROCESS NATURAL JOIN snaps
ORDER BY TO_CHAR(begin_interval_time, 'YYYYMMDDHH24')
