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
    dbname = args.dbname
    sqlid = args.sqlid
    days = args.days
    interval = args.interval
    outfile = args.outfile

    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args.outfile
    trcfile = os.environ.get('AWR_DEV_HOME') + "/trc/" + args.outfile.replace('.png', '.trc')
    parquetfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.parquet')
    jsonfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.json')
    trace=open(trcfile, 'w')
    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "awr_sqlid_perf_trend_by_plan.sql"
    txtile = os.environ.get('AWR_DEV_HOME') + "/txt/" + args.outfile.replace('.png', '.txt')

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__SQL_ID__', sqlid).replace('__DAYS__', days).replace('__INTERVAL__', interval ).replace('__DBNAME__', dbname)
    print( sql2exec, file=trace )

    df = pd.read_sql(sql2exec, con=conn)
    print( df )

    #info=df[['SQL_ID', 'PLAN_HASH_VALUE', 'PLAN_DATE','RANK']]
    #info.set_index(['SQL_ID', 'PLAN_HASH_VALUE'], inplace=True)
    #print( info, file=trace )
    #u=info.drop_duplicates(keep='last')
    #print( u, file=trace )

    #table = pa.Table.from_pandas(u, preserve_index=True)
    #pq.write_table(table, parquetfile)

    #top_details = {
    #'name': metrics
    #}

    #with open(jsonfile, 'w') as json_file:
    #    json.dump(top_details, json_file)

    #pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )
    #txt = open(txtile, 'w') 
    #print(pdf.columns.values,file=txt)

    #pdf.plot(kind='area', stacked=False, title='Top 10 SQLID for ' + metrics)

    #ax = plt.gca()
    #ax.set_facecolor('xkcd:black')
    #mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    #mkformatter = ticker.FuncFormatter(mkfunc)
    #ax.yaxis.set_major_formatter(mkformatter)

    #plt.xticks(rotation=45)
    #plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title="rank# % Sqlid", fancybox=True)
    #plt.ylabel(metrics)
    #plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )
    #plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('sqlid')
    parser.add_argument('days')
    parser.add_argument('interval')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
