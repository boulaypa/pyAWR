WITH stats AS (
    select table_name,OBJECT_TYPE,last_analyzed,stale_stats 
    from dba_tab_statistics WHERE owner='__SCHEMA__' order by table_name
)
select stats.table_name,stats.last_analyzed,stats.stale_stats,frag.avg_row_len,frag.TOTAL_SIZE_MB,frag.ACTUAL_SIZE_MB,frag.FRAGMENTED_SPACE_MB,frag.percentage from 
(
select table_name,avg_row_len,round(((blocks*8/1024)),2) AS TOTAL_SIZE_MB,
round((num_rows*avg_row_len/1024/1024),2) AS ACTUAL_SIZE_MB,
round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) AS FRAGMENTED_SPACE_MB,
(round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 AS percentage
from dba_tables WHERE owner='ESBBWPX1'
and blocks > 0
union 
select table_name,avg_row_len,
0 AS TOTAL_SIZE_MB,
0 AS ACTUAL_SIZE_MB,
0 AS FRAGMENTED_SPACE_MB,
0 AS percentage
from dba_tables WHERE owner='__SCHEMA__'
and blocks <= 0
) frag , stats 
WHERE stats.table_name=frag.table_name
ORDER BY FRAGMENTED_SPACE_MB ASC
