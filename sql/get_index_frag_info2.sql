WITH stats AS (
    select index_name,last_analyzed,stale_stats 
    from dba_ind_statistics WHERE owner='__SCHEMA__' order by index_name
), info AS (
select
  index_name,
  LEAF_BLOCKS,
  AVG_LEAF_BLOCKS_PER_KEY,
  CLUSTERING_FACTOR,
  SAMPLE_SIZE
from
  dba_indexes
where 
  table_owner = '__SCHEMA__'
    )
select info.index_name,LEAF_BLOCKS,AVG_LEAF_BLOCKS_PER_KEY,CLUSTERING_FACTOR,SAMPLE_SIZE
from stats,info
where stats.index_name=info.index_name
and LEAF_BLOCKS is not null
