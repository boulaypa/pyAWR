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

APP_NAME="SRVC"
SQL="awr_os_swap.sql"

def main(args):

    target=args.target

    conn = getCon(target)
    start = args.start
    end = args.end
    ofile = args.ofile

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + SQL

    directory=os.environ.get('AWR_MINER_HOME') + "/csv/" +target
    outfile = directory + "/" + APP_NAME + normalizeName(ofile)
    if not os.path.exists(directory):
        os.makedirs(directory)

    with open(sqlfile, 'r') as file:
            sql = file.read()

    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end)
    df = pd.read_sql(sql2exec, con=conn)
    print(df.head())
    df.to_csv(outfile)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    parser.add_argument('--ofile', required=True)
    args = parser.parse_args()
    main(args)
