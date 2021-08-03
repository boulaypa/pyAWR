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

    target=args.target
    sql=args.sql
    end=args.end
    start=args.start

    conn = getCon(target)
    print(conn)

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + sql
    outfile = os.environ.get('AWR_MINER_HOME') + "/csv/" + APP_NAME + "_" + target + ".csv"

    with open(sqlfile, 'r') as file:
            sql2exec = file.read()

    sql2exec=sql2exec.replace('__START_DATE__', start).replace('__END_DATE__', end)
    print(sql2exec)
    df = pd.read_sql(sql2exec, con=conn)
    print(df)
    df.to_csv(outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--sql", required=True )
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    args = parser.parse_args()
    main(args)
