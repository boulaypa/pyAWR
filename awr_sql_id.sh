target=DOMUTX6
sql_id="6tvhhzacvpnc6"

metrics=$metrics" ""parse_calls_delta"
metrics=$metrics" ""cpu_time_delta"
metrics=$metrics" ""disk_reads_delta"
metrics=$metrics" ""parse_calls_x_delta"
metrics=$metrics" ""parse_calls_delta"
metrics=$metrics" ""sorts_delta"
metrics=$metrics" ""apwait_delta"
metrics=$metrics" ""elapsed_time_delta"
metrics=$metrics" ""disk_reads_delta"
metrics=$metrics" ""physical_read_bytes_delta"
metrics=$metrics" ""physical_write_bytes_delta"
metrics="buffer_gets_delta"
metrics="buffer_gets_x_delta"
metrics=$metrics" ""executions_delta"

#
#
schema=%
start_p=2020_1104_000000
end_p=2020_1105_235959
date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

echo "target:"$target
echo "start:"$start_p
echo "end:"$end_p
echo "sql_id:"$sql_id

for m in $metrics
do
    $AWR_MINER_HOME/awr_sql_id.py --schema "$schema" \
                               --metrics $m \
			       --sql_id $sql_id \
			       --start "$start" --end "$end" --ofile SQLID_${sql_id}_${m}_${start_p}_${end_p}.png \
			       --target $target
done
