WITH snaps AS (
  SELECT
    *
  FROM
    dba_hist_snapshot NATURAL
    JOIN dba_hist_database_instance
  WHERE
    db_name = 'NTOP00'
    AND begin_interval_time > SYSDATE - 30
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
            end_interval_time,
            event_name,
            wait_class,
            CASE
              WHEN begin_interval_time = startup_time THEN total_waits
              ELSE total_waits - Lag(total_waits, 1) OVER(
                PARTITION BY wait_class,
                event_name,
                dbid,
                instance_number,
                startup_time
                ORDER BY
                  snap_id
              )
            END total_waits,
            CASE
              WHEN begin_interval_time = startup_time THEN time_waited_micro
              ELSE time_waited_micro - Lag(time_waited_micro, 1) OVER(
                PARTITION BY wait_class,
                event_name,
                dbid,
                instance_number,
                startup_time
                ORDER BY
                  snap_id
              )
            END time_waited_micro
          FROM
            DBA_HIST_SYSTEM_EVENT,
            NATURAL
            JOIN snaps,
            NATURAL
            JOIN DBA_HIST_EVENT_NAME
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
  end_interval_time,
  wait_class,
  event_name,
  SUM(NVL(total_waits, 0)),
  SUM(NVL(time_waited_micro, 0)),
  MAX(ratio)
FROM
  (
    SELECT
      end_interval_time,
      snap_id dbid,
      instance_number,
      wait_class,
      event_name,
      CASE
        WHEN begin_interval_time = startup_time THEN total_waits
        ELSE total_waits - Lag(total_waits, 1) OVER(
          PARTITION BY wait_class,
          event_name,
          dbid,
          instance_number,
          startup_time
          ORDER BY
            snap_id
        )
      END total_waits,
      CASE
        WHEN begin_interval_time = startup_time THEN time_waited_micro
        ELSE time_waited_micro - Lag(time_waited_micro, 1) OVER(
          PARTITION BY wait_class,
          event_name,
          dbid,
          instance_number,
          startup_time
          ORDER BY
            snap_id
        )
      END time_waited_micro,
      ratio
    FROM
      DBA_HIST_SYSTEM_EVENT,
      NATURAL
      JOIN DBA_HIST_EVENT_NAME,
      NATURAL
      JOIN snaps,
      NATURAL
      JOIN sub_top
  )
GROUP BY
  end_interval_time,
  wait_class,
  event_name
ORDER BY
  MAX(ratio) DESC;
