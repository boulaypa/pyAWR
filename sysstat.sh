start_p=20200920_220000
end_p=20200921_235959
date_fmt="YYYYMMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

for metrics in "logons cumulative" "physical read total bytes" "physical write total bytes" "session logical reads" "parse time cpu" "CPU used by this session"
do
    m=`echo $metrics | sed '1,$s/ /_/g'`
    $AWR_MINER_HOME/sysstat.py \
        --metrics "$metrics" --start "$start" --end "$end" --ofile "SYSSTAT_${m}_${start_p}_${end_p}.png" --target DOMUTX6 --verbose
done
