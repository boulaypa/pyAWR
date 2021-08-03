#!/logiciel/ms/ref/local/python/bin/python3

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
from tabulate import tabulate
import matplotlib.ticker as ticker


def config(filename='database.ini', section='oracle'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section,
filename))

    return db

def getCon():
    paramsO = config(section='oracle')
    dsn_tns = cx_Oracle.makedsn(paramsO['host'], paramsO['port'], service_name=paramsO['service'])
    conn = cx_Oracle.connect(user=paramsO['user'],password=paramsO['password'],dsn=dsn_tns)
    return( conn )
    

def main(args):

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "sql_id.sql"

    start = args["start"]
    end = args["end"]
    sqlid = args["sqlid"]
    metrics = args["metrics"]
    ofile = args["ofile"]

    tracePath = 'sql_id.trc'
    trace = open(tracePath,'w')

    outfile = os.environ.get('AWR_MINER_HOME') + "/png/" + ofile
    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    conn = getCon()

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', args["metrics"]).replace('__START_DATE__', args["start"]).replace('__END_DATE__', args["end"]).replace('__SQL_ID__', args["sqlid"] ).

    print( sql2exec )
    df = pd.read_sql(sql2exec, con=conn)

    trace.write(sql2exec)
    trace.write("\n df  \n")
    trace.write("\n"+str(list(df.columns))+"\n")
    trace.write(tabulate( df, headers='keys', tablefmt='psql'))

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
    ap = argparse.ArgumentParser()
    ap.add_argument("--sqlid", required=True )
    ap.add_argument("--metrics", required=True )
    ap.add_argument("--start", required=True )
    ap.add_argument("--end", required=True )
    ap.add_argument("--ofile", required=True )
    args = vars(ap.parse_args())
    main(args)
