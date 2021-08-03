#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style
import matplotlib.ticker as ticker
import argparse
from configparser import ConfigParser
import matplotlib.font_manager as font_manager
import pyarrow as pa
import pyarrow.parquet as pq
from pandasql import sqldf
import os
import sys

def main():
    for parquetFile in str(sys.argv):
        df=pd.read_parquet(parquetFile, engine='pyarrow')
        print ( df ) 

if __name__ == '__main__':
    main()
