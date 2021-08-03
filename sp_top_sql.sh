metrics="buffer_gets_delta"
#metrics=$metrics" ""parse_calls_delta"
#metrics=$metrics" ""cpu_time_delta"
#metrics=$metrics" ""disk_reads_delta"
#metrics=$metrics" ""parse_calls_x_delta"
#metrics=$metrics" ""parse_calls_delta"
#metrics=$metrics" ""sorts_delta"
#metrics=$metrics" ""executions_delta"
#metrics=$metrics" ""apwait_delta"
#metrics=$metrics" ""elapsed_time_delta"
#metrics=$metrics" ""disk_reads_delta"
#
#
schema=%
start_p=20200924_000000
end_p=20200924_235959
date_fmt="YYYYMMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

for m in $metrics
do
    $AWR_MINER_HOME/sp_top_sql.py --schema "$schema" \
                               --metrics $m \
			       --top 10 \
			       --start "$start" --end "$end" --ofile TOPSQL_${m}_${start_p}_${end_p}.png \
			       --stime 0 --etime 23 --target IONTOT1 --dbname IONTOT1
done
