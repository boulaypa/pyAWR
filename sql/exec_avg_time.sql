select * from
(
   select
      sql_id,
      sql_plan_hash_value,
      event,sql_exec_id,
      sql_exec_start,current_obj#,
      sql_plan_line_id,
      sql_plan_operation,
      sql_plan_options,
      SUM (delta_read_io_requests) lio_read ,
      SUM (delta_read_io_bytes) pio_read ,
      count(*) count_1
   from
      dba_hist_active_sess_history
   where
      sql_id='4z2wwkah8702f'
   group by
      sql_id,
      sql_plan_hash_value,
      event,sql_exec_id,
      sql_exec_start,
      current_obj#,
      sql_plan_line_id,
      sql_plan_operation,
      sql_plan_options
  )
  order by count_1 desc;
