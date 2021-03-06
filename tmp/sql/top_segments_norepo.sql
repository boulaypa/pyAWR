WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
         WHERE  begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
),
dba_hist_seg_stat_filtered AS 
(
	SELECT *
        FROM dba_hist_seg_stat NATURAL JOIN snaps
	 
),
segment_lr AS (
    SELECT o.owner,
           o.obj#,
           o.dataobj#,
           o.object_name,
           SUM(__METRICS_NAME__) AS total_logical_reads
    FROM   dba_hist_seg_stat_filtered h JOIN dba_hist_seg_stat_obj o
    ON    h.dbid=o.dbid 
    AND h.ts#=o.ts# 
    AND h.obj#=o.obj# 
    AND h.dataobj#=o.dataobj#
    WHERE o.owner NOT IN ('SYS','SYSTEM','SYSAUX')
    GROUP  BY o.owner,
              o.obj#,
              o.dataobj#,
              o.object_name
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
    FROM dba_hist_seg_stat_filtered NATURAL JOIN segment_lr_top10 
    GROUP BY TO_CHAR(begin_interval_time,'YYYYMMDDHH24'),object_name
)
SELECT  
    time,
    src,
    metrics 
FROM segment_data
