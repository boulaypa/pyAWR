#!/logiciel/ms/ref/local/python/bin/python3

from functions import *

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.font_manager as font_manager
import numpy as np
from matplotlib import style
import argparse
from tabulate import tabulate

import os

def main(args):

    start = args["start"]
    end = args["end"]
    metrics = args["metrics"]
    ofile = args["ofile"]
    target = args["target"]

    tracePath = 'sp_sysstat.trc'
    trace = open(tracePath,'w')

    conn = getCon(target)

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)
    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "sp_sysstat.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', metrics).replace('__START_DATE__', start).replace('__END_DATE__', end)

    trace.write(metrics)
    trace.write(sql2exec)

    outfile = os.environ.get('AWR_MINER_HOME') + "/png/" + ofile 
    df = pd.read_sql(sql2exec, con=conn)
    if args["verbose"]:
        print(df.head())

    trace.write("\n df  \n")
    trace.write("\n"+str(list(df.columns))+"\n")
    trace.write(tabulate( df, headers='keys', tablefmt='psql'))

    df.index = pd.to_datetime(df["SNAP_TIME"], format="%Y%m%d%H%M%S")
    df = df.drop(columns=["SNAP_TIME"])
    df = df.drop(columns=["SNAP_ID"])

    df.plot(kind='area', stacked=False)

    ax = plt.gca()
    mkfunc = lambda x, pos: '%1.1fG' % (x * 1e-9) if x >= 1e9 else '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.title(metrics)
    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title=metrics, fancybox=True)
    plt.ylabel(metrics,color="red")
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

    print(outfile)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--metrics", required=True )
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    parser.add_argument("--ofile", required=True )
    parser.add_argument("--target", required=True )
    parser.add_argument("--verbose", default=False, action="store_true" , help="switch verbose mode on")
    args = vars(parser.parse_args())
    main(args)
