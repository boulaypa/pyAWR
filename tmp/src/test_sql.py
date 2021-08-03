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
    script = args.script
    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open(script, 'r') as file:
            sql = file.read()
    print( sql )
    df = pd.read_sql(sql, con=conn)
    #print ( df.head() )
    pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', fill_value=0 )
    #pdf = df.pivot_table(index='TIME', columns='SRC', values='METRICS', dropna=False, aggfunc=np.sum)
    #pdf = df.pivot(index='TIME', columns='SRC', values='METRICS')
    #print ( pdf )
    print ( pdf.head() )

    pdf.plot(kind='area', stacked=True, title='Top 10 segments', color=['red', 'green', 'orange', 'darkred', 'brown', 'brown', 'pink', 'lightgreen', 'cyan', 'blue'])
    plt.gca().legend(loc='center left', bbox_to_anchor=(1, 0.5), title="HOSTNAME-username", fancybox=True)
    #plt.subplots_adjust(left=0)
    #plt.tight_layout()

    plt.xticks(rotation=45)
    plt.ylabel('Logical reads per hour')

    #plt.ylabel('Logical reads per hour')
    #plt.show()
    #plt.savefig('test.png')

    # Now check everything with the defaults:
    F = plt.gcf()
    DPI = F.get_dpi()
    print ("DPI:", DPI)
    DefaultSize = F.get_size_inches()
    print ("Default size in Inches", DefaultSize)
    print ("Which should result in a %i x %i Image"%(DPI*DefaultSize[0], DPI*DefaultSize[1]))

    # Now make the image twice as big, while keeping the fonts and all the
    # same size
    #F.set_figsize_inches( (DefaultSize[0]*2, DefaultSize[1]*2) )
    #Size = F.get_size_inches()
    #print ("Size in Inches", Size)

    #plt.savefig('myimage.pdf', format='pdf', dpi=2400, orientation='lanscape')
    plt.savefig('myimage.pdf', format='pdf', bbox_inches='tight', dpi=300 )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('script')
    args = parser.parse_args()
    main(args)
