#SNAP_TIME,CPU used by this session,db block changes,elapsed,execute count,logons cumulative,parse count (hard),parse count (total),parse time cpu,physical read total bytes,physical write total bytes,redo size,session logical reads,sorts (disk),user calls,user commits

#./matplotlib-twin-axes3.py --m1='db block changes' --m2='physical read total bytes' --m3='physical write total bytes' --target=DOMUTX6 \
# --ifile=LOAD_DOMUTX6_20200910_000000_20200910_235959.csv

#./matplotlib-twin-axes3.py --m1='session logical reads' --m2='CPU used by this session' --m3='parse count (hard)' --target=DOMUTX6 \
# --ifile=LOAD_DOMUTX6_20200910_000000_20200910_235959.csv

#./matplotlib-twin-axes3.py --m1='session logical reads' \
#                           --m2='CPU used by this session' \
#                           --m3='parse count (hard)' --target=DOMUTX6 \
#                           --ifile=LOAD_DOMUTX6_20200910_000000_20200910_235959.csv

target=NTOP00
awr_display_perf.py --target=${target} \
                    --m1='CPU used by this session' \
                    --m2='logons cumulative' \
                    --m3='user calls' --target=NTOP00 \
                    --ofile "LOAD_${target}" \
                    --ifile=csv/NTOP00/LOAD_NTOP00_2020_1109_000000_2020_1113_235959.csv
