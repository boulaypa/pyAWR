select
 to_char(sn.begin_interval_time,'YYYYMMDDHH24') SNAP_TIME,
 sum(sql.EXECUTIONS_DELTA)  EXECS
from dba_hist_sqlstat  sql,
     dba_hist_snapshot sn
where sql.sql_id='c5zncy79xadn0'
  and sql.dbid=sn.dbid
  and sql.snap_id=sn.snap_id
group by to_char(sn.begin_interval_time,'YYYYMMDDHH24')
order by to_char(sn.begin_interval_time,'YYYYMMDDHH24')
