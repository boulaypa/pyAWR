select * from (
 select
 WAIT_CLASS ,
 EVENT,
 count(sample_time) as EST_SECS_IN_WAIT
 from v$active_session_history
 where sample_time between sysdate - interval '1' hour and sysdate
 group by WAIT_CLASS,EVENT
 order by count(sample_time) desc
 )
where rownum <6
