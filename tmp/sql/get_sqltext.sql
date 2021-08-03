SELECT dbms_lob.substr(sql_text,dbms_lob.getlength(sql_text)) 
FROM dba_hist_sqltext
WHERE sql_id='__SQL_ID__'
AND dbid IN (
    SELECT dbid 
    FROM dba_hist_database_instance 
    WHERE db_name = '__DBNAME__' 
    FETCH FIRST 1 ROWS ONLY
)
