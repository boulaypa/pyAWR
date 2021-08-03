#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.font_manager as font_manager
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import os

def main(args):
    dbname = args.dbname
    statname = args.statname
    start = args.start
    end = args.end
    filename = args.filename
    title = args.title
    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)
    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "sp_sysstat.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', statname).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__DBNAME__', dbname)
    print ( sql2exec )
    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + filename.replace(' ','_').replace('/','_') + ".png"
    df = pd.read_sql(sql2exec, con=conn)
    print ( df )

    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H%M%S")
    df = df.drop(columns=["SNAP_TIME"])

    #df = df.resample('30min').asfreq()

    df.plot(kind='area', stacked=False)

    ax = plt.gca()
    mkfunc = lambda x, pos: '%1.1fG' % (x * 1e-9) if x >= 1e9 else '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.title(title)
    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title=statname, fancybox=True)
    plt.ylabel(statname,color="red")
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

    plt.show()
     
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('statname')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('filename')
    parser.add_argument('title')
    args = parser.parse_args()
    main(args)
