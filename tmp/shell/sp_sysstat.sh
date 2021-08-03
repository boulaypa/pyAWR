start="TO_DATE('20191212','YYYYMMDD')"
end="TO_DATE('20191213','YYYYMMDD')"
db=IONTOT1
metrics="queries parallelized"
metrics="DDL statements parallelized"
metrics="DML statements parallelized"
$AWR_DEV_HOME/src/sp_sysstat.py $db "$metrics" "$start" "$end" "SYSSTAT_${metrics}" "${metrics}"
