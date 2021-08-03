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

    SQL_SRC='awr_wait_trend.sql'

    dbname = args.dbname
    event = args.event
    start = args.start
    end = args.end
    interval = args.interval
    outfile = args.outfile

    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args.outfile
    trcfile = os.environ.get('AWR_DEV_HOME') + "/trc/" + args.outfile.replace('.png', '.trc')
    parquetfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.parquet')
    jsonfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.json')
    trace=open(trcfile, 'w')
    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + SQL_SRC
    txtile = os.environ.get('AWR_DEV_HOME') + "/txt/" + args.outfile.replace('.png', '.txt')

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__EVENT_NAME__', event).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__INTERVAL__', interval ).replace('__DBNAME__', dbname)
    print( sql2exec, file=trace )

    df = pd.read_sql(sql2exec, con=conn)
    #df.set_index(['BEGIN_INTERVAL_TIME'], inplace=True)
    print( df )
    # create figure and axis objects with subplots()
    fig,ax = plt.subplots()

    # make a plot
    ax.plot(df.BEGIN_INTERVAL_TIME,df.TOTAL_WAITS, color="red")
    ax.set_ylabel("TOTAL_WAITS",color="red",fontsize=14)
    ax2=ax.twinx()
   
    ax2.plot(df.BEGIN_INTERVAL_TIME,df.AVG_TIME_MS, color="blue")
    ax2.set_ylabel("AVG_TIME_MS",color="blue",fontsize=14)
    # make a plot with different y-axis using second axis object
    statname="db file parallel write"
    plt.title(statname)
    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title=statname, fancybox=True)

    plt.show()
    


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('event')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('interval')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
