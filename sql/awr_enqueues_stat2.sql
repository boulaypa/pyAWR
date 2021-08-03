 select
  ety “Enqueue”,
  reqs "Requests",
  sreq "Successful Gets",
  freq "Failed Gets",
  waits "Waits",
  wttm "Wait Time (s)",
  awttm "Avg Wait Time(ms)"
from (
select /*+ ordered */
         e.eq_type || '-' || to_char(nvl(l.name,' '))
      || decode( upper(e.req_reason)
               , 'CONTENTION', null
               , '-',          null
               , ' ('||e.req_reason||')')                ety
     , e.total_req#    - nvl(b.total_req#,0)            reqs
     , e.succ_req#     - nvl(b.succ_req#,0)             sreq
     , e.failed_req#   - nvl(b.failed_req#,0)           freq
     , e.total_wait#   - nvl(b.total_wait#,0)           waits
     , (e.cum_wait_time - nvl(b.cum_wait_time,0))/1000  wttm
     , decode(  (e.total_wait#   - nvl(b.total_wait#,0))
               , 0, to_number(NULL)
               , (  (e.cum_wait_time - nvl(b.cum_wait_time,0))
                  / (e.total_wait#   - nvl(b.total_wait#,0))
                 )
             )                                          awttm
  from dba_hist_enqueue_stat e
     , dba_hist_enqueue_stat b
     , v$lock_type           l
where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.eq_type(+)         = e.eq_type
   and b.req_reason(+)      = e.req_reason
   and e.total_wait# - nvl(b.total_wait#,0) > 0
   and l.type(+)            = e.eq_type
 order by wttm desc, waits desc);
