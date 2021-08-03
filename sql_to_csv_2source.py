#!/logiciel/ms/ref/local/python/bin/python3

from functions import *

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import matplotlib.ticker as ticker
import matplotlib.font_manager as font_manager
import argparse
from configparser import ConfigParser
import os

APP_NAME="SQL_2CSV"

def main(args):

    target0=args.target0
    sql0=args.sql0

    target1=args.target1
    sql1=args.sql1

    conn0 = getCon(target0)
    conn1 = getCon(target1)

    sqlfile0 = os.environ.get('AWR_MINER_HOME') + "/sql/" + sql0
    sqlfile1 = os.environ.get('AWR_MINER_HOME') + "/sql/" + sql1

    outfile = os.environ.get('AWR_MINER_HOME') + "/csv/" + APP_NAME + "_" + target0 + "_" + target1 + ".csv"

    with open(sqlfile0, 'r') as file0:
            sql2exec0 = file0.read()
    with open(sqlfile1, 'r') as file1:
            sql2exec1 = file1.read()

    df0 = pd.read_sql(sql2exec0, con=conn0)
    df0.rename(columns={'EXECS':'EXECS/'+target0}, inplace=True)
    print(df0)
    df1 = pd.read_sql(sql2exec1, con=conn1)
    df1.rename(columns={'EXECS':'EXECS/'+target1}, inplace=True)
    print(df1)

    df2=df0.merge(df1, on='SNAP_TIME', how='outer')
    df2.set_index('SNAP_TIME', inplace=True)
    print(df2)
    df2.to_csv(outfile)
    print(outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target0", required=True )
    parser.add_argument("--sql0", required=True )
    parser.add_argument("--target1", required=True )
    parser.add_argument("--sql1", required=True )
    args = parser.parse_args()
    main(args)
