select TO_CHAR(s.begin_interval_time,'YYYYMMDD HH24MI'),
       u.maxquerylen,
       u.tuned_undoretention 
from DBA_HIST_UNDOSTAT u,
     DBA_HIST_SNAPSHOT s
where s.snap_id=u.snap_id
and   s.dbid=u.dbid
and   s.instance_number=u.instance_number
and   s.begin_interval_time >= __START_DATE__
and   s.end_interval_time <= __END_DATE__
order by TO_CHAR(s.begin_interval_time,'YYYYMMDD HH24MI') ASC
