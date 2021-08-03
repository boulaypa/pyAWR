select OWNER,SEGMENT_NAME,sum(BYTES)/(1024*1024*1024) as SIZE_GB from dba_segments where owner like 'ESBBWP%' group by OWNER,SEGMENT_NAME
