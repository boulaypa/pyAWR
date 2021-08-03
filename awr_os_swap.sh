start_p=2020_1008_000000
end_p=2020_1009_235959

date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="DOMUTX6"

$AWR_MINER_HOME/awr_os_swap.py \
        --start "$start" --end "$end" --ofile "SWAP_${target}_${start_p}_${end_p}" --target $target 
