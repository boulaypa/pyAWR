select TO_CHAR(PLAN_HASH_VALUE,'9999999999'), TO_CHAR(TIMESTAMP,'YYYYMONDD'), MAX(COST), MAX(CPU_COST), MAX(IO_COST), MAX(TEMP_SPACE)
from dba_hist_sql_plan
where sql_id='__SQL_ID__' 
group by TO_CHAR(PLAN_HASH_VALUE,'9999999999'), TO_CHAR(TIMESTAMP,'YYYYMONDD')
;
