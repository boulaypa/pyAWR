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

def main(args):

    paramsO = config(section='oracle')
    dsn_tns = cx_Oracle.makedsn(paramsO['host'], paramsO['port'], service_name=paramsO['service'])
    conn = cx_Oracle.connect(user=paramsO['user'],password=paramsO['password'],dsn=dsn_tns)
    print(conn)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--sql", required=True )
    args = parser.parse_args()
    main(args)
