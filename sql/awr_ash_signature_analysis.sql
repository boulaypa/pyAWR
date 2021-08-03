select
   object_type,
   object_name,
   SUM(wait_count)
from
   dba_hist_waitstat          wait,
   dba_hist_snapshot            snap,
   dba_hist_active_sess_history   ash,
   dba_data_files              df,
   dba_objects                  obj
where wait.snap_id = snap.snap_id
and wait.snap_id = ash.snap_id
and df.file_id = ash.current_file#
and obj.object_id = ash.current_obj#
and wait_count > 0
group by object_type,object_name
order by SUM(wait_count) desc ;
