#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import argparse
from configparser import ConfigParser
import os

def main(args):
    name = args.name
    unit = args.unit
    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sysmetric.sql', 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', name)
    outfile=name.replace(' ','_').replace('/','_') + ".pdf"
    print( outfile )
    print( sql2exec )
    df = pd.read_sql(sql2exec, con=conn)
    print( df )
    df.plot(x="BEGIN_TIME", y="VALUE")
    plt.xticks(rotation=45)
    plt.ylabel(unit)
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title=name, fancybox=True)
    plt.savefig("SYSMETRIC_"+outfile, format='pdf', bbox_inches='tight', dpi=300, orientation='landscape' )
    plt.show()
     
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('name')
    parser.add_argument('unit')
    args = parser.parse_args()
    main(args)
