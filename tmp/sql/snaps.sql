spool snaps.txt

select * from (
    select dbid,lead(snap_id)over(partition by instance_number order by end_interval_time desc) bid,
         snap_id eid,row_number() over(order by end_interval_time desc) n
    from dba_hist_snapshot natural join dba_hist_database_instance
    where db_name = 'NTOP00'
  ) order by BID ;

spool off
