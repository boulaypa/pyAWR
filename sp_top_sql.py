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
import matplotlib.ticker as ticker


def main(args):

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "sp_top_sql.sql"

    start = args["start"]
    end = args["end"]
    top = args["top"]
    schema = args["schema"]
    metrics = args["metrics"]
    ofile = args["ofile"]
    stime = args["stime"]
    etime = args["etime"]
    target = args["target"]
    dbname = args["dbname"]

    tracePath = 'sp_top_sql.trc'
    trace = open(tracePath,'w')

    outfile = os.environ.get('AWR_MINER_HOME') + "/png/" + ofile
    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = getCon(target)

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', args["metrics"]).replace('__START_DATE__', args["start"]).replace('__END_DATE__', args["end"]).replace('__TOP__', args["top"] ).replace('__SCHEMA__', args["schema"]).replace('__STIME__', args["stime"]).replace('__ETIME__', args["etime"]).replace('__DBNAME__', args["dbname"])

    df = pd.read_sql(sql2exec, con=conn)

    trace.write(sql2exec)
    trace.write("\n df  \n")
    trace.write("\n"+str(list(df.columns))+"\n")
    trace.write(tabulate( df, headers='keys', tablefmt='psql'))

    return

    pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )

    pdf.plot(kind='area', stacked=True, title='Top 10 sql_id for '+metrics+' ' )

    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title="sql_id", fancybox=True)
    plt.ylabel(metrics)
    ax = plt.gca()
    mkfunc = lambda x, pos: '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    ax.yaxis.set_major_formatter(mkformatter)
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--schema", required=True )
    parser.add_argument("--metrics", required=True )
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    parser.add_argument("--stime", required=True )
    parser.add_argument("--etime", required=True )
    parser.add_argument("--ofile", required=True )
    parser.add_argument("--top", required=True )
    parser.add_argument("--target", required=True )
    parser.add_argument("--dbname", required=True )
    args = vars(parser.parse_args())
    main(args)
