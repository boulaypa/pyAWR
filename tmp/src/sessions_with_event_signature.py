#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import matplotlib.font_manager as font_manager
import os

def main(args):
    dbname = args.dbname
    event = args.event
    start = args.start
    end = args.end
    outfile = args.outfile

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sessions_with_event_signature.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__EVENT_NAME__', event).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__DBNAME__', dbname)
    print ( sql2exec )
    df = pd.read_sql(sql2exec, con=conn)

    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H")
    df = df.drop(columns=["SNAP_TIME"])

    print ( df )

    df.plot(color="red")
    plt.xticks(rotation=45)
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title=event + "event occurences", fancybox=True)
    plt.ylabel("Sessions waiting for event " +  event,color="red")

    plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('event')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
