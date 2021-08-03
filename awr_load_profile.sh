start_p=2020_1116_000000
end_p=2020_1117_235959
date_fmt="YYYY_MMDD_HH24MISS"

start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

target="IOMUTX5"
target="NTOP00"
target="SIHMX03"

$AWR_MINER_HOME/awr_load_profile.py \
        --start "$start" --end "$end" --ofile "LOAD_${target}_${start_p}_${end_p}" \
        --target $target --verbose --csv
