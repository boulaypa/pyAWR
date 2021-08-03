WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
         WHERE  begin_interval_time >= __START_DATE__
         AND end_interval_time <= __END_DATE__
),
dba_hist_seg_stat_filtered AS 
(
    SELECT snaps.BEGIN_INTERVAL_TIME,dba_hist_seg_stat.*
        FROM dba_hist_seg_stat,
             snaps
        WHERE dba_hist_seg_stat.snap_id = snaps.snap_id AND
              dba_hist_seg_stat.dbid = snaps.dbid
),
segment_lr AS (
    SELECT o.owner,
           o.obj#,
           o.dataobj#,
           o.object_name,
           o.OBJECT_TYPE,
           SUM(__METRICS_NAME__) sm
    FROM   dba_hist_seg_stat_filtered h JOIN dba_hist_seg_stat_obj o
    ON    h.dbid=o.dbid 
    AND h.ts#=o.ts# 
    AND h.obj#=o.obj# 
    AND h.dataobj#=o.dataobj#
    WHERE o.owner NOT IN ('SYS','SYSTEM','SYSAUX')
    GROUP  BY o.owner,
              o.obj#,
              o.dataobj#,
              o.object_name,
              o.OBJECT_TYPE
    ORDER  BY SUM(__METRICS_NAME__) DESC 
),
segment_lr_top10 AS (
    SELECT owner,
           obj#,
           dataobj#,
           object_name,
           object_type,
           sm
    FROM segment_lr
    WHERE rownum <= 10
),
segment_data AS (
    SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24') AS time,
           owner||'.'||object_type||'.'||object_name AS src,
           SUM(__METRICS_NAME__) AS metrics
    FROM dba_hist_seg_stat_filtered NATURAL JOIN segment_lr_top10
    GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24'),owner,object_type,object_name
)
SELECT
    time,
    src,
    metrics
FROM segment_data
