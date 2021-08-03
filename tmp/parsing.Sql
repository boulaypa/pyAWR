select force_matching_signature fms, count(distinct(sql_id))
from  DBA_HIST_SQLSTAT
group by force_matching_signature
