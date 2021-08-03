target=COMUTX6
target=DOMUTX6

SCRIPT=get_table_frag_info.sql
SCRIPT=dump_ash_history_all.sql
SCRIPT=awr-enqueue-deadlocks.sql
SCRIPT=oracle_blocker_blocked_sess_history2.sql
SCRIPT=awr_enqueues_stat.sql
SCRIPT=awr_enqueues_stat3.sql
SCRIPT=dbms_segment_advisor.sql

sql_to_csv.py --target $target --sql $SCRIPT
