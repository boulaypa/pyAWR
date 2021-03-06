#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import matplotlib.font_manager as font_manager
import matplotlib.ticker as ticker
import os

def main(args):

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    if args["dsn"] is not None:
        dsnString=args["dsn"]
        dsnStringS=dsnString.split(':')
        host=dsnStringS[0]
        port=dsnStringS[1]
        sid=dsnStringS[2]
        dsn = cx_Oracle.makedsn(host, port, sid)

    if args["host"] is not None:
        host=args["host"]
        if args["sid"] is not None:
           sid=args["sid"]
           if args["port"] is not None:
               port=args["port"] 
           else :
               port="1521" 
           dsn = cx_Oracle.makedsn(host, port, sid)

    if args["tns"] is not None:
        conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA,dsn=args["tns"])
    elif dns is not None:
        conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA,dsn=dsn)
    else:
        conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)

    with open('sql_id.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', args["metrics"]).replace('__START_DATE__', args["start"]).replace('__END_DATE__', args["end"]).replace('__SQL_ID__', args["sqlid"] ).replace('__DBNAME__', args["dbname"])
    print( sql2exec ) 
    df = pd.read_sql(sql2exec, con=conn)
    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H%M%S")
    df = df.drop(columns=["SNAP_TIME"])
    print( df ) 
    info=df[['SQL_ID', 'PLAN_HASH_VALUE', 'RANK']]

    df.plot(title=args["metrics"].replace('_delta','').replace('_x',' per exec')  + ' for sqlid ' + args["sqlid"],color="red")

    ax = plt.gca()
    ax.set_facecolor('xkcd:black')
    mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.xticks(rotation=45)
    plt.ylabel(args["metrics"].replace('_delta','').replace('_x',' per exec'))
    #plt.show()
    plt.savefig(args["outfile"], format='png', bbox_inches='tight', dpi=300 )

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument("--dbname", required=True )
    ap.add_argument("--sqlid", required=True )
    ap.add_argument("--metrics", required=True )
    ap.add_argument("--start", required=True )
    ap.add_argument("--end", required=True )
    ap.add_argument("--outfile", required=True )
    ap.add_argument("--dsn", required=False)
    ap.add_argument("--tns", required=False)
    ap.add_argument("--host", required=False)
    ap.add_argument("--port", required=False)
    ap.add_argument("--sid", required=False)
    ap.add_argument("--user", required=False)
    ap.add_argument("--passwd", required=False)
    args = vars(ap.parse_args())
    main(args)
