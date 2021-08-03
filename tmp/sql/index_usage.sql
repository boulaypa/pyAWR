 SELECT
 p.object_name search_columns,
 ROUND (COUNT(*)/15 ,2 ) COUNT
 FROM
 DBA_HIST_SNAPSHOT sn,
 DBA_HIST_SQL_PLAN p,
 DBA_HIST_SQLSTAT st
 WHERE
 st.sql_id = p.sql_id
 AND
 sn.snap_id = st.snap_id
AND
p.object_type = 'INDEX'
 AND sn.snap_id BETWEEN &start_snap_id AND &stop_snap_id
AND p.object_owner ='&USER_NAME'
GROUP BY
 p.object_name ORDER BY 2 DESC, 1
