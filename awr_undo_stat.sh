start_p=2020_1006_000000
end_p=2020_1006_235959
date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="DOMUTX6"

$AWR_MINER_HOME/awr_undo_stat.py \
    --start "$start" --end "$end" \
    --ofile UNDO_${m}_${start_p}_${end_p}.png \
    --target $target
