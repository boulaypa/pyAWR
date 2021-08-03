metrics=$1

start="2020_1120_0000"
end="2020_1127_2359"

start_p="TO_DATE('"$start"','YYYY_MMDD_HH24MI')"
end_p="TO_DATE('"$end"','YYYY_MMDD_HH24MI')"
target=DOMUTX6

get()
{
    cat awr_top_segments.in | egrep -v "^#" | while read metrics
    do
        echo "$metrics"
        $AWR_MINER_HOME/awr_top_segments.py --start "$start_p" --end "$end_p" \
        --metrics $metrics --ofile ${target}_${metrics}.${start}_${end}.png --target ${target}
    done
}

get
