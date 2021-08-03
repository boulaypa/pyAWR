#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import os

def main(args):
    dbname = args.dbname
    name = args.name
    unit = args.unit
    start = args.start
    end = args.end
    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sysmetric_date.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', name).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__DBNAME__', dbname)
    outfile=name.replace(' ','_').replace('/','_') + ".png"
    print( outfile )
    print( sql2exec )
    df = pd.read_sql(sql2exec, con=conn)
    print( df )

    df.index = pd.to_datetime(df["BEGIN_TIME"], format="%Y%m%d%H%M")
    df = df.drop(columns=["BEGIN_TIME"])

    print ( df.head() )

    df.plot(kind='area', stacked=True)
    plt.xticks(rotation=45)
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title="Segment name", fancybox=True)
    plt.ylabel("SYSMETRICS for " +  name,color="red")

    plt.show()

     
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('name')
    parser.add_argument('unit')
    parser.add_argument('start')
    parser.add_argument('end')
    args = parser.parse_args()
    main(args)
