WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = '__DBNAME__'
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
),
data as (
    select TO_DATE(TO_CHAR(begin_interval_time,'__INTERVAL__'),'__INTERVAL__') as begin_interval_time,
        EVENT_NAME,
        TOTAL_WAITS-(lag(TOTAL_WAITS,1) over(partition by STARTUP_TIME, EVENT_NAME order by snap_id)) delta_total_waits,
        TIME_WAITED_MICRO-(lag(TIME_WAITED_MICRO,1) over(partition by STARTUP_TIME, EVENT_NAME order by snap_id)) delta_time_waited
    from DBA_HIST_SYSTEM_EVENT NATURAL JOIN  snaps
    where EVENT_NAME like '__EVENT_NAME__'
)
select begin_interval_time, event_name, sum(delta_total_waits) total_waits, round(sum(delta_time_waited/1000000),3) total_time_s,
round(sum(delta_time_waited)/decode(sum(delta_total_waits),0,null,sum(delta_total_waits))/1000,3) avg_time_ms from
data
group by begin_interval_time, event_name
order by 2, begin_interval_time
