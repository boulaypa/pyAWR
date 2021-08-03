SELECT segment_owner||'.'||segment_name||' ('||segment_type||')' as object,
           round( allocated_space/1024/1024,1 ) alloc_mb,
           round( used_space/1024/1024, 1 ) used_mb,
           round( reclaimable_space/1024/1024) reclaim_mb,
           round( reclaimable_space/allocated_space*100,0 ) pctsave,
           recommendations
      FROM TABLE(dbms_space.asa_recommendations())
     where segment_owner in ('CMNAMXX1','CMNBDSX1','CMNBPMX1')
order by 4 desc
