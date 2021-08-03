WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 3 ),
segment_lr_snap AS (
    SELECT s.snap_id,
           s.begin_interval_time,
           owner,
           a.obj#,
           a.dataobj#,
           object_name,
           SUM(logical_reads_delta) AS total_logical_reads
    FROM   dba_hist_seg_stat a,
           dba_hist_seg_stat_obj b,
           snaps s
    WHERE  owner LIKE 'HAUP%'
           AND a.obj# = b.obj#
           AND a.dataobj# = b.dataobj#
           AND a.dbid = b.dbid
           AND a.dbid = s.dbid
           AND a.snap_id = s.snap_id
    GROUP  BY s.snap_id,
              s.begin_interval_time,
              owner,
              a.obj#,
              a.dataobj#,
              object_name
    ORDER  BY SUM(logical_reads_delta) DESC 
),
segment_lr AS (
    SELECT owner,
           obj#,
           dataobj#,
           object_name,
           SUM(total_logical_reads) AS total_logical_reads
    FROM   segment_lr_snap
    GROUP  BY owner,
              obj#,
              dataobj#,
              object_name
),
segment_lr_top10 AS (
    SELECT owner,
           obj#,
           dataobj#,
           object_name
    FROM segment_lr
    ORDER BY total_logical_reads DESC
    FETCH NEXT 10 ROWS ONLY
),
segment_data AS(
    SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24') AS time,
           b.owner||'.'||b.object_name AS src, 
           SUM(total_logical_reads) AS metrics
    FROM segment_lr_snap a,
         segment_lr_top10 b 
    WHERE a.obj#(+) = b.obj#
    AND   a.dataobj#(+) = b.dataobj#
    GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24'),b.owner||'.'||b.object_name
)
SELECT  
    time,
    src,
    metrics
FROM segment_data
