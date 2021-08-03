#!/usr/bin/python3

import cx_Oracle
import argparse
import sqlparse
from configparser import ConfigParser
import os

def main(args):
    if args["dsn"] is not None:
        dsnString=args["dsn"]
        dsnStringS=dsnString.split(':')
        host=dsnStringS[0]
        port=dsnStringS[1]
        sid=dsnStringS[2]
        odsn = cx_Oracle.makedsn(host, port, sid)
        print("DSN:"+host+":"+port+":"+sid)

    if args["host"] is not None:
        host=args["host"]
        if args["sid"] is not None:
           sid=args["sid"]
           if args["port"] is not None:
               port=args["port"]
           else :
               port="1521"
           odsn = cx_Oracle.makedsn(host, port, sid)

    if args["tns"] is not None:
        conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA,dsn=args["tns"])
    elif odsn is not None:
       conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA,dsn=odsn)
    else:
        conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA)


    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "get_sqltext.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__SQL_ID__', args["sqlid"]).replace('__DBNAME__', args["dbname"])

    results = ""

    cur = conn.cursor()
    cur.execute(sql2exec)
    for result in cur:
        results += "".join(result) 

    #print(results) 
    beauty=sqlparse.format(results, reindent=True, keyword_case='upper')
    print ( beauty )
    conn.close();
    text_file = open(args["sqlid"]+".sql_id", "w")
    n = text_file.write(beauty)
    text_file.close()

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument("--dbname", required=True )
    ap.add_argument("--sqlid", required=True )
    ap.add_argument("--dsn", required=False)
    ap.add_argument("--user", required=False)
    ap.add_argument("--password", required=False)
    ap.add_argument("--host", required=False)
    ap.add_argument("--port", required=False)
    ap.add_argument("--sid", required=False)
    ap.add_argument("--tns", required=False)
    args = vars(ap.parse_args())
    main(args)
