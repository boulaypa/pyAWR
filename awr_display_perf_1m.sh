target=DOMUTX6
awr_display_perf_1m.py --target=${target} \
                       --m1='ENQ_DEADLOCKS' \
                       --target=$target \
                       --ofile "deadlocks_${target}" \
                       --ifile=csv/SQL_2CSV_DOMUTX6.csv
