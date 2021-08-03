WITH snaps AS (
  SELECT
    *
  FROM
    dba_hist_snapshot 
  WHERE begin_interval_time >= __START_DATE__
  AND begin_interval_time <= __END_DATE__
),
sub_top AS (
  SELECT
    *
  FROM
    (
      SELECT
        wait_class,
        event_name,
        SUM(total_waits),
        SUM(time_waited_micro),
        (
          (Ratio_to_report(SUM(time_waited_micro)) OVER()) * 100
        ) ratio
      FROM
        (
          SELECT
            s.begin_interval_time,
            se.event_name,
            se.wait_class,
            CASE
              WHEN s.begin_interval_time = s.startup_time THEN e.total_waits
              ELSE e.total_waits - Lag(e.total_waits, 1) OVER(
                PARTITION BY se.wait_class,
                se.event_name,
                s.dbid,
                s.instance_number,
                s.startup_time
                ORDER BY
                  s.snap_id
              )
            END total_waits,
            CASE
              WHEN s.begin_interval_time = s.startup_time THEN e.time_waited_micro
              ELSE e.time_waited_micro - Lag(e.time_waited_micro, 1) OVER(
                PARTITION BY se.wait_class,
                se.event_name,
                s.dbid,
                s.instance_number,
                s.startup_time
                ORDER BY
                  s.snap_id
              )
            END time_waited_micro
          FROM
            DBA_HIST_SYSTEM_EVENT e
            , snaps s
            , DBA_HIST_EVENT_NAME se
          WHERE e.event_id = se.event_id
          AND e.dbid = se.dbid
          AND e.snap_id = s.snap_id
        )
      WHERE
        total_waits >= 0
        AND wait_class != 'Idle'
      GROUP BY
        wait_class,
        event_name
      ORDER BY
        SUM(total_waits) DESC
    )
  WHERE
    ROWNUM < 10
)
SELECT
  begin_interval_time AS time,
  wait_class||'.'||event_name AS src,
  SUM(NVL(total_waits, 0)) AS total_waits,
  SUM(NVL(time_waited_micro, 0)) time_waited_micro,
  MAX(ratio) 
FROM
  (
    SELECT
      s.begin_interval_time,
      s.snap_id dbid,
      s.instance_number,
      en.wait_class,
      se.event_name,
      CASE
        WHEN s.begin_interval_time = s.startup_time THEN se.total_waits
        ELSE se.total_waits - Lag(se.total_waits, 1) OVER(
          PARTITION BY en.wait_class,
          en.event_name,
          s.dbid,
          s.instance_number,
          s.startup_time
          ORDER BY
            s.snap_id
        )
      END total_waits,
      CASE
        WHEN s.begin_interval_time = s.startup_time THEN se.time_waited_micro
        ELSE se.time_waited_micro - Lag(se.time_waited_micro, 1) OVER(
          PARTITION BY en.wait_class,
          en.event_name,
          s.dbid,
          s.instance_number,
          s.startup_time
          ORDER BY
            s.snap_id
        )
      END time_waited_micro,
      ratio
    FROM
      DBA_HIST_SYSTEM_EVENT se,
      DBA_HIST_EVENT_NAME en, 
      snaps s, sub_top t
    WHERE se.event_id = en.event_id
          AND se.dbid = en.dbid
          AND se.snap_id = s.snap_id
          AND se.event_name = t.event_name
  )
GROUP BY
  begin_interval_time,
  wait_class ||'.'||event_name,
  event_name
ORDER BY
  begin_interval_time
