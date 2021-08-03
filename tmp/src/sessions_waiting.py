#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import matplotlib.font_manager as font_manager
import matplotlib.patheffects as path_effects
import matplotlib.patches as mpatches
import os

def main(args):
    dbname = args.dbname
    owner = args.owner
    object_name = args.object_name
    start = args.start
    end = args.end
    outfile = args.outfile
    title = args.title

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sessions_waiting.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__OBJECT_NAME__', object_name).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__OWNER__', owner ).replace('__DBNAME__', dbname)
    print ( sql2exec  )
    df = pd.read_sql(sql2exec, con=conn)
    print ( df.head() )

    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H%M%S")
    df = df.drop(columns=["SNAP_TIME"])

    print ( df.head() )

    df = df.resample('1min').asfreq()

    df.plot(kind='area', stacked=True)
    plt.xticks(rotation=45)
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title="Segment name", fancybox=True)
    plt.ylabel("Sessions waiting for segment " +  object_name,color="red")

    plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('owner')
    parser.add_argument('object_name')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    parser.add_argument('title')
    args = parser.parse_args()
    main(args)
