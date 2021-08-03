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

APP_NAME="TOPSEG_"

def main(args):

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "awr_top_segments.sql"

    start = args["start"]
    end = args["end"]
    metrics = args["metrics"]
    ofile = args["ofile"]
    target = args["target"]

    tracePath = 'top_segments.trc'
    trace = open(tracePath,'w')

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    directory=os.environ.get('AWR_MINER_HOME') + "/png/" +target
    outfile = directory + "/" + APP_NAME + normalizeName(ofile)
    if not os.path.exists(directory):
        os.makedirs(directory)

    conn = getCon(target)

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__METRICS_NAME__', metrics)
    trace.write(sql2exec)
    df = pd.read_sql(sql2exec, con=conn)

    trace.write("\n df  \n")
    trace.write("\n"+str(list(df.columns))+"\n")
    trace.write(tabulate( df, headers='keys', tablefmt='psql'))

    df['SRC'] = df['SRC'].str.replace('$', '')
    pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )

    metrics_name=metrics.replace("_DELTA","")
    pdf.plot(kind='area', stacked=True, title='Top 10 segments for '+metrics_name )

    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title="segments owner.type.name", fancybox=True)
    plt.ylabel(metrics_name + " per Hour")
    ax = plt.gca()
    mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)

    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('--start', required=True)
    parser.add_argument('--end', required=True)
    parser.add_argument('--metrics', required=True)
    parser.add_argument('--ofile', required=True)
    parser.add_argument("--target", required=True )
    args = vars(parser.parse_args())
    main(args)
