start_p="2020_1122_0000"
end_p="2020_1221_2359"

start="TO_DATE('$start_p','YYYY_MMDD_HH24MI')"
end="TO_DATE('$end_p','YYYY_MMDD_HH24MI')"

target="IOMUTX2"

$AWR_MINER_HOME/awr_top_system_events.py --start "$start" --end "$end" --ofile "TOP_SYSSTAT__${start_p}_${end_p}.png" --target $target
