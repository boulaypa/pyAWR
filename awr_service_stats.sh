start_p=2020_1109_000000
end_p=2020_1112_235959
date_fmt="YYYY_MMDD_HH24MISS"

start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="DOMUTX6"
target="IOMUTX5"

$AWR_MINER_HOME/awr_service_stats.py \
        --start "$start" --end "$end" --ofile "SERVICE_${target}_${start_p}_${end_p}" --target $target 
