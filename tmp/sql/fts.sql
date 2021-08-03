SELECT O.OBJECT_NAME,O.OWNER, SUM(S.TABLE_SCANS_TOTAL) "# of FTS",(SELECT NUM_ROWS FROM DBA_TABLES T WHERE T.TABLE_NAME = O.OBJECT_NAME) "num rows total"
 FROM DBA_HIST_SEG_STAT S JOIN DBA_OBJECTS O ON (S.OBJ# = O.DATA_OBJECT_ID)
 WHERE O.OWNER NOT IN ( 'SYS','DBSNMP','XDB')
 AND O.OBJECT_TYPE = 'TABLE'
 GROUP BY S.OBJ#,O.OBJECT_NAME,O.OWNER
 ORDER BY 4 DESC;
