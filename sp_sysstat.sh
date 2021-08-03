start_p=20201101_000000
end_p=20201230_235959
date_fmt="YYYYMMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target=DOMUTR6
metrics="session pga memory"

m=`echo $metrics | sed '1,$s/ /_/g'`
$AWR_MINER_HOME/sp_sysstat.py \
        --metrics "$metrics" --start "$start" --end "$end" --ofile "SYSSTAT_${m}_${start_p}_${end_p}.png" --target $target --verbose
