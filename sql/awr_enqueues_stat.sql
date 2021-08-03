select snap_id,eq_type,req_reason, total_req#, total_wait#,failed_req#, cum_wait_time 
from dba_hist_enqueue_stat 
where failed_req#>0 and eq_type='TM'
order by snap_id ASC
