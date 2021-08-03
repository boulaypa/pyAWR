WITH snaps
     AS (SELECT *
         FROM   dba_hist_snapshot
                NATURAL join dba_hist_database_instance
         WHERE  db_name = '__DBNAME__'
         AND begin_interval_time > __START_DATE__
         AND end_interval_time < __END_DATE__
),
plan AS ( SELECT DISTINCT sql_id, plan_hash_value, timestamp
          FROM   dba_hist_sql_plan 
          NATURAL JOIN 
                 dba_hist_database_instance 
          WHERE  db_name = '__DBNAME__' and id=0
),
ash_data AS (
   SELECT *
   FROM dba_hist_active_sess_history
   NATURAL JOIN snaps
)
SELECT  sql_id, sql_plan_hash_value AS PLAN_HASH_VALUE, plan_date, rownum AS rank 
FROM (
SELECT a.*, b.timestamp AS PLAN_DATE FROM  (
SELECT * FROM (
    WITH bclass AS (SELECT class, ROWNUM r from v$waitstat)
    SELECT /*+ LEADING(a) USE_HASH(u) */
        10 * COUNT(*)                                                      "TotalSeconds"
      , ROUND(10 * COUNT(*) / ((CAST(__END_DATE__ AS DATE) - CAST(__START_DATE__ AS DATE)) * 86400), 1) AAS
      , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , __GROUPING_COLS__
--      , 10 * SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
--      , 10 * SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
--      , 10 * SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
--      , 10 * SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
--      , 10 * SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
--      , 10 * SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
--      , 10 * SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
--      , 10 * SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
--      , 10 * SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
--      , 10 * SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
--      , 10 * SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
--      , 10 * SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
--      , 10 * SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
           , NVL(event, session_state)||
                CASE 
                    WHEN event like 'enq%' AND session_state = 'WAITING'
                    THEN ' [mode='||BITAND(p1, POWER(2,14)-1)||']'
                    WHEN a.event IN (SELECT name FROM v$event_name WHERE parameter3 = 'class#') 
                    THEN ' ['||CASE WHEN a.p3 <= (SELECT MAX(r) FROM bclass) 
                               THEN (SELECT class FROM bclass WHERE r = a.p3)
                               ELSE (SELECT DECODE(MOD(BITAND(a.p3,TO_NUMBER('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') FROM dual)
                               END  ||']' 
                    ELSE null 
                END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
           , CASE WHEN a.session_type = 'BACKGROUND' OR REGEXP_LIKE(a.program, '.*\([PJ]\d+\)') THEN
                REGEXP_REPLACE(SUBSTR(a.program,INSTR(a.program,'(')), '\d', 'n')
             ELSE
                '('||REGEXP_REPLACE(REGEXP_REPLACE(a.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
             END || ' ' program2
           , CASE WHEN BITAND(time_model, POWER(2, 01)) = POWER(2, 01) THEN 'DBTIME '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 02)) = POWER(2, 02) THEN 'BACKGROUND '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 03)) = POWER(2, 03) THEN 'CONNECTION_MGMT '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 04)) = POWER(2, 04) THEN 'PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 05)) = POWER(2, 05) THEN 'FAILED_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 06)) = POWER(2, 06) THEN 'NOMEM_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 07)) = POWER(2, 07) THEN 'HARD_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 08)) = POWER(2, 08) THEN 'NO_SHARERS_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 09)) = POWER(2, 09) THEN 'BIND_MISMATCH_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 10)) = POWER(2, 10) THEN 'SQL_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 11)) = POWER(2, 11) THEN 'PLSQL_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 12)) = POWER(2, 12) THEN 'PLSQL_RPC '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 13)) = POWER(2, 13) THEN 'PLSQL_COMPILATION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 14)) = POWER(2, 14) THEN 'JAVA_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 15)) = POWER(2, 15) THEN 'BIND '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 16)) = POWER(2, 16) THEN 'CURSOR_CLOSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 17)) = POWER(2, 17) THEN 'SEQUENCE_LOAD '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 18)) = POWER(2, 18) THEN 'INMEMORY_QUERY '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 19)) = POWER(2, 19) THEN 'INMEMORY_POPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 20)) = POWER(2, 20) THEN 'INMEMORY_PREPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 21)) = POWER(2, 21) THEN 'INMEMORY_REPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 22)) = POWER(2, 22) THEN 'INMEMORY_TREPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 23)) = POWER(2, 23) THEN 'TABLESPACE_ENCRYPTION ' END time_model_name
        FROM ash_data a ) a
      , dba_hist_users u
      , (SELECT
             object_id,data_object_id,owner,object_name,subobject_name,object_type
           , owner||'.'||object_name obj
           , owner||'.'||object_name||' ['||object_type||']' objt
         FROM dba_objects) o
    WHERE
        a.user_id = u.user_id (+)
    AND a.current_obj# = o.object_id(+)
    AND __FILTERS__
    AND sample_time BETWEEN __START_DATE__ AND __END_DATE__
    GROUP BY
        __GROUPING_COLS__
    ORDER BY
        "TotalSeconds" DESC
       , __GROUPING_COLS__
)
WHERE ROWNUM <= __TOP__
) a , plan b
WHERE a.sql_id = b.sql_id AND a.sql_plan_hash_value = b.plan_hash_value
) WHERE rownum <= 10
