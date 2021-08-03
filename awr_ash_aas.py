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
import os
from tabulate import tabulate

APP_NAME="AAS_"

def main(args):

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "awr_ash_aas.sql"

    start = args["start"]
    end = args["end"]
    ofile = args["ofile"]
    target = args["target"]

    tracePath = 'awr_ash_aas.trc'
    trace = open(tracePath,'w')

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    directory=os.environ.get('AWR_MINER_HOME') + "/csv/" +target
    outfile = directory + "/" + APP_NAME + normalizeName(ofile)
    if not os.path.exists(directory):
        os.makedirs(directory)

    conn = getCon(target)

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end)
    trace.write(sql2exec)
    df = pd.read_sql(sql2exec, con=conn)
    df.to_csv(outfile)
    print("file " + outfile + " created")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('--start', required=True)
    parser.add_argument('--end', required=True)
    parser.add_argument('--ofile', required=True)
    parser.add_argument("--target", required=True )
    args = vars(parser.parse_args())
    main(args)
