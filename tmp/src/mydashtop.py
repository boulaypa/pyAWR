#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import numpy as np
import argparse
from configparser import ConfigParser
import pyarrow as pa
import pyarrow.parquet as pq
import os
import json


def main(args):
    dbname = args.dbname
    groupingcols = args.groupingcols
    filter = args.filter
    start = args.start
    end = args.end
    outfile = args.outfile

    outfile = os.environ.get('AWR_DEV_HOME') + "/png/" + args.outfile
    trcfile = os.environ.get('AWR_DEV_HOME') + "/trc/" + args.outfile.replace('.png', '.trc')
    parquetfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.parquet')
    jsonfile = os.environ.get('AWR_DEV_HOME') + "/parquet/" + args.outfile.replace('.png', '.json')
    trace=open(trcfile, 'w')
    sqlfile = os.environ.get('AWR_DEV_HOME') + "/sql/" + "mydashtop.sql"
    txtile = os.environ.get('AWR_DEV_HOME') + "/txt/" + args.outfile.replace('.png', '.txt')

    conn = cx_Oracle.connect(user="SYS",password="manager",mode=cx_Oracle.SYSDBA)
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__GROUPING_COLS__', groupingcols).replace('__START_DATE__', start).replace('__END_DATE__', end).replace('__TOP__', '20' ).replace('__DBNAME__', dbname).replace('__FILTERS__', filter )
    print( sql2exec, file=trace )

    df = pd.read_sql(sql2exec, con=conn)
    print( df )

    info=df[['SQL_ID', 'PLAN_HASH_VALUE', 'PLAN_DATE','RANK']]
    info.set_index(['SQL_ID', 'PLAN_HASH_VALUE'], inplace=True)
    print( info, file=trace )
    u=info.drop_duplicates(keep='last')
    print( u, file=trace )

    table = pa.Table.from_pandas(u, preserve_index=True)
    pq.write_table(table, parquetfile)

    top_details = { 'name': "ash" } 
    with open(jsonfile, 'w') as json_file:
        json.dump(top_details, json_file)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('dbname')
    parser.add_argument('groupingcols')
    parser.add_argument('filter')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('outfile')
    args = parser.parse_args()
    main(args)
