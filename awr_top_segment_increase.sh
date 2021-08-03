start="2020_1124_0000"
end="2020_1124_2359"

start_p="TO_DATE('"$start"','YYYY_MMDD_HH24MI')"
end_p="TO_DATE('"$end"','YYYY_MMDD_HH24MI')"

target=DOMUTX6
SCRIPT=awr_top_segment_increase.sql

awr_top_segment_increase.py --target $target --sql $SCRIPT --start "$start_p" --end "$end_p" --top 20
