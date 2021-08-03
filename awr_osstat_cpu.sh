start_p=2020_1103_000000
end_p=2020_1105_235959

date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="DOMUTX6"

$AWR_MINER_HOME/awr_osstat_cpu.py \
        --start "$start" --end "$end" --ofile "OSSTAT_${target}_${start_p}_${end_p}" --target $target 
