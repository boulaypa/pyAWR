#./sysstat_date.py NTOP00 "physical read total bytes" "TO_DATE('2019040820','YYYYMMDDHH24')" "TO_DATE('2019040923','YYYYMMDDHH24')" titi
db=NTOP00
metrics="physical read total bytes"
metrics="physical write total bytes"

start="TO_DATE('2019040820','YYYYMMDDHH24')"
end="TO_DATE('2019040901','YYYYMMDDHH24')"
tag=08Avr2019

start="TO_DATE('2019120920','YYYYMMDDHH24')"
end="TO_DATE('2019121002','YYYYMMDDHH24')"
tag=09Dec2019

start="TO_DATE('2019121209','YYYYMMDDHH24')"
end="TO_DATE('2019121316','YYYYMMDDHH24')"
tag=08Avr2019

#for metrics in "physical read total bytes" "physical write total bytes" "session logical reads" "parse time cpu" "CPU used by this session"
for metrics in "physical write total bytes" 
do
$AWR_DEV_HOME/src/sysstat_date.py $db "$metrics" "$start" "$end" "SYSSTAT_${metrics}_${tag}" $tag
done
