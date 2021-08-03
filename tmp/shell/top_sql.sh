#metrics="buffer_gets_delta"
#metrics=$metrics" ""parse_calls_delta"
#metrics=$metrics" ""cpu_time_delta"
#metrics=$metrics" ""disk_reads_delta"
#metrics=$metrics" ""parse_calls_x_delta"
#metrics=$metrics" ""parse_calls_delta"
#metrics=$metrics" ""sorts_delta"
#metrics=$metrics" ""executions_delta"
#metrics=$metrics" ""apwait_delta"
#metrics=$metrics" ""elapsed_time_delta"
metrics=$metrics" ""iowait_delta"
#
#

dbname=COMUTX6
schema=LIGX1
start="TO_DATE('20200413000000','YYYYMMDDHH24MISS')"
end="TO_DATE('20200413235959','YYYYMMDDHH24MISS')"
tag=21Jan2020

#
#start="TO_DATE('2019120920','YYYYMMDDHH24')"
#end="TO_DATE('201912100130','YYYYMMDDHH24MI')"
#tag=09Dec2019
#

for m in $metrics
do
    $AWR_DEV_HOME/src/top_sql.py --dbname $dbname --schema MOOX1  \
	                         --metrics $m \
				 --top 10 \
				 --start "$start" --end "$end" --outfile TOPSQL_${m}_${tag}.png \
				 --stime 0 --etime 23 \
				 --user system --password "manager" \
				 --sql top_sql_norepo.sql \
				 --dsn 10.10.0.4:1521:GENT1

done
