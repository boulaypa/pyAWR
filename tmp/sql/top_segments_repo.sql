WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' 
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
),
segment_lr AS (
    SELECT owner,
           a.obj#,
           a.dataobj#,
           object_name,
           SUM(__METRICS_NAME__) AS total_logical_reads
    FROM   dba_hist_seg_stat a,
           dba_hist_seg_stat_obj b,
           snaps s
    WHERE  owner LIKE 'HAUP%'
           AND a.obj# = b.obj#
           AND a.dataobj# = b.dataobj#
           AND a.dbid = b.dbid
           AND a.dbid = s.dbid
           AND a.snap_id = s.snap_id
    GROUP  BY owner,
              a.obj#,
              a.dataobj#,
              object_name
    ORDER  BY SUM(__METRICS_NAME__) DESC 
),
segment_lr_top10 AS (
    SELECT owner,
           obj#,
           dataobj#,
           object_name
    FROM segment_lr
    FETCH NEXT 10  ROWS ONLY
),
segment_data AS(
    SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24') AS time,
           object_name AS src, 
           SUM(__METRICS_NAME__) AS metrics
    FROM dba_hist_seg_stat NATURAL JOIN snaps NATURAL JOIN segment_lr_top10 
    GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24'),object_name
)
SELECT  
    time,
    src,
    metrics 
FROM segment_data
