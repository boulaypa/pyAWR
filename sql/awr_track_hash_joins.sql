select
   to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
   count(*)                                         c2,
   sum(st.rows_processed_delta)                     c3,
   sum(st.disk_reads_delta)                         c4,  
   sum(st.cpu_time_delta)                           c5
from
   dba_hist_snapshot sn,
   dba_hist_sql_plan  p,
   dba_hist_sqlstat   st
where st.sql_id = p.sql_id
and sn.snap_id = st.snap_id   
and sn.dbid = st.dbid 
and   p.operation like ‘%HASH%’
having count(*) > 0
group by begin_interval_time
