WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = 'NTOP00' and begin_interval_time > SYSDATE - 10 )
SELECT owner                    AS SCHEMA,
       object_name              AS table_name,
       SUM(logical_reads_delta) AS total_logical_reads
FROM   dba_hist_seg_stat a,
       dba_hist_seg_stat_obj b,
       snaps s
WHERE  owner LIKE 'HAUP%'
       AND a.obj# = b.obj#
       AND a.dataobj# = b.dataobj#
       AND a.dbid = s.dbid
       AND a.snap_id = s.snap_id
GROUP  BY owner,
          object_name
ORDER  BY SUM(logical_reads_delta) DESC
