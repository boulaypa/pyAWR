dbname=NTOP00

e="db file parallel write"
start="TO_DATE('201912120900','YYYYMMDDHH24MI')"
end="TO_DATE('201912131600','YYYYMMDDHH24MI')"

$AWR_DEV_HOME/src/awr_wait_trend.py $dbname "$e" $start $end YYYYMMDDHH24MI awr_wait_trend
