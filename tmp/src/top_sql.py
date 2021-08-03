#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import matplotlib.ticker as ticker
import argparse
from configparser import ConfigParser
import matplotlib.font_manager as font_manager
import pyarrow as pa
import pyarrow.parquet as pq
from pandasql import sqldf
import os
import json


def main(args):

    odsn=None
    if args["dsn"] is not None:
        dsnString=args["dsn"]
        dsnStringS=dsnString.split(':')
        host=dsnStringS[0]
        port=dsnStringS[1]
        sid=dsnStringS[2]
        #odsn = cx_Oracle.makedsn(host, port, service_name=sid)
        #print("DSN:"+host+":"+port+":"+sid)

    if args["host"] is not None:
        host=args["host"]
        if args["sid"] is not None:
           sid=args["sid"]
           if args["port"] is not None:
               port=args["port"]
           else :
               port="1521"
           #odsn = cx_Oracle.makedsn(host, port, sid)
           #odsn = cx_Oracle.makedsn(host, port, service_name=sid)
           #odsn = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='DOMUTX6')

    #if args["tns"] is not None:
        #conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA,dsn=args["tns"])
    #elif odsn is not None:
    #   conn = cx_Oracle.connect(user=args["user"],password=args["password"],dsn=odsn)
       #conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA,dsn=odsn)
    #else:
    #    conn = cx_Oracle.connect(user=args["user"],password=args["password"],mode=cx_Oracle.SYSDBA)

    dsn_tns = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='COMUTX6')
    conn = cx_Oracle.connect(user="SYSTEM",password="Ty67_1_June19",dsn=dsn_tns)

    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args["outfile"]
    trcfile = os.environ.get('AWR_DEV_HOME') + "/trc/" + args["outfile"].replace('.png', '.trc')
    parquetfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args["outfile"].replace('.png', '.parquet')
    jsonfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args["outfile"].replace('.png', '.json')
    trace=open(trcfile, 'w')

    if args["sql"] is not None:
        sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + args["sql"]
    else :
        sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "top_sql_norep.sql"

    txtile = os.environ.get('AWR_DEV_HOME') + "/txt/" + args["outfile"].replace('.png', '.txt')

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', args["metrics"]).replace('__START_DATE__', args["start"]).replace('__END_DATE__', args["end"]).replace('__TOP__', args["top"] ).replace('__DBNAME__', args["dbname"]).replace('__SCHEMA__', args["schema"]).replace('__STIME__', args["stime"]).replace('__ETIME__', args["etime"])

    print( sql2exec, file=trace )

    df = pd.read_sql(sql2exec, con=conn)

    info=df[['SQL_ID', 'PLAN_HASH_VALUE', 'PLAN_DATE','RANK']]
    info.set_index(['SQL_ID', 'PLAN_HASH_VALUE'], inplace=True)
    print( info, file=trace )
    u=info.drop_duplicates(keep='last')
    print( u, file=trace )

    table = pa.Table.from_pandas(u, preserve_index=True)
    pq.write_table(table, parquetfile)

    top_details = {
    'name': args["metrics"]
    }

    with open(jsonfile, 'w') as json_file:
        json.dump(top_details, json_file)

    pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )
    txt = open(txtile, 'w') 
    print(pdf.columns.values,file=txt)

    pdf.plot(kind='area', stacked=True, title='Top 10 SQLID for ' + args["metrics"])

    ax = plt.gca()
    ax.set_facecolor('xkcd:black')
    mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title="rank# % Sqlid", fancybox=True)
    plt.ylabel(args["metrics"])
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )
    plt.show()

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument("--dbname", required=True )
    ap.add_argument("--schema", required=True )
    ap.add_argument("--metrics", required=True )
    ap.add_argument("--start", required=True )
    ap.add_argument("--end", required=True )
    ap.add_argument("--stime", required=True )
    ap.add_argument("--etime", required=True )
    ap.add_argument("--outfile", required=True )
    ap.add_argument("--top", required=True )
    ap.add_argument("--dsn", required=False)
    ap.add_argument("--host", required=False)
    ap.add_argument("--tns", required=False)
    ap.add_argument("--user", required=False)
    ap.add_argument("--sql", required=False)
    ap.add_argument("--password", required=False)
    args = vars(ap.parse_args())
    main(args)
