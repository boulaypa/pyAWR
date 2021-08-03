WITH sub1 AS (
SELECT sn.snap_id,
       sn.snap_time,
       sn.startup_time,
       EXTRACT(HOUR from CAST(sn.snap_time AS TIMESTAMP)) snap_hour
FROM  stats$snapshot sn
WHERE sn.SNAP_TIME >= __START_DATE__
AND   sn.SNAP_TIME <= __END_DATE__
), sub2 AS (
SELECT snap_id,
       snap_time,
       startup_time,
       snap_hour,
       LAG(snap_hour) OVER ( ORDER BY snap_id) snap_hour_lag
from sub1 ), sub3 AS (
select snap_id, snap_time , startup_time, snap_hour - snap_hour_lag diff
from sub2 ), sub4 AS (
select snap_id,snap_time,startup_time from sub3 where diff=1
),
snaps AS(
       SELECT sn.snap_id
          , sn.snap_time
          , sn.startup_time
          , ( sn.snap_time - ( LAG( sn.snap_time, 1 ) OVER( ORDER BY sn.snap_id ) ) ) *24*3600 AS time_diff
       FROM  sub4 sn
)
-- These are the columns SQL Developer needs for a graph:
-- X-axis, series name, Y-axis

SELECT TO_CHAR( snap_time, 'YYYYMMDDHH24' ) time
     , stat_name
     , value
     , value_diff
     , time_diff
     , value_diff  * blksz / 1024 / 1024
       / DECODE( time_diff, 0, NULL, time_diff ) "MB/s"
  FROM
     (
     SELECT sn.snap_id
          ,ss.value
          , ss.value - ( LAG( ss.value ) OVER( ORDER BY sn.STARTUP_TIME,sn.snap_id, ss.name ) ) AS value_diff
          , sn.time_diff
          , sn.snap_time
          , ss.name stat_name
          , ( select to_number(value) from v$parameter where name='db_block_size' ) blksz
       FROM stats$sysstat ss
          , snaps sn
      WHERE ss.name = '__METRICS_NAME__'
        AND sn.snap_id = ss.snap_id
     )
ORDER BY snap_time, stat_name DESC
