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
import decimal
from configparser import ConfigParser
import os

APP_NAME="SCHEMA_INDEX_DDL"

def main(args):

    target=args.target
    schema=args.schema
    sql=args.sql

    conn = getCon(target)
    print(conn)

    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + sql
    outfile = os.environ.get('AWR_MINER_HOME') + "/csv/" + APP_NAME + "_" + target + ".csv"

    with open(sqlfile, 'r') as file:
            sql2exec = file.read()

    sql2exec=sql2exec.replace('__SCHEMA__', schema)
    df = pd.read_sql(sql2exec, con=conn)

    #print(df)
    #df.to_csv(outfile)
    #print(outfile)

    cursor = conn.cursor()
    cursor.execute("""
    begin
        dbms_metadata.set_transform_param( dbms_metadata.session_transform,
            'SQLTERMINATOR', FALSE);
        dbms_metadata.set_transform_param( dbms_metadata.session_transform,
            'PRETTY', FALSE);
        dbms_metadata.set_transform_param( dbms_metadata.session_transform,
            'SEGMENT_ATTRIBUTES', FALSE);
    end;""")
    for index, row in df.iterrows():
            print(row['INDEX_NAME'])

            binds = dict(object_type='INDEX', name=row['INDEX_NAME'], schema=schema)
            ddl = cursor.callfunc('DBMS_METADATA.GET_DDL', keywordParameters=binds, returnType=cx_Oracle.CLOB)
            sql="begin dbms_space.create_index_cost('%s', :usedBindVar, :allocBindVar ); end;" % ( ddl )
            print( sql )
            #The number of bytes representing the actual index data
            # Used Bytes 
            usedOutVal = cursor.var(cx_Oracle.NUMBER)
            #Size of the index when created in the tablespace
            #Allocated Bytes
            allocOutVal = cursor.var(cx_Oracle.NUMBER)
            cursor.execute( sql, usedBindVar=usedOutVal, allocBindVar=allocOutVal )
            print(usedOutVal.getvalue())
            print(allocOutVal.getvalue())

#exec dbms_space.create_index_cost('create index scott.idx_test on scott.emp (emp_id, emp_hire_date) LOCAL', :used, :alloc );

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument("--target", required=True )
    parser.add_argument("--schema", required=True )
    parser.add_argument("--sql", required=True )
    args = parser.parse_args()
    main(args)
