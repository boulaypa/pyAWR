SET SERVEROUTPUT ON LONG 99999 LINES 2000 PAGES 2000 FEEDBACK OFF HEAD OFF PAGESIZE 0 LINESIZE 2000 LONG 99999
DECLARE
 
B_SQLFULLTEXT GV$SQLAREA.SQL_FULLTEXT%TYPE;
 
I_SQL_ID                  dba_hist_sqlstat.SQL_ID%TYPE;
I_SQLFULLTEXT              dba_hist_sqltext.sql_text%TYPE;
I_parsing_schema_name    dba_hist_sqlstat.parsing_schema_name%TYPE;
I_TOTALELAPSEDTIME         VARCHAR2(4000);
I_NUmberofExecs             VARCHAR2(4000);
I_RowsProcessed              VARCHAR2(4000);
I_avg_query_time         VARCHAR2(4000);
V_COUNT NUMBER :=0;
 
CURSOR ELAPSED_QUERY_DETAILS
IS
select sub.sql_id,
       txt.sql_text,
       parsing_schema_name,
       sub.seconds_since_date as TOTALELAPSEDTIME,
       sub.execs_since_date as NUmberofExecs,
       sub.gets_rows_date as RowsProcessed,
       round(sub.seconds_since_date / (sub.execs_since_date + 0.01), 3) avg_query_time
  from ( -- sub to sort before top N filter
        select sql_id,
                g.parsing_schema_name,
                round(sum(ELAPSED_TIME_delta) / 1000000) as seconds_since_date,
                sum(executions_delta) as execs_since_date,
                sum(buffer_gets_delta) as gets_since_date,
                sum(ROWS_PROCESSED_delta) as gets_rows_date,
                row_number() over (order by round(sum(elapsed_time_delta) / 1000000) desc) r
          from dba_hist_snapshot natural
          join dba_hist_sqlstat g
         where trunc(begin_interval_time) = trunc(sysdate-1)
         group by sql_id, g.parsing_schema_name) sub
  join dba_hist_sqltext txt on sub.sql_id = txt.sql_id
 where r <= 25
 order by avg_query_time desc;
 
BEGIN
        BEGIN
        DBMS_OUTPUT.PUT_LINE(' Started to Print sql ids which are newly created ');
        OPEN ELAPSED_QUERY_DETAILS;
        LOOP
        FETCH ELAPSED_QUERY_DETAILS INTO I_SQL_ID,I_SQLFULLTEXT,I_parsing_schema_name,I_TOTALELAPSEDTIME,I_NUmberofExecs,I_RowsProcessed,I_avg_query_time;
        EXIT WHEN ELAPSED_QUERY_DETAILS%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('                                               ');
                    V_COUNT := 0;
                    SELECT COUNT(*) INTO V_COUNT FROM dbmon.TOP_ELAPSEDTIME_SQLIDS WHERE SQL_ID = I_SQL_ID;
                    IF V_COUNT = 0
                    THEN
                                        DBMS_OUTPUT.PUT_LINE('New ELAPSED sql id details details --> I_SQL_ID - '||I_SQL_ID
                    ||' ::I_parsing_schema_name - '||I_parsing_schema_name||' ::I_TOTALELAPSEDTIME - '||I_TOTALELAPSEDTIME||':: I_NUmberofExecs - '||I_NUmberofExecs
                    ||' ::I_RowsProcessed - '||I_RowsProcessed ||' ::I_avg_query_time - '||I_avg_query_time);
                    END IF;
        DBMS_OUTPUT.PUT(CHR(10));
        END LOOP;
        CLOSE ELAPSED_QUERY_DETAILS;
        DBMS_OUTPUT.PUT_LINE(' Ended to Print sql ids which are newly created ');
       EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('                                          ');
        END;
 
      BEGIN
        BEGIN
        DELETE FROM dbmon.TOP_ELAPSEDTIME_SQLIDS;
        COMMIT;
         EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('                                          ');
        END;
        DBMS_OUTPUT.PUT_LINE(' Started Executing to print the long running elapsed queries ');
        OPEN ELAPSED_QUERY_DETAILS;
        LOOP
        FETCH ELAPSED_QUERY_DETAILS INTO I_SQL_ID,I_SQLFULLTEXT,I_parsing_schema_name,I_TOTALELAPSEDTIME,I_NUmberofExecs,I_RowsProcessed,I_avg_query_time;
        EXIT WHEN ELAPSED_QUERY_DETAILS%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('                                               ');
                    DBMS_OUTPUT.PUT_LINE(' Insert long running elapsed query  details into  to Print sql ids which are newly created ');
                    DBMS_OUTPUT.PUT_LINE('elapsed query  details  --> I_SQL_ID - '||I_SQL_ID
                    ||' ::I_parsing_schema_name - '||I_parsing_schema_name||' ::I_TOTALELAPSEDTIME - '||I_TOTALELAPSEDTIME||':: I_NUmberofExecs - '||I_NUmberofExecs
                    ||' ::I_RowsProcessed - '||I_RowsProcessed ||' ::I_avg_query_time - '||I_avg_query_time);
 
                INSERT INTO dbmon.TOP_ELAPSEDTIME_SQLIDS VALUES (I_SQL_ID,SYSDATE);
                                INSERT INTO dbmon.ALL_ELAPSEDTIME_SQLIDS VALUES (I_SQL_ID,SYSDATE);
                    COMMIT;
                I_parsing_schema_name    := NULL;
                I_TOTALELAPSEDTIME         := NULL;
                I_NUmberofExecs             := NULL;
                I_RowsProcessed              := NULL;
                I_avg_query_time        := NULL;
 
        DBMS_OUTPUT.PUT(CHR(10));
        DBMS_OUTPUT.PUT(CHR(10));
        END LOOP;
        CLOSE ELAPSED_QUERY_DETAILS;
        DBMS_OUTPUT.PUT_LINE(' Started Executing to print the long running elapsed queries ');
      EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('                                          ');
      END;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.put_line('Error : '|| DBMS_UTILITY.format_error_stack() || CHR(10) || DBMS_UTILITY.format_error_backtrace());
END;
/
