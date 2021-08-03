SELECT TO_CHAR(SN.BEGIN_INTERVAL_TIME,'YYYYMMDD_HH24MI') SNAP_TIME,
       sga.allo sga,
       pga.allo pga,
       (sga.allo + pga.allo) tot
FROM
  (SELECT snap_id,
          INSTANCE_NUMBER,
          ROUND (SUM (bytes) / 1024 / 1024 / 1024, 3) allo
   FROM DBA_HIST_SGASTAT
   GROUP BY snap_id,
            INSTANCE_NUMBER) sga,

  (SELECT snap_id,
          INSTANCE_NUMBER,
          ROUND (SUM (VALUE) / 1024 / 1024 / 1024, 3) allo
   FROM DBA_HIST_PGASTAT
   WHERE name = 'total PGA allocated'
   GROUP BY snap_id,
            INSTANCE_NUMBER) pga,
     dba_hist_snapshot sn
WHERE sn.snap_id = sga.snap_id
  AND sn.INSTANCE_NUMBER = sga.INSTANCE_NUMBER
  AND sn.snap_id = pga.snap_id
  AND sn.INSTANCE_NUMBER = pga.INSTANCE_NUMBER
  AND sn.begin_interval_time > __START_DATE__
  AND sn.end_interval_time < __END_DATE__
ORDER BY TO_CHAR(SN.BEGIN_INTERVAL_TIME,'YYYYMMDD_HH24MI') ASC
