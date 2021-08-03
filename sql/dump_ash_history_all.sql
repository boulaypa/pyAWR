SELECT h.*,x.begin_interval_time
FROM   dba_hist_snapshot x,
       dba_hist_active_sess_history h
WHERE  h.snap_id= x.snap_id
AND    h.dbid= x.dbid
AND    h.instance_number= x.instance_number
AND    x.begin_interval_time > SYSDATE - 1
