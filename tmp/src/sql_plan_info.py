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
    dbname = args.dbname
    sqlid = args.sqlid
    start = args.start
    end = args.end
    outfile = args.outfile

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sql_plan_info.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__SQL_ID__', sqlid ).replace('__DBNAME__', dbname)
    df = pd.read_sql(sql2exec, con=conn)
    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H%M%S")
    df = df.drop(columns=["SNAP_TIME"])
    print( df.head()) 

    #df.plot(title=metrics.replace('_delta','').replace('_x',' per exec')  + ' for sqlid ' + sqlid,color="red")

    #ax = plt.gca()
    #ax.set_facecolor('xkcd:black')
    #mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    #mkformatter = ticker.FuncFormatter(mkfunc)
    #ax.yaxis.set_major_formatter(mkformatter)

    #plt.xticks(rotation=45)
    #plt.ylabel(metrics.replace('_delta','').replace('_x',' per exec'))
    #plt.show()
    #plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('sqlid')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
