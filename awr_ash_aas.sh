start="2020_1027_0000"
end="2020_1027_2359"

start_p="TO_DATE('"$start"','YYYY_MMDD_HH24MI')"
end_p="TO_DATE('"$end"','YYYY_MMDD_HH24MI')"
target=DOMUTX6

$AWR_MINER_HOME/awr_ash_aas.py --start "$start_p" --end "$end_p" \
    --ofile ${target}_${metrics}.${start}_${end}.csv --target ${target}
