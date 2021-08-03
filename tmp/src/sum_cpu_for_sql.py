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
    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open('sum_cpu_for_sql.sql', 'r') as file:
            sql = file.read()
    print( sql )
    df = pd.read_sql(sql, con=conn)
    print( df )
    df.plot(x="BEGIN_TIME", y="VALUE")
    plt.xticks(rotation=45)
    #plt.ylabel("cpu")
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title="cpu for sql", fancybox=True)
    plt.autoscale(True, 'y', tight = False)
    plt.savefig("sum_cpu_for_sql.png", format='png', bbox_inches='tight', dpi=300, orientation='landscape' )
     
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    args = parser.parse_args()
    main(args)
