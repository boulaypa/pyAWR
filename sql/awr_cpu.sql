 SELECT  snaps.tm,
         snaps.dur,
         snaps.instances,
         osstat.num_cpus                                                                                                                                                                                           cpus,
         osstat.num_cpus * dur * 60                                                                                                                                                                                cap,
         ((timemodel.dbt   - Lag(timemodel.dbt,1) OVER (ORDER BY snaps.id)))/1000000                                                                                                                               dbt,
         ((timemodel.dbc   - Lag(timemodel.dbc,1) OVER (ORDER BY snaps.id)))/1000000                                                                                                                               dbc,
         ((timemodel.bgc   - Lag(timemodel.bgc,1) OVER (ORDER BY snaps.id)))/1000000                                                                                                                               bgc,
         ((timemodel.rmanc - Lag(timemodel.rmanc,1) OVER (ORDER BY snaps.id)))/1000000                                                                                                                             rmanc,
         (((timemodel.dbt - Lag(timemodel.dbt,1) OVER (ORDER BY snaps.id)))/1000000)/dur/60                                                                                                                        aas ,
         (((timemodel.dbc - Lag(timemodel.dbc,1) OVER (ORDER BY snaps.id)))/1000000) + (((timemodel.bgc - Lag(timemodel.bgc,1) OVER (ORDER BY snaps.id)))/1000000)                                                 totora ,
         osstat.LOAD                                                                                                                                                                                               LOAD ,
         ((osstat.busy_time - Lag(osstat.busy_time,1) OVER (ORDER BY snaps.id)))/100                                                                                                                               totos,
         Round(100*(((((timemodel.dbc - Lag(timemodel.dbc,1) OVER (ORDER BY snaps.id)))/1000000) + (((timemodel.bgc - Lag(timemodel.bgc,1) OVER (ORDER BY snaps.id)))/1000000)) / (osstat.num_cpus * 60 * dur)),2) oracpupct,
         Round(100*((((timemodel.rmanc - Lag(timemodel.rmanc,1) OVER (ORDER BY snaps.id)))/1000000) / (osstat.num_cpus * 60 * dur)),2)                                                                             rmancpupct,
         Round(100*((((osstat.busy_time - Lag(osstat.busy_time,1) OVER (ORDER BY snaps.id)))/100) / (osstat.num_cpus * 60 * dur)),3)                                                                               oscpupct,
         Round(100*((((osstat.user_time - Lag(osstat.user_time,1) OVER (ORDER BY snaps.id)))/100) / (osstat.num_cpus * 60 * dur)),3)                                                                               usrcpupct,
         Round(100*((((osstat.sys_time - Lag(osstat.sys_time,1) OVER (ORDER BY snaps.id)))/100) / (osstat.num_cpus * 60 * dur)),3)                                                                                 syscpupct,
         Round(100*((((osstat.iowait_time - Lag(osstat.iowait_time,1) OVER (ORDER BY snaps.id)))/100) / (osstat.num_cpus * 60 * dur)),3)                                                                           iowaitcpupct,
         sysstat.logons_curr ,
         ((sysstat.logons_cum - Lag (sysstat.logons_cum,1) OVER (ORDER BY snaps.id)))/dur/60 logons_cum,
         ((sysstat.execs      - Lag (sysstat.execs,1) OVER (ORDER BY snaps.id)))/dur/60      execs
FROM     (
                         /* DBA_HIST_SNAPSHOT */
                         SELECT DISTINCT id,
                                         dbid,
                                         tm,
                                         instances,
                                         Max(dur) OVER (partition BY id) dur
                         FROM            (
                                                         SELECT DISTINCT s.snap_id id,
                                                                         s.dbid,
                                                                         To_char(s.end_interval_time,'YYYYMMDDHH24MISS')                                                                tm,
                                                                         Count(s.instance_number) OVER (partition BY snap_id)                                                            instances,
                                                                         1440*((Cast(s.end_interval_time AS DATE) - Lag(Cast(s.end_interval_time AS DATE),1) OVER (ORDER BY s.snap_id))) dur
                                                         FROM            dba_hist_snapshot s,
                                                                         v$database d
                                                         WHERE           s.begin_interval_time > __START_DATE__
                                                         AND             s.end_interval_time < __END_DATE__
                                                         AND             s.dbid=d.dbid) ) snaps,
         (
                /* Data from DBA_HIST_OSSTAT */
                SELECT *
                FROM   (
                              SELECT snap_id,
                                     dbid,
                                     stat_name,
                                     value
                              FROM   dba_hist_osstat ) PIVOT (sum(value) FOR (stat_name) IN ('NUM_CPUS'    AS num_cpus,
                                                                                             'BUSY_TIME'   AS busy_time,
                                                                                             'LOAD'        AS LOAD,
                                                                                             'USER_TIME'   AS user_time,
                                                                                             'SYS_TIME'    AS sys_time,
                                                                                             'IOWAIT_TIME' AS iowait_time)) ) osstat,
         (
                /* DBA_HIST_TIME_MODEL */
                SELECT *
                FROM   (
                              SELECT snap_id,
                                     dbid,
                                     stat_name,
                                     value
                              FROM   dba_hist_sys_time_model ) PIVOT (sum(value) FOR (stat_name) IN ('DB time'                        AS dbt,
                                                                                                     'DB CPU'                         AS dbc,
                                                                                                     'background cpu time'            AS bgc,
                                                                                                     'RMAN cpu time (backup/restore)' AS rmanc)) ) timemodel,
         (
                /* DBA_HIST_SYSSTAT */
                SELECT *
                FROM   (
                              SELECT snap_id,
                                     dbid,
                                     stat_name,
                                     value
                              FROM   dba_hist_sysstat ) PIVOT (sum(value) FOR (stat_name) IN ('logons current'    AS logons_curr,
                                                                                              'logons cumulative' AS logons_cum,
                                                                                              'execute count'     AS execs)) ) sysstat
WHERE    dur > 0
AND      snaps.id=osstat.snap_id
AND      snaps.dbid=osstat.dbid
AND      snaps.id=timemodel.snap_id
AND      snaps.dbid=timemodel.dbid
AND      snaps.id=sysstat.snap_id
AND      snaps.dbid=sysstat.dbid
ORDER BY id ASC 
