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
from functools import reduce
import os
import sys
import json

if len(sys.argv) != 2:
    print('Must have 1 arguments!')
    print('Correct usage is "python answer.py input_dir " ')
    exit()

input_dir = sys.argv[1]
input_file_extension = '.parquet'
cmd = 'currentframe'

dfs = []

# iterate over the contents of the directory
for f in os.listdir(input_dir):
    # index of last period in string
    fi = f.rfind('.')
    # separate filename from extension
    file_name = f[:fi]
    file_ext = f[fi:]
    jsonfile = file_name + '.json'

    if file_ext in (input_file_extension):

        with open(jsonfile, 'r') as myfile:
            data=myfile.read()
        obj = json.loads(data)
        metrics=str(obj['name']).replace('_delta','')

        df=pd.read_parquet(f, engine='pyarrow')
        print( df )
        df.rename(columns={"RANK": metrics},inplace=True)
        df1 = df
        dfs.append(df1)

df_merged = reduce(lambda  left,right: pd.merge(left,right,on=['SQL_ID','PLAN_HASH_VALUE','PLAN_DATE'], how='outer'), dfs).fillna('void')
print ( df_merged )
df_merged.to_html('df_merged.html')
