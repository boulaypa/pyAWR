-- Get the datbase block size from dba_hist_datafile
WITH ts_info as (
select dbid, ts#, tsname, max(block_size) block_size
from dba_hist_datafile
group by dbid, ts#, tsname),
-- Get the maximum snaphsot id for each day from dba_hist_snapshot
snap_info as (
select dbid,to_char(trunc(end_interval_time,'DD'),'MM/DD/YY') dd, max(s.snap_id) snap_id
from dba_hist_snapshot s
where s.end_interval_time > __START_DATE__
and s.end_interval_time < __END_DATE__
group by dbid,trunc(end_interval_time,'DD'))
-- Sum up the sizes of all the tablespaces for the last snapshot of each day
select s.dd, s.dbid, sum(tablespace_size*f.block_size)
from dba_hist_tbspc_space_usage sp,
ts_info f,
snap_info s
where s.dbid = sp.dbid
and s.snap_id = sp.snap_id
and sp.dbid = f.dbid
and sp.tablespace_id = f.ts#
group by s.dd, s.dbid
order by s.dd
