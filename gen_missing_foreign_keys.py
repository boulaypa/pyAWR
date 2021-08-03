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
import os

APP_NAME="MISSING_FK_INDEXES"

def main(args):

    target=args.target
    schema=args.schema
    sql=args.sql

    conn = getCon(target)

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + sql
    outfile = os.environ.get('AWR_MINER_HOME') + "/csv/" + APP_NAME + "_" + target + "." + schema + ".csv"

    with open(sqlfile, 'r') as file:
            sql2exec = file.read()

    sql2exec=sql2exec.replace('__SCHEMA__', schema)
    df = pd.read_sql(sql2exec, con=conn)

    df.to_csv(outfile)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--schema", required=True )
    parser.add_argument("--sql", required=True )
    args = parser.parse_args()
    main(args)
