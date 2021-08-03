start_p=2020_1010_000000
end_p=2020_1010_235959

date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="NTOP00"

$AWR_MINER_HOME/awr_pga_stat.py \
        --start "$start" --end "$end" --ofile "PGASTAT_${target}_${start_p}_${end_p}" --target $target 
