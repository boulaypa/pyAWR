start_p=20200924_000000
end_p=20200924_235959

date_fmt="YYYYMMDD_HH24MISS"

start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

$AWR_MINER_HOME/io_histogram.py --target ORAGEN2
