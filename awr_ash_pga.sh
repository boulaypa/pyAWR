start_p=2020_1010_000000
end_p=2020_1010_235959
date_fmt="YYYY_MMDD_HH24MISS"
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"
target="NTOP00"

$AWR_MINER_HOME/awr_ash_pga.py --top 10 \
			       --start "$start" --end "$end" --ofile TOP_ASH_PGA_${m}_${start_p}_${end_p}.png \
			       --target $target
