WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 7 ),
segment_lr AS (
    SELECT owner,
           a.obj#,
           a.dataobj#,
           object_name,
           SUM(PHYSICAL_READS_DELTPHYSICAL_READS_DELTA) AS total_logical_reads
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
    ORDER  BY SUM(PHYSICAL_READS_DELTA) DESC 
),
segment_lr_top10 AS (
    SELECT owner,
           obj#,
           dataobj#,
           object_name
    FROM segment_lr
    FETCH NEXT 10 ROWS ONLY
),
segment_data AS(
    SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24') AS time,
           owner||'.'||object_name AS src, 
           SUM(PHYSICAL_READS_DELTA) AS metrics
    FROM dba_hist_seg_stat NATURAL JOIN snaps NATURAL JOIN segment_lr_top10 
    GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24'),owner||'.'||object_name
)
SELECT  
    time,
    src,
    NVL(metrics,0) as metrics
FROM segment_data
