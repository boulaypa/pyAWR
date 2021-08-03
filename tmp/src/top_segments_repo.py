#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import matplotlib.ticker as ticker
import argparse
from configparser import ConfigParser
import os

def main(args):

    SQL_SRC="top_segments.sql"

    dbname = args.dbname
    metrics = args.metrics
    start = args.start
    end = args.end
    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args.outfile
    #conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    dsn_tns = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='COMUTX6')
    conn = cx_Oracle.connect(user="system",password="Ty67_1_June19",dsn=dsn_tns)

    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + SQL_SRC
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', metrics).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__DBNAME__', dbname)
    print( sql2exec )

    df = pd.read_sql(sql2exec, con=conn)
    print( df )
    pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )

    pdf.plot(kind='area', stacked=False, title='Top 10 segments for ' + metrics)

    ax = plt.gca()
    ax.set_facecolor('xkcd:black')
    mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.xticks(rotation=45)
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title="Segment name", fancybox=True)
    plt.ylabel(metrics)
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )
    plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('metrics')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
