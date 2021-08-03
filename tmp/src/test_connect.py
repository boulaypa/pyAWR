#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import style
import os

if __name__ == '__main__':

    dsn_tns = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='COMUTX6') 
    #dsn_tns = cx_Oracle.makedsn('10.166.17.130', '1521', 'MHMT1') 
    connection = cx_Oracle.connect(user="system",password="Ty67_1_June19",dsn=dsn_tns)

    #connection = cx_Oracle.connect(user="SYS",password="Gu325rT333Ts393",mode=cx_Oracle.SYSDBA,dsn=dsn_tns)
    #con = cx_Oracle.connect('system', 'manager', 'MHMT1')
    #connection = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA,dsn='MHMT1')
    #cur = connection.cursor()
    #cur.execute("select distinct db_name from dba_hist_database_instance");
    #for row in cur:
    #    print(row)
    #cur.execute("select count(1) from dba_hist_sqlstat s, dba_users u where s.parsing_schema_name='LIGX1' and s.parsing_user_id=u.user_id");
    #for row in cur:
    #    print(row)
    #cur.execute("SELECT " +
    #        " count(1) " +
    #"FROM "+
    #"   dba_hist_snapshot "+
    #"WHERE begin_interval_time >= TO_DATE('20200131000000','YYYYMMDDHH24MISS') "+
    #"AND end_interval_time <= TO_DATE('20200131235959','YYYYMMDDHH24MISS') "+
    #"AND extract(hour from BEGIN_INTERVAL_TIME) >= 0 "+
    #"AND extract(hour from END_INTERVAL_TIME) <= 23")
    #for row in cur:
    #    print(row)
    #cur.close()
    connection.close()
