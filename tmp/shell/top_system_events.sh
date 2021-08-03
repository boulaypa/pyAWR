dbname=DOMUTX6

start="TO_DATE('2020021304','YYYYMMDDHH24')"
end="TO_DATE('2020021315','YYYYMMDDHH24')"
tag="13Mars2020"

$AWR_DEV_HOME/src/top_system_events.py $dbname "$start" "$end" top_system_events_${tag}.png 
