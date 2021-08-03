select begin_interval_time 
from dba_hist_snapshot natural join dba_hist_database_instance
where db_name = 'NTOP00'
order by begin_interval_time asc
/
