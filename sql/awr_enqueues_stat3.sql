WITH snaps AS
(
    SELECT s.* /*+ materialize */
    FROM dba_hist_snapshot s , dba_hist_database_instance i
    WHERE s.begin_interval_time >= __START_DATE__
    AND s.end_interval_time <= __END_DATE__
    AND s.dbid = i.dbid
    AND s.instance_number = i.instance_number
    AND s.startup_time = i.startup_time
),
data as (
    SELECT /*+ materialize */
        begin_interval_time,
        CASE WHEN TOTAL_REQ# - LAG(TOTAL_REQ#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time) < 0 
            THEN TOTAL_REQ#
        ELSE TOTAL_REQ# - LAG(TOTAL_REQ#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time) 
        END TOTAL_REQ#,
        CASE WHEN TOTAL_WAIT# - LAG(TOTAL_WAIT#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time) < 0
            THEN TOTAL_WAIT#
        ELSE TOTAL_WAIT# - LAG(TOTAL_WAIT#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time)
        END TOTAL_WAIT#,
        CASE WHEN CUM_WAIT_TIME - LAG(CUM_WAIT_TIME) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time) < 0
            THEN CUM_WAIT_TIME
        ELSE CUM_WAIT_TIME - LAG(CUM_WAIT_TIME) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time)
        END CUM_WAIT_TIME,
        CASE WHEN FAILED_REQ# - LAG(FAILED_REQ#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time) < 0
            THEN FAILED_REQ#
        ELSE FAILED_REQ# - LAG(FAILED_REQ#) OVER (PARTITION BY EQ_TYPE,REQ_REASON ORDER BY begin_interval_time)
        END FAILED_REQ#
    FROM
        dba_hist_enqueue_stat ss , snaps s
    WHERE  REQ_REASON = 'row lock contention' AND EQ_TYPE='TX' 
    AND    ss.snap_id = s.snap_id
    AND    ss.dbid = s.dbid
    AND    ss.instance_number = s.instance_number
)
SELECT TO_CHAR(begin_interval_time,'YYYYMMDDHH24MI') AS snap_time,
       TOTAL_WAIT#,TOTAL_REQ#,CUM_WAIT_TIME,FAILED_REQ#
FROM data
