#!/usr/bin/python3

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

def main(args):

    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "top_system_events.sql"

    dbname = args.dbname
    start = args.start
    end = args.end
    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args.outfile
    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)
    #conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)

    dsn_tns = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='COMUTX6')
    conn = cx_Oracle.connect(user="system",password="Ty67_1_June19",dsn=dsn_tns)

    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__DBNAME__', dbname)
    print( sql2exec )
    df = pd.read_sql(sql2exec, con=conn)
    print( df.head() )

    pdf = df.pivot_table(index='TIME', columns='SRC', values='TIME_WAITED_MICRO', fill_value=0 )

    pdf.plot(kind='area', stacked=True, title='Top 10 system events' )

    plt.xticks(rotation=45)
    plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title="system events", fancybox=True)
    plt.ylabel("TIME_WAITED_MICRO")
    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )
    plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
