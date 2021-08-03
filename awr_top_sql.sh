#!/usr/bin/bash -e

date_fmt="YYYY_MMDD_HH24MISS"
start_p=2020_1214_000000
end_p=2020_1217_235959

usage() { echo "Usage: $0 --list-metrics --list-snapshots --list-targets [--target <target in database.ini >] [--metrics <metrics name>] [--start <start-date>] [--end <end date>]" 1>&2; exit 1; }

list_targets() { egrep "\[.*\]" database.ini | tr -d "[]";  }

list_metrics() {
cat <<EndOfCat
EndOfCat
}

ARGUMENT_LIST=(
    "target:"
    "start:"
    "end:"
    "metrics:"
    "date_fmt:"
    "help"
    "list-targets"
    "list-snapshots"
    "list-metrics"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            target=$2
            shift 2
            ;;
        --metrics)
            metrics=$2
            shift 2
            ;;
        --start)
            start_p=$2
            shift 2
            ;;
        --end)
            end_p=$2
            shift 2
            ;;
        --date_fmt)
            date_fmt=$2
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        --list-targets)
            list_targets
            shift 1
            exit
            ;;
        --list-metrics)
            list_metrics
            shift 1
            exit
            ;;
        *)
        break
            ;;
    esac
done

# a: variable is set
if [[ -z $target ]];
then
    usage
    exit 1
fi

metrics="buffer_gets_delta"
metrics=$metrics" ""parse_calls_delta"
metrics=$metrics" ""executions_delta"
metrics=$metrics" ""cpu_time_delta_sec"
metrics=$metrics" ""disk_reads_delta"
metrics=$metrics" ""parse_calls_x_delta"
metrics=$metrics" ""parse_calls_delta"
metrics=$metrics" ""sorts_delta"
metrics=$metrics" ""buffer_gets_delta"
metrics=$metrics" ""executions_delta"
metrics=$metrics" ""elapsed_time_delta_sec"
metrics=$metrics" ""apwait_delta"
metrics=$metrics" ""apwait_x_delta"
metrics=$metrics" ""disk_reads_delta"
metrics=$metrics" ""physical_read_bytes_delta"
metrics=$metrics" ""physical_write_bytes_delta"

schema=%
start="TO_DATE('$start_p','$date_fmt')"
end="TO_DATE('$end_p','$date_fmt')"

echo "target:"$target
echo "start:"$start_p
echo "end:"$end_p

for m in $metrics
do
    $AWR_MINER_HOME/awr_top_sql.py --schema "$schema" \
                               --metrics $m \
			       --top 10 \
			       --start "$start" --end "$end" --ofile TOPSQL_${m}_${start_p}_${end_p}.png \
			       --stime 0 --etime 23 --target $target
done
