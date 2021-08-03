# @dashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate TO_DATE('2019120920','YYYYMMDDHH24SS') TO_DATE('201912100130','YYYYMMDDHH24')
 
dbname=NTOP00

start="TO_DATE('2019040820','YYYYMMDDHH24')"
end="TO_DATE('2019040901','YYYYMMDDHH24')"
tag=08Avr2019

start="TO_DATE('2019120920','YYYYMMDDHH24')"
end="TO_DATE('201912100130','YYYYMMDDHH24MI')"
tag=09Dec2019

grouping="sql_id,sql_plan_hash_value"
filter="session_type='FOREGROUND'"

$AWR_DEV_HOME/src/mydashtop.py $dbname "$grouping" "$filter" "$start" "$end" ASH_${m}_${tag}.png
