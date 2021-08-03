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
from tabulate import tabulate
import os

APP_NAME="UNDO_"

def main(args):

    target=args.target
    start = args.start
    end = args.end
    ofile = args.ofile
    
    tracePath = 'awr_undo_stat.trc'
    trace = open(tracePath,'w')

    conn = getCon(target)

    directory=os.environ.get('AWR_MINER_HOME') + "/file/" +target
    outfile = directory + "/" + APP_NAME + normalizeName(ofile)
    if not os.path.exists(directory):
        os.makedirs(directory)

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "awr_undo_stat.sql"

    with open(sqlfile, 'r') as file:
            sql = file.read()

    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end)
    trace.write(sql)
    df = pd.read_sql(sql2exec, con=conn)

    trace.write(sql2exec)
    trace.write("\n df  \n")
    trace.write("\n"+str(list(df.columns))+"\n")
    trace.write(tabulate( df, headers='keys', tablefmt='psql'))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    parser.add_argument("--ofile", required=True )

    args = parser.parse_args()
    main(args)
