dbname=COMUTX6

start="TO_DATE('201912130000','YYYYMMDDHH24MI')"
end="TO_DATE('201912142359','YYYYMMDDHH24MI')"
tag="13Dec2019"

$AWR_DEV_HOME/src/top_system_events.py $dbname "$start" "$end" top_system_events_${tag}.png 
