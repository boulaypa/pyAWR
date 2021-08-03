SELECT value num_cpus FROM v$osstat WHERE stat_name = 'NUM_CPUS'

select  snap_id, snap_len, round(id1 /snap_len *100,2) id1,
                       round(usr1 /snap_len *100,2) usr1,
                       round(sys1 /snap_len *100,2) sys1,
                       round(io1 /snap_len *100,2) io1,
                       round(nice1 /snap_len *100,2) nice1 
                     , snap_begin, snap_end
from (
     select  snap_id,  id1, usr1,sys1, io1, nice1
           , snap_begin, snap_end ,
             round( extract( day from diffs) *24*60*60*60+
                    extract( hour from diffs) *60*60+
                    extract( minute from diffs )* 60 +
                    extract( second from diffs )) snap_len 
             -- above is the exact length of the snapshot in seconds
     from ( select /*+ at this stage, each row show the cumulative value.
                       r1    7500  8600
                       r2    7300  8300
                       r3    7200  8110
                    we use [max(row) - lag(row)] to have the difference 
                    between [row and row-1], to obtain differentials values:
                       r1    200   300
                       r2    100   190
                       r3    0       0
                    */
        a.snap_id,
        (max(id1)    - lag( max(id1))   over (order by a.snap_id))/100        id1 ,
        (max(usr1)   - lag( max(usr1))  over (order by a.snap_id))/100        usr1,
        ( max(sys1)  - lag( max(sys1))  over (order by a.snap_id))/100        sys1,
        ( max(io1)   - lag( max(io1))   over (order by a.snap_id))/100        io1,
        ( max(nice1) - lag( max(nice1)) over (order by a.snap_id))/100        nice1,
          -- for later display
          max(to_char(BEGIN_INTERVAL_TIME,' YYYY-MM-DD HH24:mi:ss'))          snap_begin,
          -- for later display
          max(to_char(END_INTERVAL_TIME,' YYYY-MM-DD HH24:mi:ss'))            snap_end,
          -- exact len of snap used for percentage calculation
        ( max(END_INTERVAL_TIME)-max(BEGIN_INTERVAL_TIME))                    diffs
        from ( /*+  perform a pivot table so that the 5 values selected appear 
                    on one line. The case, distibute col a.value among 5 new 
                    columns, but creates a row for each. We will use the group 
                    by (snap_id) to condense the 5 rows into one. If you don't 
                    see how this works, just remove the group by and max function, 
                    then re-add it and you will see the use of max(). 
                    Here is what you will see:
        Raw data :   1000     2222
                     1000     3333
                     1000     4444
                     1000     5555
                     1000     6666
        The SELECT CASE creates populate our inline view with structure:
                       ID    IDLE    USER   SYS   IOWAIT   NICE
                     1000    2222
                     1000             3333
                     1000                   4444
                     1000                          5555
                     1000                                  6666
         the group by(1000) condenses the rows in one:
                       ID    IDLE    USER   SYS   IOWAIT  NICE
                      1000   2222    3333   4444   5555   6666
               */
               select a.snap_id,
                  case b.STAT_NAME
                       when 'IDLE_TIME' then a.value / &p_num_cpus
                   end  id1,
                  case b.STAT_NAME
                       when 'USER_TIME' then a.value / &p_num_cpus
                  end usr1 ,
                  case b.STAT_NAME
                       when 'SYS_TIME' then  a.value / &p_num_cpus
                  end sys1 ,
                  case b.STAT_NAME
                       when 'IOWAIT_TIME' then  a.value / &p_num_cpus
                  end io1,
                  case b.STAT_NAME
                       when 'NICE_TIME' then  a.value / &p_num_cpus
                  end nice1
                  from  DBA_HIST_OSSTAT a,  DBS_HIST_OSSTAT_NAME b
                       where
                            a.dbid      = b.dbid       and
                            a.STAT_ID   = b.stat_id    and
                            b.stat_name in ('IDLE_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME','NICE_TIME')
                       order by 1 desc
              ) a,  DBA_HIST_snapshot s
         where  a.snap_id = s.snap_id
         group by a.snap_id
         order by snap_id desc
        )
   )
